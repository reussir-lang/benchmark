# Benchmark comparison

Current runtime and memory comparisons across the registered language configurations on workstation and Spark.

| Host | Configurations | Timed | Peak RSS | Errors |
| --- | --- | --- | --- | --- |
| workstation | 288 | 287 | 287 | 0 |
| spark | 288 | 287 | 287 | 0 |

[Combined results](comparison.csv) · [Ratios to Reussir](relative-to-reussir.csv) · [Errors](errors.csv)

| Host | Results | Categories | Plots |
| --- | --- | --- | --- |
| workstation | [Table](workstation/comparison.md) · [CSV](workstation/comparison.csv) | [Category summary](workstation/category-summary.md) | [Runtime and memory](workstation/plots/index.html) |
| spark | [Table](spark/comparison.md) · [CSV](spark/comparison.csv) | [Category summary](spark/category-summary.md) | [Runtime and memory](spark/plots/index.html) |

Measurements run sequentially on CPU 1 on workstation and CPU 19 on Spark, requesting five warmups and ten timing samples within a five-minute case budget. Peak RSS comes from a GNU time run. Budget-limited and exhausted cases are marked explicitly; plots show runtime standard deviations, not confidence intervals.

Ratios compare configurations on the same host against default Reussir. Values above 1 mean slower runtime or higher memory use. Geometric means exclude incomplete and budget-limited pairs, with coverage reported separately.

The `ocaml` configuration uses OxCaml (Flambda 2). Exact compiler versions, source hashes, build settings, and per-configuration measurement provenance are recorded in the [workstation manifest](../workstation/results/manifest.json) and [Spark manifest](../spark/results/manifest.json).
