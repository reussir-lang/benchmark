import argparse
import json
import os
import sys

from benches import BENCHES, SETS
from runner import run_benchmark
from terminal_dashboard import LiveBenchmarkDashboard
from tqdm import tqdm


def parse_args():
    all_variants = sorted(
        {variant for bench in BENCHES.values() for variant in bench["sources"]}
    )

    parser = argparse.ArgumentParser(description="Compile and run benchmark(s).")
    parser.add_argument(
        "--bench",
        choices=sorted(BENCHES.keys()),
        help="Benchmark name. If omitted, run all benchmarks.",
    )
    parser.add_argument(
        "--set",
        dest="bench_set",
        choices=sorted(SETS.keys()),
        help="Benchmark set. If omitted, run all sets.",
    )
    parser.add_argument(
        "--variant",
        choices=all_variants,
        help="Language variant. If omitted, run all variants.",
    )
    parser.add_argument(
        "--input-json",
        help="Read aggregated benchmark output from this JSON file instead of running benchmarks.",
    )
    parser.add_argument(
        "--output-json",
        help="Write aggregated benchmark output to this JSON file.",
    )
    parser.add_argument(
        "--plot-dir",
        help=(
            "Directory to write plots "
            "(timing.png, peak_rss.png, and speedup_over_rust.png)."
        ),
    )
    tui_group = parser.add_mutually_exclusive_group()
    tui_group.add_argument(
        "--tui",
        dest="tui",
        action="store_true",
        help="Force the live terminal dashboard (normally enabled on a TTY).",
    )
    tui_group.add_argument(
        "--no-tui",
        dest="tui",
        action="store_false",
        help="Disable the live terminal dashboard and use a progress line.",
    )
    parser.set_defaults(tui=None)
    return parser, parser.parse_args()


def resolve_targets(selected_bench, selected_variant, selected_set, parser):
    benches = [selected_bench] if selected_bench else sorted(BENCHES.keys())
    if selected_set:
        benches = [b for b in benches if BENCHES[b]["set"] == selected_set]
        if not benches:
            parser.error(f"No benchmarks selected in set '{selected_set}'.")
    targets = []
    for bench_name in benches:
        bench_sources = BENCHES[bench_name]["sources"]
        variants = (
            [selected_variant]
            if selected_variant
            else sorted(bench_sources.keys())
        )
        for variant in variants:
            if variant not in bench_sources:
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


def _read_json(path):
    input_path = os.path.abspath(path)
    with open(input_path, "r", encoding="utf-8") as f:
        payload = json.load(f)
    if not isinstance(payload, dict):
        raise RuntimeError(
            f"Expected top-level object in benchmark JSON: {input_path}"
        )
    return payload


def _select_results(results, selected_bench, selected_variant, parser):
    bench_names = [selected_bench] if selected_bench else sorted(results.keys())
    filtered = {}

    for bench_name in bench_names:
        bench_results = results.get(bench_name)
        if not isinstance(bench_results, dict):
            parser.error(f"Benchmark '{bench_name}' was not found in the input data.")
        variants = (
            [selected_variant]
            if selected_variant
            else sorted(bench_results.keys())
        )
        for variant in variants:
            if variant not in bench_results:
                parser.error(
                    f"Variant '{variant}' is not available for bench '{bench_name}'."
                )
            filtered.setdefault(bench_name, {})
            filtered[bench_name][variant] = bench_results[variant]

    return filtered


def _plot_grouped_bars(
    rows,
    value_key,
    ylabel,
    title,
    output_path,
    reference_line=None,
    yscale=None,
):
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
    ax.set_xlabel("Benchmark")
    ax.set_ylabel(ylabel)
    ax.set_xticks(x)
    ax.set_xticklabels(benches, rotation=20, ha="right")
    if yscale is not None:
        ax.set_yscale(yscale)
    ax.grid(axis="y", linestyle="--", alpha=0.45)
    ax.grid(axis="x", visible=False)
    if reference_line is not None:
        ax.axhline(
            reference_line,
            color="black",
            linestyle=":",
            linewidth=1.0,
            alpha=0.75,
        )
    ax.legend(title="Variant", ncols=min(4, len(variants)), frameon=True)
    fig.tight_layout()
    fig.savefig(output_path, dpi=180)
    plt.close(fig)
    return True


def plot_results(results, plot_dir):
    """Summarize the results as one SVG per benchmark set.

    Each plot is a grouped bar chart of mean runtime (log scale) with one
    bar group per benchmark and one bar per language variant.
    """
    rows_by_set = {}
    for bench, bench_results in sorted(results.items()):
        if not isinstance(bench_results, dict):
            continue
        bench_meta = BENCHES.get(bench)
        bench_set = bench_meta["set"] if bench_meta else "unknown"
        for variant, payload in sorted(bench_results.items()):
            timing_seconds = _extract_timing_seconds(payload)
            rows_by_set.setdefault(bench_set, []).append(
                {
                    "bench": bench,
                    "variant": variant,
                    "timing_seconds": timing_seconds,
                }
            )

    os.makedirs(plot_dir, exist_ok=True)
    created = []
    for bench_set, rows in sorted(rows_by_set.items()):
        title = SETS.get(bench_set, bench_set)
        output_path = os.path.join(plot_dir, f"{bench_set}.svg")
        if _plot_grouped_bars(
            rows,
            "timing_seconds",
            "Mean runtime (s, log scale)",
            f"{title} — mean runtime by benchmark and variant",
            output_path,
            yscale="log",
        ):
            created.append(output_path)
    return created


def run_targets(targets, tui_choice=None):
    """Run targets with either the live dashboard or the legacy progress bar."""

    results = {}
    dashboard = LiveBenchmarkDashboard(enabled=tui_choice)
    if not dashboard.enabled:
        progress = tqdm(targets, desc="Benchmarking", unit="target")
        for bench_name, variant in progress:
            progress.set_postfix_str(f"{bench_name}/{variant}")
            results.setdefault(bench_name, {})
            results[bench_name][variant] = run_benchmark(bench_name, variant)
        return results

    bench_totals = {
        bench_name: sum(1 for candidate, _ in targets if candidate == bench_name)
        for bench_name, _ in targets
    }
    with dashboard:
        for index, (bench_name, variant) in enumerate(targets):
            frame = {
                "results": results,
                "current_bench": bench_name,
                "current_variant": variant,
                "total": len(targets),
                "bench_total": bench_totals[bench_name],
            }
            dashboard.update(
                **frame,
                completed=index,
                status="Running",
            )
            results.setdefault(bench_name, {})
            results[bench_name][variant] = run_benchmark(bench_name, variant)
            dashboard.update(
                **frame,
                completed=index + 1,
                status="Completed",
            )
    return results


def main():
    parser, args = parse_args()

    if args.input_json:
        results = _select_results(
            _read_json(args.input_json), args.bench, args.variant, parser
        )
    else:
        targets = resolve_targets(args.bench, args.variant, args.bench_set, parser)
        results = run_targets(targets, args.tui)

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
                "No plottable data found for timing/peak RSS/speedup.",
                file=sys.stderr,
            )
        else:
            print(
                "Generated plots:\n" + "\n".join(generated_plots),
                file=sys.stderr,
            )


if __name__ == "__main__":
    main()
