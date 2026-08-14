"""Correctness sweep: compile every (bench, variant) cell and run it once.

Benchmarks self-verify (non-zero exit on a wrong result), so a clean sweep
means every implementation in every configuration computes the expected
value. Run this after touching any benchmark or toolchain configuration;
it is much faster than the timed suite.

Usage:
    python3 verify.py [--bench NAME] [--variant NAME] [--set NAME]
"""

import argparse
import os
import resource
import subprocess
import sys
import tempfile

import compile as compilers
from benches import BENCHES, SETS, VARIANTS


def _unlimit_stack():
    # Mirror runner.py: several variants (notably Rust, which does not
    # guarantee tail-call elimination) need an unlimited stack at these
    # workload sizes.
    resource.setrlimit(
        resource.RLIMIT_STACK, (resource.RLIM_INFINITY, resource.RLIM_INFINITY)
    )


def _targets(args):
    for bench_name in sorted(BENCHES):
        meta = BENCHES[bench_name]
        if args.bench and bench_name != args.bench:
            continue
        if args.bench_set and meta["set"] != args.bench_set:
            continue
        for variant in sorted(meta["sources"]):
            if args.variant and variant != args.variant:
                continue
            yield bench_name, variant, meta, meta["sources"][variant]


def _compile(variant, bench_meta, source, executable, resolve):
    spec = VARIANTS[variant]
    kind = spec["kind"]
    if kind == "reussir":
        program, driver = source
        compilers.compile_reussir(
            resolve(program),
            resolve(driver),
            executable,
            reuse_across_call=spec.get("reuse_across_call", True),
            extra_compiler_flags=list(spec.get("extra_flags", [])),
            use_std=bench_meta.get("reussir-std", False),
        )
    elif kind == "koka":
        compilers.compile_koka(resolve(source), executable)
    elif kind == "lean":
        compilers.compile_lean(resolve(source), executable)
    elif kind == "rust":
        compilers.compile_rust(
            resolve(source), executable, extern_crates=spec.get("extern_crates")
        )
    elif kind == "haskell":
        compilers.compile_haskell(
            resolve(source), executable, rts_opts=spec.get("rts_opts")
        )
    elif kind == "ocaml":
        compilers.compile_ocaml(resolve(source), executable)
    else:
        raise ValueError(f"Unsupported variant kind: {kind}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bench", choices=sorted(BENCHES.keys()))
    parser.add_argument("--variant", choices=sorted(VARIANTS.keys()))
    parser.add_argument("--set", dest="bench_set", choices=sorted(SETS.keys()))
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))

    def resolve(path):
        return path if os.path.isabs(path) else os.path.join(script_dir, path)

    failures = []
    for bench_name, variant, meta, source in _targets(args):
        label = f"{bench_name}/{variant}"
        with tempfile.TemporaryDirectory() as tmpdir:
            executable = os.path.join(tmpdir, "bench")
            try:
                _compile(variant, meta, source, executable, resolve)
            except Exception as e:  # noqa: BLE001 - report and continue
                print(f"FAIL {label}: compile: {e}", flush=True)
                failures.append(label)
                continue
            proc = subprocess.run(
                [executable],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
                preexec_fn=_unlimit_stack,
            )
            if proc.returncode != 0:
                detail = proc.stderr.strip() or f"exit {proc.returncode}"
                print(f"FAIL {label}: {detail}", flush=True)
                failures.append(label)
            else:
                print(f"ok   {label}", flush=True)

    if failures:
        print(f"\n{len(failures)} failure(s): {', '.join(failures)}")
        return 1
    print("\nall cells verified")
    return 0


if __name__ == "__main__":
    sys.exit(main())
