import argparse
import json

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


if __name__ == "__main__":
    main()
