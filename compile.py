import os
import shutil
import stat
import subprocess
import tempfile

from config import CONFIG


def _run_quiet(cmd, cwd, step):
    try:
        subprocess.run(
            cmd,
            check=True,
            cwd=cwd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except subprocess.CalledProcessError as e:
        streams = [
            stream.strip()
            for stream in (e.stdout, e.stderr)
            if stream and stream.strip()
        ]
        error_details = "\n".join(streams) if streams else "no error output"
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
                "-flto=thin",
                "-fuse-ld=lld",
                "-O3",
                "-march=native",
                CONFIG["reussir-libs"] + "/libreussir_rt.a",
            ],
            cwd=tmpdir,
            step="reussir linking",
        )
    _ensure_executable(output, "reussir linking")


def compile_koka(program: str, output: str) -> None:
    # -O3 with the same clang, thin-LTO, and -march=native the reussir
    # variant links with, so kklib participates in cross-module optimization.
    with tempfile.TemporaryDirectory() as tmpdir:
        _run_quiet(
            [
                CONFIG["koka-compiler"],
                "-O3",
                f"--cc={CONFIG['cc']}",
                "--ccopts=-flto=thin -march=native",
                "--cclinkopts=-flto=thin -fuse-ld=lld",
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
            "-C",
            "opt-level=3",
            "-o",
            output,
            program,
        ],
        cwd=os.path.dirname(program) or ".",
        step="rust compilation",
    )
    _ensure_executable(output, "rust compilation")


def compile_haskell(program: str, output: str, rts_opts: str | None = None) -> None:
    # -rtsopts always; an ``rts_opts`` string (e.g. "-A1G") is baked into the
    # binary with -with-rtsopts so the harness can run it with no arguments.
    ghc_cmd = [
        CONFIG["ghc"],
        "-O2",
        "-rtsopts",
    ]
    if rts_opts:
        ghc_cmd.append(f"-with-rtsopts={rts_opts}")
    with tempfile.TemporaryDirectory() as tmpdir:
        _run_quiet(
            ghc_cmd
            + [
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


def compile_ocaml(program: str, output: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        # OCaml derives a module name from the filename; benchmark names use
        # hyphens, which are not valid in module identifiers.
        local_name = os.path.basename(program).replace("-", "_")
        local_program = os.path.join(tmpdir, local_name)
        shutil.copyfile(program, local_program)
        _run_quiet(
            [
                CONFIG["ocamlopt"],
                "-O3",
                "-o",
                output,
                local_program,
            ],
            cwd=tmpdir,
            step="OCaml compilation",
        )
    _ensure_executable(output, "OCaml compilation")


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
