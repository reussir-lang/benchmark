import glob
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


# Compiled core/std package artifacts (interface + LLVM IR), keyed by the
# codegen flags they were built with. The cache holds TemporaryDirectory
# objects alive for the process so verify/bench runs compile the packages
# once per configuration instead of once per cell.
_STD_CACHE = {}


def _reussir_codegen_flags(reuse_across_call, extra_compiler_flags):
    flags = ["-Oaggressive"]
    if reuse_across_call:
        flags.append("--reuse-across-call")
    flags.extend(extra_compiler_flags)
    flags.extend(["--relocation-mode", "pic"])
    return flags


def _reussir_std_artifacts(reuse_across_call, extra_compiler_flags):
    """Build Reussir's bundled core and std packages to .rri + LLVM IR.

    Returns the directory holding core.rri/core.ll/std.rri/std.ll. The
    packages get the same codegen flags as the benchmark program, so
    reuse analysis and LTO treat std code exactly like benchmark code.
    """
    key = (reuse_across_call, tuple(extra_compiler_flags))
    cached = _STD_CACHE.get(key)
    if cached is not None:
        return cached.name
    source_root = CONFIG.get("reussir-src")
    if not source_root:
        raise RuntimeError(
            "std benchmarks need the pinned Reussir source tree; set "
            "REUSSIR_SRC (exported by the Nix dev shell) or reussir-src "
            "in config.json"
        )
    core_src = os.path.join(source_root, "library", "core", "src")
    std_src = os.path.join(source_root, "library", "std", "src")
    tmpdir = tempfile.TemporaryDirectory(prefix="reussir-std-")
    d = tmpdir.name
    codegen_flags = _reussir_codegen_flags(reuse_across_call, extra_compiler_flags)
    rrc = CONFIG["reussir-compiler"]
    core_pkg = [rrc, "--package-root", core_src, "--package-name", "core", "--core"]
    _run_quiet(
        core_pkg + ["-t", "rri", "-o", "core.rri"],
        cwd=d,
        step="reussir core interface",
    )
    _run_quiet(
        core_pkg + ["-t", "llvm-ir", "-o", "core.ll"] + codegen_flags,
        cwd=d,
        step="reussir core compilation",
    )
    core_externs = [
        "--extern",
        f"core={os.path.join(d, 'core.rri')}",
        "--extern-src",
        f"core={core_src}",
    ]
    std_pkg = [rrc, "--package-root", std_src, "--package-name", "std"]
    std_pkg += core_externs
    _run_quiet(
        std_pkg + ["-t", "rri", "-o", "std.rri"],
        cwd=d,
        step="reussir std interface",
    )
    _run_quiet(
        std_pkg + ["-t", "llvm-ir", "-o", "std.ll"] + codegen_flags,
        cwd=d,
        step="reussir std compilation",
    )
    _STD_CACHE[key] = tmpdir
    return d


def compile_reussir(
    program: str,
    driver: str,
    output: str,
    reuse_across_call: bool = True,
    extra_compiler_flags=None,
    use_std: bool = False,
) -> None:
    if extra_compiler_flags is None:
        extra_compiler_flags = []
    compiler_cmd = [
        CONFIG["reussir-compiler"],
        "-o",
        "reussir.ll",
    ]
    extra_link_inputs = []
    if use_std:
        std_dir = _reussir_std_artifacts(reuse_across_call, extra_compiler_flags)
        source_root = CONFIG["reussir-src"]
        compiler_cmd.extend(
            [
                # --extern needs package mode; the input file becomes the
                # crate root of this single-file benchmark package.
                "--package-name",
                "bench",
                "--extern",
                f"core={os.path.join(std_dir, 'core.rri')}",
                "--extern-src",
                f"core={os.path.join(source_root, 'library', 'core', 'src')}",
                "--extern",
                f"std={os.path.join(std_dir, 'std.rri')}",
                "--extern-src",
                f"std={os.path.join(source_root, 'library', 'std', 'src')}",
            ]
        )
        extra_link_inputs = [
            os.path.join(std_dir, "std.ll"),
            os.path.join(std_dir, "core.ll"),
        ]
    compiler_cmd.extend(
        _reussir_codegen_flags(reuse_across_call, extra_compiler_flags)
    )
    compiler_cmd.extend(
        [
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
            ]
            + extra_link_inputs
            + [
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


def compile_rust(program: str, output: str, extern_crates=None) -> None:
    # ``extern_crates`` names crates prebuilt as rlibs in the ``rpds-libs``
    # directory (RPDS_LIBS in the Nix shell, hashed cargo deps/ layout);
    # each becomes an ``--extern`` and the directory a ``-L dependency=``
    # so transitive rlibs resolve too.
    extern_flags = []
    if extern_crates:
        libdir = CONFIG.get("rpds-libs")
        if not libdir:
            raise RuntimeError(
                "rust extern-crate benchmarks need prebuilt rlibs; set "
                "RPDS_LIBS (exported by the Nix dev shell) or rpds-libs "
                "in config.json"
            )
        extern_flags = ["-L", f"dependency={libdir}"]
        for crate in extern_crates:
            matches = sorted(glob.glob(os.path.join(libdir, f"lib{crate}-*.rlib")))
            if not matches:
                raise RuntimeError(f"no rlib for crate {crate!r} in {libdir}")
            extern_flags += ["--extern", f"{crate}={matches[-1]}"]
    _run_quiet(
        [
            CONFIG["rustc"],
            "-C",
            "opt-level=3",
        ]
        + extern_flags
        + [
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
