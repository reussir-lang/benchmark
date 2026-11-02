# Workstation and Spark benchmark report

The `ocaml` configuration now uses OxCaml (OCaml 5.4 based, Flambda 2, `-O3`). Lean and Rust use native CPU targeting and ThinLTO. All 124 affected cells on each host were refreshed; all 164 other result and status records per host are unchanged.

| Host | Cells | Timing | Peak RSS | Errors |
| --- | --- | --- | --- | --- |
| workstation | 288 | 287 | 287 | 0 |
| spark | 288 | 287 | 287 | 0 |

[Combined CSV](comparison.csv) · [Toolchain before/after](toolchain-change.csv) · [Paired ratios](relative-to-reussir.csv) · [Errors](errors.csv)

| Host | Toolchain | Complete pairs | Geomean speedup |
| --- | --- | --- | --- |
| workstation | OxCaml | 26 | 1.083× |
| workstation | lean | 27 | 1.112× |
| workstation | rust | 68 | 1.022× |
| spark | OxCaml | 26 | 1.004× |
| spark | lean | 27 | 1.056× |
| spark | rust | 67 | 1.002× |

Speedup is previous runtime / refreshed runtime, geometrically averaged over pairs with completed, non-budget-limited timings. Above 1 means faster. Rust combines its registered allocator and persistent-collection variants; each cell has equal weight. See [summary CSV](toolchain-summary.csv) and [per-cell changes](toolchain-change.csv).

[workstation: full table](workstation/comparison.md) · [CSV](workstation/comparison.csv) · [Plots](workstation/plots/index.html) · [Categories](workstation/category-summary.md)

[spark: full table](spark/comparison.md) · [CSV](spark/comparison.csv) · [Plots](spark/plots/index.html) · [Categories](spark/category-summary.md)

Measurements run sequentially on CPU 1 on workstation and CPU 19 on Spark, requesting five warmups and ten timing samples within the existing five-minute case budget. Budget-limited or exhausted cells remain explicit. Peak RSS comes from one GNU time run. OxCaml is pinned at `dc1bd3914b0bae35f9cb227d113db620722a5d41`; each host’s `provenance/native-toolchains-manifest.json` records exact package paths, versions, sources, flags and measurement settings. Reussir remains at `36f05142f3b33f442f69afa421a10b7a39ee21f9`; its measurements and all Haskell, Koka and Morphic measurements are unchanged. Historical [Reussir before/after](reussir-change.csv) describes the preceding refresh, not this toolchain change.
