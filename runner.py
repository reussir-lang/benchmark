import json
import os
import resource
import subprocess
import tempfile
import compile

from config import CONFIG
from benches import BENCHES


def _unlimit_stack():
    resource.setrlimit(resource.RLIMIT_STACK, (resource.RLIM_INFINITY, resource.RLIM_INFINITY))


def _runtime_env(bench_variant):
    env = os.environ.copy()
    if bench_variant == "rust-with-mimalloc":
        for assignment in CONFIG.get("rust-runtime-env", []):
            key, sep, value = assignment.partition("=")
            if not sep:
                raise ValueError(f"Invalid rust-runtime-env entry: {assignment!r}")
            env[key] = value
    return env


def _measure_peak_rss_kb(executable, env=None):
    time_binary = "/usr/bin/time"
    if not os.path.exists(time_binary):
        return None

    rss_file = tempfile.NamedTemporaryFile(
        mode="w",
        suffix=".rss",
        delete=False,
    )
    rss_path = rss_file.name
    rss_file.close()

    try:
        subprocess.run(
            [time_binary, "-f", "%M", "-o", rss_path, executable],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            text=True,
            preexec_fn=_unlimit_stack,
            env=env,
        )
        with open(rss_path, "r", encoding="utf-8") as f:
            rss_text = f.read().strip()
        if not rss_text:
            return None
        return int(rss_text.splitlines()[0])
    except (subprocess.SubprocessError, OSError, ValueError, IndexError):
        return None
    finally:
        if os.path.exists(rss_path):
            os.remove(rss_path)


def run_benchmark(bench_name, bench_variant):
    bench = BENCHES.get(bench_name)
    if bench is None:
        raise ValueError(f"Unknown bench_name: {bench_name}")

    bench_info = bench.get(bench_variant)
    if bench_info is None:
        raise ValueError(
            f"Unknown bench_variant for {bench_name}: {bench_variant}"
        )

    script_dir = os.path.dirname(os.path.abspath(__file__))

    def resolve(path):
        if os.path.isabs(path):
            return path
        return os.path.join(script_dir, path)

    with tempfile.TemporaryDirectory() as tmpdir:
        executable = os.path.join(tmpdir, f"{bench_name}-{bench_variant}")
        runtime_env = _runtime_env(bench_variant)

        if bench_variant in {"reussir", "reussir-nrac", "reussir-dia"}:
            if not isinstance(bench_info, tuple) or len(bench_info) != 2:
                raise ValueError(
                    f"Invalid reussir bench info for {bench_name}: {bench_info!r}"
                )
            program, driver = bench_info
            reuse_across_call = bench_variant != "reussir-nrac"
            extra_flags = (
                ["--disable-invariant-analysis"] if bench_variant == "reussir-dia" else []
            )
            compile.compile_reussir(
                resolve(program),
                resolve(driver),
                executable,
                reuse_across_call=reuse_across_call,
                extra_compiler_flags=extra_flags,
            )
        elif bench_variant == "koka":
            compile.compile_koka(resolve(bench_info), executable)
        elif bench_variant == "lean":
            compile.compile_lean(resolve(bench_info), executable)
        elif bench_variant in {"rust", "rust-with-mimalloc"}:
            compile.compile_rust(resolve(bench_info), executable)
        elif bench_variant == "haskell":
            compile.compile_haskell(resolve(bench_info), executable)
        else:
            raise ValueError(f"Unsupported bench_variant: {bench_variant}")

        json_file = tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".json",
            delete=False,
        )
        json_path = json_file.name
        json_file.close()
        try:
            hyperfine_cmd = [
                CONFIG["hyperfine"],
                "--warmup",
                str(CONFIG["warmup-runs"]),
                "--runs",
                str(CONFIG["runs"]),
                "--export-json",
                json_path,
                executable,
            ]
            try:
                subprocess.run(
                    hyperfine_cmd,
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.PIPE,
                    text=True,
                    preexec_fn=_unlimit_stack,
                    env=runtime_env,
                )
            except subprocess.CalledProcessError as e:
                error_details = e.stderr.strip() if e.stderr else "no error output"
                raise RuntimeError(
                    f"hyperfine failed for {bench_name}/{bench_variant}: {error_details}"
                ) from e
            with open(json_path, "r", encoding="utf-8") as f:
                result = json.load(f)
            peak_rss_kb = _measure_peak_rss_kb(executable, env=runtime_env)
            if peak_rss_kb is not None:
                result["peak_rss_kb"] = peak_rss_kb
            return result
        finally:
            if os.path.exists(json_path):
                os.remove(json_path)
