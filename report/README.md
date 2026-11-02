# Workstation and Spark benchmark report

All 28 Reussir workloads were remeasured in both default and NRAC configurations on each host. Seven missing other-language MLTT configurations were measured on each host, completing all nine registered MLTT configurations. All 225 previously recorded other-language cells per host are unchanged.

| Host | Cells | Timing | Peak RSS | Errors |
| --- | --- | --- | --- | --- |
| workstation | 288 | 287 | 287 | 0 |
| spark | 288 | 287 | 287 | 0 |

[Combined CSV](comparison.csv) · [Reussir before/after](reussir-change.csv) · [Paired ratios](relative-to-reussir.csv) · [Errors](errors.csv)

[workstation: full table](workstation/comparison.md) · [CSV](workstation/comparison.csv) · [Plots](workstation/plots/index.html) · [Categories](workstation/category-summary.md)

[spark: full table](spark/comparison.md) · [CSV](spark/comparison.csv) · [Plots](spark/plots/index.html) · [Categories](spark/category-summary.md)

Ratios compare measurements on the same host. Reussir uses merged compiler revision `36f05142f3b33f442f69afa421a10b7a39ee21f9`; other languages retain their original toolchains. Only their missing MLTT cells were measured; existing results are unchanged. Before/after changes compare against the previous primary dataset, compiler `bcfff8d419169a09509b963714de0675630c7bc1`, and include all intervening compiler and library changes. Missing and failed measurements remain explicit.
