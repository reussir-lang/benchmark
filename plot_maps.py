"""Stacked-bar plots for the std-collections map benchmarks.

Two figures, one per map structure. Each language variant gets a single
horizontal bar whose segments stack the mean runtime of that structure's
configurations, so the bar length is the total time across the retention
tiers and the segments show where it goes:

- ordered:   ordered-map-linear + ordered-map-shared + ordered-map-heavily-shared
- unordered: hash-map-linear + hash-map-shared + hash-map-heavily-shared

The time axis is logarithmic, so segment boundaries sit at true
cumulative times but segment lengths are log-compressed.

Feed it one or more aggregated results JSONs produced by
``main.py --output-json`` (later files override earlier ones per
benchmark/variant cell, so a full-set run can be combined with a
later single-bench run):

    python3 plot_maps.py results.json dense.json --plot-dir plots

Writes ``ordered-map-stacked.<fmt>`` and ``hash-map-stacked.<fmt>``.
"""

import argparse
import json
import os

# Configuration segments per figure, in stack order (fixed hue order:
# the palette follows the configuration, never the bar).
FIGURES = {
    "ordered-map-stacked": {
        "title": "Ordered map — mean runtime by variant, stacked across configurations",
        "segments": [
            ("ordered-map-linear", "linear"),
            ("ordered-map-shared", "shared"),
            ("ordered-map-heavily-shared", "heavily shared"),
        ],
    },
    "hash-map-stacked": {
        "title": "Hash map — mean runtime by variant, stacked across configurations",
        "segments": [
            ("hash-map-linear", "linear"),
            ("hash-map-shared", "shared"),
            ("hash-map-heavily-shared", "heavily shared"),
        ],
    },
}

# Categorical slots 1-3 of the validated reference palette (light mode):
# adjacent CVD dE >= 8 and normal-vision dE >= 15 pass; the magenta slot
# sits under 3:1 contrast on the surface, so the bars carry direct value
# labels (relief rule) rather than relying on fill alone.
SEGMENT_COLORS = ["#2a78d6", "#008300", "#e87ba4"]
SURFACE = "#fcfcfb"
TEXT_PRIMARY = "#0b0b0b"
TEXT_SECONDARY = "#52514e"


def _mean_seconds(payload):
    try:
        return float(payload["results"][0]["mean"])
    except (KeyError, IndexError, TypeError, ValueError):
        return None


def load_results(paths):
    merged = {}
    for path in paths:
        with open(path) as f:
            data = json.load(f)
        for bench, variants in data.items():
            if not isinstance(variants, dict):
                continue
            merged.setdefault(bench, {}).update(variants)
    return merged


def _format_seconds(value):
    return f"{value:.2f} s" if value < 10 else f"{value:.1f} s"


def plot_stacked(results, name, spec, output_path):
    import matplotlib.pyplot as plt

    benches = [bench for bench, _ in spec["segments"]]
    variants = sorted(
        {v for bench in benches for v in results.get(bench, {})}
    )
    rows = []
    for variant in variants:
        means = [
            _mean_seconds(results.get(bench, {}).get(variant))
            if variant in results.get(bench, {})
            else None
            for bench in benches
        ]
        if all(m is None for m in means):
            continue
        rows.append((variant, [m or 0.0 for m in means]))
    if not rows:
        return False

    # Fastest total at the top of the chart.
    rows.sort(key=lambda r: sum(r[1]), reverse=True)
    labels = [r[0] for r in rows]
    totals = [sum(r[1]) for r in rows]
    axis_max = max(totals)
    positive = [w for r in rows for w in r[1] if w > 0]
    axis_min = min(min(positive) * 0.6, min(totals) * 0.5)

    fig, ax = plt.subplots(figsize=(9.5, 0.52 * len(rows) + 1.9))
    fig.patch.set_facecolor(SURFACE)
    ax.set_facecolor(SURFACE)
    ax.set_xscale("log")
    ax.set_xlim(axis_min, axis_max * 1.6)

    from math import log10

    log_span = log10(axis_max * 1.6) - log10(axis_min)

    def _log_frac(lo, hi):
        return (log10(max(hi, axis_min)) - log10(max(lo, axis_min))) / log_span

    y = range(len(rows))
    left = [0.0] * len(rows)
    for seg_idx, (_, seg_label) in enumerate(spec["segments"]):
        widths = [r[1][seg_idx] for r in rows]
        ax.barh(
            y,
            widths,
            left=left,
            height=0.62,
            label=seg_label,
            color=SEGMENT_COLORS[seg_idx],
            edgecolor=SURFACE,
            linewidth=1.6,
        )
        # Direct labels on segments wide enough on the log axis to hold
        # them, placed at the segment's on-screen (geometric) midpoint.
        for row_idx, width in enumerate(widths):
            lo = left[row_idx]
            hi = lo + width
            if width > 0 and _log_frac(lo, hi) > 0.08:
                mid = (max(lo, axis_min) * hi) ** 0.5
                ax.text(
                    mid,
                    row_idx,
                    _format_seconds(width),
                    ha="center",
                    va="center",
                    fontsize=8,
                    color=SURFACE,
                )
        left = [a + b for a, b in zip(left, widths)]

    for row_idx, total in enumerate(totals):
        ax.text(
            total * 1.05,
            row_idx,
            _format_seconds(total),
            ha="left",
            va="center",
            fontsize=9,
            color=TEXT_PRIMARY,
        )

    ax.set_yticks(list(y))
    ax.set_yticklabels(labels, fontsize=9, color=TEXT_PRIMARY)
    ax.set_xlabel("Mean runtime (s, log scale)", fontsize=10, color=TEXT_SECONDARY)
    ax.set_title(spec["title"], fontsize=12, color=TEXT_PRIMARY, pad=34)
    ax.grid(axis="x", linestyle="--", linewidth=0.6, alpha=0.4)
    ax.grid(axis="y", visible=False)
    ax.tick_params(colors=TEXT_SECONDARY, labelsize=9)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.legend(
        loc="lower left",
        bbox_to_anchor=(0, 1.005),
        ncols=len(spec["segments"]),
        frameon=False,
        fontsize=9,
        handlelength=1.4,
        columnspacing=1.2,
    )
    fig.tight_layout()
    fig.savefig(output_path, dpi=180, facecolor=SURFACE)
    plt.close(fig)
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", nargs="+", help="Aggregated results JSON file(s).")
    parser.add_argument("--plot-dir", default="plots", help="Output directory.")
    parser.add_argument("--format", default="svg", choices=["svg", "png"])
    args = parser.parse_args()

    results = load_results(args.results)
    os.makedirs(args.plot_dir, exist_ok=True)
    created = []
    for name, spec in FIGURES.items():
        output_path = os.path.join(args.plot_dir, f"{name}.{args.format}")
        if plot_stacked(results, name, spec, output_path):
            created.append(output_path)
        else:
            print(f"skipped {name}: no data for its benchmarks")
    for path in created:
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
