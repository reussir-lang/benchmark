import argparse
import json
import os
import sys

from benches import BENCHES
from runner import run_benchmark
from tqdm import tqdm


def parse_args():
    all_variants = sorted(
        {variant for bench in BENCHES.values() for variant in bench.keys()}
    )

    parser = argparse.ArgumentParser(description="Compile and run benchmark(s).")
    parser.add_argument(
        "--bench",
        choices=sorted(BENCHES.keys()),
        help="Benchmark name. If omitted, run all benchmarks.",
    )
    parser.add_argument(
        "--variant",
        choices=all_variants,
        help="Language variant. If omitted, run all variants.",
    )
    parser.add_argument(
        "--output-json",
        help="Write aggregated benchmark output to this JSON file.",
    )
    parser.add_argument(
        "--plot-dir",
        help="Directory to write plots (timing.png and peak_rss.png).",
    )
    return parser, parser.parse_args()


def resolve_targets(selected_bench, selected_variant, parser):
    benches = [selected_bench] if selected_bench else sorted(BENCHES.keys())
    targets = []
    for bench_name in benches:
        bench_variants = BENCHES[bench_name]
        variants = (
            [selected_variant]
            if selected_variant
            else sorted(bench_variants.keys())
        )
        for variant in variants:
            if variant not in bench_variants:
                parser.error(
                    f"Variant '{variant}' is not available for bench '{bench_name}'."
                )
            targets.append((bench_name, variant))
    return targets


def _safe_float(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _first_result_entry(payload):
    if not isinstance(payload, dict):
        return None
    results = payload.get("results")
    if not isinstance(results, list) or not results:
        return None
    entry = results[0]
    return entry if isinstance(entry, dict) else None


def _extract_timing_seconds(payload):
    entry = _first_result_entry(payload)
    if entry is None:
        return None
    return _safe_float(entry.get("mean"))


def _extract_peak_rss_kb(payload):
    if not isinstance(payload, dict):
        return None

    for key in ("peak_rss_kb", "max_rss_kb", "peak_rss", "max_rss"):
        value = _safe_float(payload.get(key))
        if value is not None:
            return value

    entry = _first_result_entry(payload)
    if entry is None:
        return None
    for key in ("peak_rss_kb", "max_rss_kb", "peak_rss", "max_rss"):
        value = _safe_float(entry.get(key))
        if value is not None:
            return value
    return None


def _write_json(path, payload):
    output_path = os.path.abspath(path)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
        f.write("\n")


def _plot_grouped_bars(rows, value_key, ylabel, title, output_path):
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError as e:
        raise RuntimeError(
            "Plotting requested but matplotlib and numpy are required."
        ) from e

    benches = sorted({row["bench"] for row in rows})
    variants = sorted({row["variant"] for row in rows})
    values = {
        (row["bench"], row["variant"]): row[value_key]
        for row in rows
        if row.get(value_key) is not None
    }
    if not values:
        return False

    plt.style.use("ggplot")

    x = np.arange(len(benches))
    width = 0.8 / max(len(variants), 1)
    fig_width = max(9, len(benches) * 1.6)
    fig, ax = plt.subplots(figsize=(fig_width, 5.5))
    palette = plt.get_cmap("tab10")

    plotted_any = False
    for idx, variant in enumerate(variants):
        series = []
        for bench in benches:
            value = values.get((bench, variant))
            series.append(np.nan if value is None else value)
        if np.isnan(np.asarray(series, dtype=float)).all():
            continue
        offset = x - 0.4 + (idx + 0.5) * width
        ax.bar(
            offset,
            series,
            width=width * 0.95,
            label=variant,
            color=palette(idx % 10),
            edgecolor="white",
            linewidth=0.8,
        )
        plotted_any = True

    if not plotted_any:
        plt.close(fig)
        return False

    ax.set_title(title, fontsize=13, pad=10)
    ax.set_xlabel("Benchmark category")
    ax.set_ylabel(ylabel)
    ax.set_xticks(x)
    ax.set_xticklabels(benches, rotation=20, ha="right")
    ax.grid(axis="y", linestyle="--", alpha=0.45)
    ax.grid(axis="x", visible=False)
    ax.legend(title="Language", ncols=min(4, len(variants)), frameon=True)
    fig.tight_layout()
    fig.savefig(output_path, dpi=180)
    plt.close(fig)
    return True


def plot_results(results, plot_dir):
    rows = []
    for bench, bench_results in sorted(results.items()):
        if not isinstance(bench_results, dict):
            continue
        for variant, payload in sorted(bench_results.items()):
            timing_seconds = _extract_timing_seconds(payload)
            peak_rss_kb = _extract_peak_rss_kb(payload)
            rows.append(
                {
                    "bench": bench,
                    "variant": variant,
                    "timing_seconds": timing_seconds,
                    "peak_rss_mib": (
                        peak_rss_kb / 1024.0 if peak_rss_kb is not None else None
                    ),
                }
            )

    os.makedirs(plot_dir, exist_ok=True)
    timing_path = os.path.join(plot_dir, "timing.png")
    peak_rss_path = os.path.join(plot_dir, "peak_rss.png")

    created = []
    if _plot_grouped_bars(
        rows,
        "timing_seconds",
        "Mean runtime (s)",
        "Benchmark Runtime by Category and Language",
        timing_path,
    ):
        created.append(timing_path)

    if _plot_grouped_bars(
        rows,
        "peak_rss_mib",
        "Peak RSS (MiB)",
        "Benchmark Peak RSS by Category and Language",
        peak_rss_path,
    ):
        created.append(peak_rss_path)

    return created


def main():
    parser, args = parse_args()

    targets = resolve_targets(args.bench, args.variant, parser)
    results = {}
    progress = tqdm(targets, desc="Benchmarking", unit="target")
    for bench_name, variant in progress:
        progress.set_postfix_str(f"{bench_name}/{variant}")
        results.setdefault(bench_name, {})
        results[bench_name][variant] = run_benchmark(bench_name, variant)

    print(json.dumps(results, indent=2))

    if args.output_json:
        _write_json(args.output_json, results)

    if args.plot_dir:
        try:
            generated_plots = plot_results(results, args.plot_dir)
        except RuntimeError as e:
            parser.error(str(e))
        if not generated_plots:
            print(
                "No plottable data found for timing/peak RSS.",
                file=sys.stderr,
            )
        else:
            print(
                "Generated plots:\n" + "\n".join(generated_plots),
                file=sys.stderr,
            )


if __name__ == "__main__":
    main()
