import os
import subprocess
import tempfile
import shutil
import stat

from config import CONFIG


def _run_quiet(cmd, cwd, step):
    try:
        subprocess.run(
            cmd,
            check=True,
            cwd=cwd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
        )
    except subprocess.CalledProcessError as e:
        error_details = e.stderr.strip() if e.stderr else "no error output"
        raise RuntimeError(f"{step} failed: {error_details}") from e


def _ensure_executable(path, step):
    if not os.path.exists(path):
        raise RuntimeError(f"{step} failed: expected output not found at {path}")
    mode = os.stat(path).st_mode
    execute_bits = stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
    if mode & execute_bits:
        return
    os.chmod(path, mode | execute_bits)


def compile_reussir(
    program: str,
    driver: str,
    output: str,
    reuse_across_call: bool = True,
    extra_compiler_flags=None,
) -> None:
    if extra_compiler_flags is None:
        extra_compiler_flags = []
    compiler_cmd = [
        CONFIG["reussir-compiler"],
        "-o",
        "reussir.ll",
        "-Oaggressive",
    ]
    if reuse_across_call:
        compiler_cmd.append("--reuse-across-call")
    compiler_cmd.extend(extra_compiler_flags)
    compiler_cmd.extend(
        [
            "--relocation-mode",
            "pic",
            "-t",
            "llvm-ir",
            program,
        ]
    )
    with tempfile.TemporaryDirectory() as tmpdir:
        _run_quiet(
            compiler_cmd,
            cwd=tmpdir,
            step="reussir compilation",
        )
        _run_quiet(
            [
                CONFIG["cc"],
                "-o",
                output,
                "reussir.ll",
                driver,
                "-flto",
                "-O3",
                "-march=native",
                "-L",
                CONFIG["reussir-libs"],
                "-lreussir_rt",
                f"-Wl,-rpath={CONFIG['reussir-libs']}",
            ],
            cwd=tmpdir,
            step="reussir linking",
        )
    _ensure_executable(output, "reussir linking")

def compile_koka(program: str, output: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        _run_quiet(
            [
                CONFIG["koka-compiler"],
                "-O3",
                program,
                "-o",
                output,
            ],
            cwd=tmpdir,
            step="koka compilation",
        )
    _ensure_executable(output, "koka compilation")

def compile_rust(program: str, output: str) -> None:
    _run_quiet(
        [
            CONFIG["rustc"],
            "-C", "opt-level=3",
            "-o",
            output,
            program,
        ],
        cwd=os.path.dirname(program) or ".",
        step="rust compilation",
    )
    _ensure_executable(output, "rust compilation")


def compile_haskell(program: str, output: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        _run_quiet(
            [
                CONFIG["ghc"],
                "-O2",
                "-outputdir",
                tmpdir,
                "-o",
                output,
                program,
            ],
            cwd=tmpdir,
            step="haskell compilation",
        )
    _ensure_executable(output, "haskell compilation")


def compile_lean(program: str, output: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        # copy program to tmpdir
        shutil.copyfile(program, os.path.join(tmpdir, os.path.basename(program)))
        _run_quiet(
            [
                CONFIG["lean-compiler"],
                os.path.join(tmpdir, os.path.basename(program)),
                "-c",
                f"{output}.c",
            ],
            cwd=tmpdir,
            step="lean C emission",
        )
        _run_quiet(
            [
                CONFIG["leanc"],
                "-o",
                output,
                f"{output}.c",
                "-flto",
                "-O3",
            ],
            cwd=tmpdir,
            step="lean linking",
        )
    _ensure_executable(output, "lean linking")
