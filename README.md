# Benchmark data

Measurements from the AMD Ryzen 9 9950X workstation (`x86_64`) and NVIDIA GB10 Spark (`aarch64`). Data and rendered reports live directly at the root. Source and harness code belong on `main`.

The latest refresh replaces all 124 OCaml/OxCaml, Lean and Rust cells per host in the existing JSON. OCaml uses pinned OxCaml (Flambda 2) with `-O3`; Lean and Rust use native CPU targeting and ThinLTO. Findlib and Zarith are rebuilt with OxCaml; Lean's runtime and standard library are rebuilt with ThinLTO; Rust's external crates retain bitcode. All 164 other result and status records per host are unchanged.

Each host has 288 cells across 28 workloads, including all nine MLTT configurations. `heap-functional` belongs to functional data structures. Raytracer and MLTT measurements are in the canonical JSON alongside the rest of the suite.

- [Report and plots](report/README.md)
- [Toolchain before/after](report/toolchain-change.csv)
- [Combined CSV](report/comparison.csv)
- [Workstation results](workstation/results/results.json) and [provenance](workstation/results/manifest.json)
- [Spark results](spark/results/results.json) and [provenance](spark/results/manifest.json)

Each combined manifest maps cells to their batch manifest through `cell_provenance`. `native-toolchains-manifest.json` records the latest toolchain refresh. Existing baseline, raytracer, Reussir and MLTT manifests retain the provenance of unchanged cells. Raw samples and statuses live in `results.json` and `status.json`.
