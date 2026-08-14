import os
import json

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(SCRIPT_DIR, "config.json")

with open(CONFIG_PATH, "r") as f:
    CONFIG = json.load(f)


_ENVIRONMENT_OVERRIDES = {
    "reussir-compiler": "REUSSIR_COMPILER",
    "reussir-libs": "REUSSIR_LIBS",
    "reussir-src": "REUSSIR_SRC",
    "cc": "BENCHMARK_CC",
    "koka-compiler": "BENCHMARK_KOKA",
    "lean-compiler": "BENCHMARK_LEAN",
    "leanc": "BENCHMARK_LEANC",
    "rustc": "BENCHMARK_RUSTC",
    "rpds-libs": "RPDS_LIBS",
    "ghc": "BENCHMARK_GHC",
    "ocamlopt": "BENCHMARK_OCAMLOPT",
    "hyperfine": "BENCHMARK_HYPERFINE",
    "time": "BENCHMARK_TIME",
}

for config_key, environment_key in _ENVIRONMENT_OVERRIDES.items():
    value = os.environ.get(environment_key)
    if value:
        CONFIG[config_key] = value

# Runtime environment entries may refer to store paths exported by the Nix
# shell, for example ``LD_PRELOAD=$MIMALLOC_LIB``.
for key, value in list(CONFIG.items()):
    if isinstance(value, list):
        CONFIG[key] = [os.path.expandvars(item) for item in value]
