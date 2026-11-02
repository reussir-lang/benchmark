# Benchmark data

Measurements from the AMD Ryzen 9 9950X workstation (`x86_64`) and NVIDIA GB10 Spark (`aarch64`). Data and rendered reports live directly at the root of this branch. Benchmark source and harness code belong on `main`.

All 28 Reussir workloads, in both `reussir` and `reussir-nrac` configurations, were rerun on November 2, 2026 using merged compiler revision `36f05142f3b33f442f69afa421a10b7a39ee21f9` (#919), including the updated standard library and ordered maps. The suite is revision `10f3826d1525903de23a92bae1d005094d838609` (benchmark PR #10). Every Reussir cell completed five warmups and ten timing samples with successful built-in result checks. Measurements run sequentially on CPU 1 on the workstation and CPU 19 on Spark, using the original per-host toolchains and runtime archive. Peak RSS is measured with GNU time.

Each host contains 288 cells: 56 updated Reussir cells, seven newly measured other-language MLTT cells, and 225 unchanged other-language cells. MLTT is part of the main suite with all nine registered configurations: Reussir, Reussir NRAC, Lean, Koka, OCaml, Rust, Rust with mimalloc, Haskell, and Haskell with a 1 GiB nursery. The new MLTT measurements use the same per-host toolchains and measurement CPU. All existing other-language data from the original November 1 suite and November 2 raytracer batch retains its result and status records unchanged.

`heap-functional` is grouped under functional data structures.

- [Report and plots](report/README.md)
- [Combined CSV](report/comparison.csv)
- [Reussir before/after](report/reussir-change.csv)
- [Workstation results](workstation/results/results.json) and [provenance](workstation/results/manifest.json)
- [Spark results](spark/results/results.json) and [provenance](spark/results/manifest.json)

Each combined manifest maps every cell to its batch manifest: `baseline-manifest.json`, `raytracer-manifest.json`, `reussir-manifest.json`, or `mltt-manifest.json`. These record compiler revisions, source hashes, configurations and runtime hashes. Raw timing samples and final statuses are retained in `results.json` and `status.json`.
