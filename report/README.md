# Completed default benchmark suite

Both hosts completed the original default suite and environment retries on November 1, 2026. Raytracer results from merged PR #9 were added on November 2 using the same compiler environments and measurement CPUs. All original measurements are retained; errors and unavailable measurements remain explicit.

Category summaries and plot galleries classify `heap-functional` as functional data structures. This reporting migration preserves all measurements and benchmark source versions.

| Host | Cases | Timing | Footprint | Budget limited | Single sample | Errors |
| --- | --- | --- | --- | --- | --- | --- |
| workstation | 279 | 278 | 278 | 5 | 2 | 0 |
| spark | 279 | 278 | 278 | 6 | 2 | 0 |

[Combined CSV](comparison.csv) · [Paired ratios](relative-to-reussir.csv) · [Errors](errors.csv)

[workstation: full table](workstation/comparison.html) · [Markdown](workstation/comparison.md) · [CSV](workstation/comparison.csv)

[workstation: all runtime and peak-memory plots](workstation/plots/index.html). X marks takes too long (no completed measurement within five minutes); * marks measurements with fewer samples due to the time budget.

[workstation: categorized means and medians](workstation/category-summary.md) · [Category CSV](workstation/category-summary.csv)

[spark: full table](spark/comparison.html) · [Markdown](spark/comparison.md) · [CSV](spark/comparison.csv)

[spark: all runtime and peak-memory plots](spark/plots/index.html). X marks takes too long (no completed measurement within five minutes); * marks measurements with fewer samples due to the time budget.

[spark: categorized means and medians](spark/category-summary.md) · [Category CSV](spark/category-summary.csv)

Ratios use only complete non-budget-limited pairs against ordinary Reussir on the same host. Time and memory above 1 mean slower and more resident memory, respectively. Budget-limited measurements remain visible in the full tables.
