# Benchmark data

Current benchmark measurements and cross-language comparisons for the AMD Ryzen 9 9950X workstation (`x86_64`) and NVIDIA GB10 Spark (`aarch64`). Each host has 288 configurations across 28 workloads. Benchmark sources and the harness are on `main`.

- [Comparison report and plots](report/README.md)
- [Combined results table](report/comparison.csv)
- [Workstation measurements](workstation/results/results.json) and [provenance](workstation/results/manifest.json)
- [Spark measurements](spark/results/results.json) and [provenance](spark/results/manifest.json)

Each host's `results.json` contains raw samples and peak RSS; `status.json` records completion and time-budget outcomes. The combined manifest's `cell_provenance` maps each configuration to its measurement manifest, including compiler versions, source hashes, build settings, and measurement parameters.

The array-heap refresh applies the recorded [source patch](workstation/results/heap-child-index-source.patch) to benchmark revision `26b4446e03823f822f96650207ced834888cfb2c`. Both hosts use that same patch; the per-host `heap-child-index-manifest.json` files record the refreshed configurations and their five-warmup, ten-sample measurements. Other configurations retain their existing provenance.
