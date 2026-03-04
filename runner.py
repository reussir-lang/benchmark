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

        if bench_variant == "reussir":
            if not isinstance(bench_info, tuple) or len(bench_info) != 2:
                raise ValueError(
                    f"Invalid reussir bench info for {bench_name}: {bench_info!r}"
                )
            program, driver = bench_info
            compile.compile_reussir(
                resolve(program),
                resolve(driver),
                executable,
            )
        elif bench_variant == "koka":
            compile.compile_koka(resolve(bench_info), executable)
        elif bench_variant == "lean":
            compile.compile_lean(resolve(bench_info), executable)
        elif bench_variant == "rust":
            compile.compile_rust(resolve(bench_info), executable)
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
                )
            except subprocess.CalledProcessError as e:
                error_details = e.stderr.strip() if e.stderr else "no error output"
                raise RuntimeError(
                    f"hyperfine failed for {bench_name}/{bench_variant}: {error_details}"
                ) from e
            with open(json_path, "r", encoding="utf-8") as f:
                return json.load(f)
        finally:
            if os.path.exists(json_path):
                os.remove(json_path)
