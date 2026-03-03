import os
import json
import subprocess
import tempfile
import shutil

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(SCRIPT_DIR, "config.json")

with open(CONFIG_PATH, "r") as f:
    CONFIG = json.load(f)

def compile_reussir(program: str, driver: str, output: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        subprocess.run([
            CONFIG["reussir-compiler"],
            "-o", "reussir.ll",
            "-Oaggressive",
            "--reuse-across-call",
            "--relocation-mode", "pic",
            "-t", "llvm-ir",
            program
        ], check=True, cwd=tmpdir)
        subprocess.run([
            CONFIG["cc"],
            "-o", output,
            "reussir.ll",
            driver,
            "-flto",
            "-O3",
            "-L", CONFIG["reussir-libs"],
            "-lreussir_rt",
            f"-Wl,-rpath={CONFIG['reussir-libs']}",
        ], check=True, cwd=tmpdir)

def compile_koka(program: str, output: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        subprocess.run([
            CONFIG["koka-compiler"],
            "-O3",
            program,
            "-o", 
            output,
        ], check=True, cwd=tmpdir)

def compile_lean(program: str, output: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        # copy program to tmpdir
        shutil.copyfile(program, os.path.join(tmpdir, os.path.basename(program)))
        subprocess.run([
            CONFIG["lean-compiler"],
            os.path.join(tmpdir, os.path.basename(program)),
            "-c", 
            f"{output}.c",
        ], check=True, cwd=tmpdir)
        subprocess.run([
            CONFIG["leanc"],
            "-o", output,
            f"{output}.c",
            "-flto",
            "-O3",
        ], check=True, cwd=tmpdir)