import json
import os
import resource
import signal
import statistics
import subprocess
import tempfile
import time
import compile

from config import CONFIG
from benches import BENCHES, VARIANTS


def _unlimit_stack():
    resource.setrlimit(resource.RLIMIT_STACK, (resource.RLIM_INFINITY, resource.RLIM_INFINITY))


def _runtime_env(bench_variant):
    env = os.environ.copy()
    env_key = VARIANTS.get(bench_variant, {}).get("runtime_env_key")
    if env_key:
        for assignment in CONFIG.get(env_key, []):
            key, sep, value = assignment.partition("=")
            if not sep:
                raise ValueError(f"Invalid {env_key} entry: {assignment!r}")
            env[key] = value
    return env


def _run_until(command, deadline, env):
    remaining = deadline - time.monotonic()
    if remaining <= 0:
        raise subprocess.TimeoutExpired(command, 0)
    with subprocess.Popen(
        command,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
        preexec_fn=_unlimit_stack,
        start_new_session=True,
        env=env,
    ) as process:
        try:
            _, stderr = process.communicate(timeout=remaining)
        except subprocess.TimeoutExpired:
            # hyperfine and GNU time launch children; stop the whole sample.
            os.killpg(process.pid, signal.SIGKILL)
            process.communicate()
            raise
        if process.returncode:
            raise subprocess.CalledProcessError(process.returncode, command, stderr=stderr)


def _measure_rss_sample(executable, deadline, env):
    time_binary = CONFIG.get("time", "/usr/bin/time")
    if not os.path.isabs(time_binary):
        import shutil

        time_binary = shutil.which(time_binary)
    if not time_binary or not os.path.exists(time_binary):
        _run_until([executable], deadline, env)
        return None

    with tempfile.TemporaryDirectory() as tmpdir:
        rss_path = os.path.join(tmpdir, "peak.rss")
        _run_until(
            [time_binary, "-f", "%M %e %U %S", "-o", rss_path, executable], deadline, env
        )
        with open(rss_path, "r", encoding="utf-8") as stream:
            rss, elapsed, user, system = stream.read().strip().split()
            return {
                "peak_rss_kb": int(rss),
                "times": [float(elapsed)],
                "user": float(user),
                "system": float(system),
                "exit_codes": [0],
            }


def measure_executable(executable, env=None):
    """Measure completed samples within one budget, including warmups and RSS."""
    budget = float(CONFIG.get("case-time-budget-seconds", 300))
    if budget <= 0:
        raise ValueError("case-time-budget-seconds must be positive")
    requested = int(CONFIG["runs"])
    if requested <= 0:
        raise ValueError("runs must be positive")
    started = time.monotonic()
    deadline = started + budget
    samples = []
    rss_sample = None
    warmups = 0
    limited = False
    try:
        rss_sample = _measure_rss_sample(executable, deadline, env)
        estimate = time.monotonic() - started
        # The RSS run also warms the program. Reserve room for timing points
        # before spending the remaining budget on additional warmups.
        warmups = 1
        desired_warmups = max(0, int(CONFIG["warmup-runs"]) - 1)
        for _ in range(desired_warmups):
            if deadline - time.monotonic() < estimate * (min(2, requested) + 1):
                break
            before = time.monotonic()
            _run_until([executable], deadline, env)
            estimate = max(estimate, time.monotonic() - before)
            warmups += 1

        with tempfile.TemporaryDirectory() as tmpdir:
            json_path = os.path.join(tmpdir, "sample.json")
            for _ in range(requested):
                if deadline - time.monotonic() < estimate:
                    limited = True
                    break
                before = time.monotonic()
                _run_until(
                    [CONFIG["hyperfine"], "--warmup", "0", "--runs", "1",
                     "--export-json", json_path, executable],
                    deadline,
                    env,
                )
                with open(json_path, "r", encoding="utf-8") as stream:
                    samples.append(json.load(stream)["results"][0])
                estimate = max(estimate, time.monotonic() - before)
    except subprocess.TimeoutExpired:
        limited = True

    timing_source = "hyperfine"
    if not samples and rss_sample is not None:
        # A completed long RSS run still provides a GNU time timing point.
        samples = [rss_sample]
        timing_source = "gnu-time"
    result = {
        "results": [],
        "timing_source": timing_source if samples else None,
        "sample_count": len(samples),
        "requested_samples": requested,
        "warmup_runs": warmups,
        "case_time_budget_seconds": budget,
        "measurement_seconds": time.monotonic() - started,
        "budget_limited": limited,
    }
    if rss_sample is not None:
        result["peak_rss_kb"] = rss_sample["peak_rss_kb"]
    if samples:
        times = [duration for sample in samples for duration in sample["times"]]
        result["results"] = [{
            "command": executable,
            "mean": statistics.fmean(times),
            "stddev": statistics.stdev(times) if len(times) > 1 else None,
            "median": statistics.median(times),
            "user": statistics.fmean(sample["user"] for sample in samples),
            "system": statistics.fmean(sample["system"] for sample in samples),
            "min": min(times),
            "max": max(times),
            "times": times,
            "exit_codes": [code for sample in samples for code in sample["exit_codes"]],
        }]
    return result


def run_benchmark(bench_name, bench_variant):
    bench = BENCHES.get(bench_name)
    if bench is None:
        raise ValueError(f"Unknown bench_name: {bench_name}")

    bench_info = bench.get("sources", {}).get(bench_variant)
    if bench_info is None:
        raise ValueError(
            f"Unknown bench_variant for {bench_name}: {bench_variant}"
        )
    spec = VARIANTS.get(bench_variant)
    if spec is None:
        raise ValueError(f"Variant {bench_variant} is not registered in VARIANTS")

    script_dir = os.path.dirname(os.path.abspath(__file__))

    def resolve(path):
        if os.path.isabs(path):
            return path
        return os.path.join(script_dir, path)

    with tempfile.TemporaryDirectory() as tmpdir:
        executable = os.path.join(tmpdir, f"{bench_name}-{bench_variant}")
        runtime_env = _runtime_env(bench_variant)

        compile.compile_cell(bench, spec, bench_info, executable, resolve)

        try:
            return measure_executable(executable, runtime_env)
        except subprocess.CalledProcessError as error:
            details = error.stderr.strip() if error.stderr else "no error output"
            raise RuntimeError(
                f"benchmark failed for {bench_name}/{bench_variant}: {details}"
            ) from error
