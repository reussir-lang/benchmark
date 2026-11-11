# Benchmark data

Current benchmark measurements and cross-language comparisons for the AMD Ryzen 9 9950X workstation (`x86_64`) and NVIDIA GB10 Spark (`aarch64`). Each host has 306 configurations across 30 workloads. Benchmark sources and the harness are maintained on `main`; the new regular-array sources are frozen at `f8365f183f2459d25a8cc3aa76a8b93a34206e31` in [benchmark PR #15](https://github.com/reussir-lang/benchmark/pull/15).

- [Comparison report and plots](report/README.md)
- [Combined results table](report/comparison.csv)
- [Workstation measurements](workstation/results/results.json) and [provenance](workstation/results/manifest.json)
- [Spark measurements](spark/results/results.json) and [provenance](spark/results/manifest.json)

Each host's `results.json` contains raw samples and peak RSS; `status.json` records completion and time-budget outcomes. The combined manifest's `cell_provenance` maps each configuration to its measurement manifest, including compiler versions, source hashes, build settings, and measurement parameters.

The array-heap refresh applies the recorded [source patch](workstation/results/heap-child-index-source.patch) to benchmark revision `26b4446e03823f822f96650207ced834888cfb2c`. Both hosts use that same patch; the per-host `heap-child-index-manifest.json` files record the refreshed configurations and their five-warmup, ten-sample measurements. Other configurations retain their existing provenance.

The regular-array refresh adds `rgba-composite` and `pcm-mix-limit` in seven languages (nine runtime configurations), requesting five warmups and ten timed runs per configuration on each host within the existing five-minute budget. Exact source revisions and toolchains are recorded in each host's `regular-arrays-manifest.json`.

The 30 Spark `reussir` configurations were refreshed with merged compiler `c55dc218bacaa2cfda9574c3b2eaee1e237b6010` and its runtime, preserving native ThinLTO settings, CPU 19 affinity, five warmups, and ten samples. Sources are benchmark revision `1cf406dffa22b8bfc65eeb30241e8154f27a5505`. Other Spark configurations and all workstation measurements retain their prior samples. See [refresh provenance](spark/results/reussir-980-manifest.json).

This refresh includes the inline-variant TBI fix in [Reussir PR #981](https://github.com/reussir-lang/reussir/pull/981). [Diagnostic samples](spark/results/reussir-981-diagnostic.json) isolate the stack-growth regression introduced in PR #980 and confirm recovery with the fix.

The [Spark refresh report](report/spark-refresh-20261111.html) includes all 30 updated Reussir workloads and the [18 paper Lean2rr measurements](spark/lean2rr-980/manifest.json), with PRs #980 and #981 backported onto the existing paper stack. Native Lean timings remain the prior baseline. Seventeen extracted workloads completed ten samples; the heavily shared hash-map case completed two within the five-minute budget. The report records the remaining 20.21% extracted `life` slowdown and its back-to-back diagnostic.
