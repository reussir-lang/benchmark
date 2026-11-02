# Default benchmark data

Measurements from the AMD Ryzen 9 9950X workstation (`x86_64`) and NVIDIA GB10 Spark (`aarch64`). Each host has 279 benchmark/variant cells, including nine raytracer configurations added from [benchmark PR #9](https://github.com/reussir-lang/benchmark/pull/9).

The original 270 cells per host were measured on November 1, 2026, at benchmark revision `959c9ac4e1e956c8b7acff44f6298b6d52d46c15`. Raytracer alone was measured on November 2 at merged revision `2e1ec4fe82558112529c872733d3162a6e887e05` and added to the existing data. All original result and status entries are preserved.

Reporting groups `heap-functional` under `functional-data-structures`, as recorded in [reporting-categories.json](reporting-categories.json). Category summaries and plot galleries use this classification. The benchmark sources, run registry and recorded measurements retain their original versions.

Both batches use Reussir revision `bcfff8d419169a09509b963714de0675630c7bc1`, the same native compiler and runtime archives, and each host's original toolchain configuration. Measurements run sequentially on CPU 1 on the workstation and CPU 19 on Spark. Raytracer completed all five warmups and ten timing samples per configuration, including checksum validation on every execution. Peak RSS is collected separately by GNU time; file output is excluded.

- [Combined report and plots](report/README.md)
- [Combined measurements as CSV](report/comparison.csv)
- [Workstation raw results](workstation/results/results.json) and [manifest](workstation/results/manifest.json)
- [Spark raw results](spark/results/results.json) and [manifest](spark/results/manifest.json)

Each host's `results/baseline-manifest.json` preserves the original manifest. `results/manifest.json` describes the combined target list and links to `results/raytracer-manifest.json` for the added batch. `raytracer/` retains that batch's raw results, status, manifest, log and exit status. The original logs and environment retry records are retained; historical error logs describe earlier attempts, while `results/status.json` records the final outcomes.

This branch contains saved data and rendered reports only. Compiler and runtime hashes, per-source hashes, timing samples, budget limits and explicit unavailable measurements are retained in the JSON data. Morphic has no registered raytracer implementation; it is absent from that case's nine configurations.
