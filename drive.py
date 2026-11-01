import json, sys
from benches import BENCHES
from runner import run_benchmark
results = {}
for bench in BENCHES:
    for variant in ["koka", "reussir"]:
        key = f"{bench}/{variant}"
        try:
            r = run_benchmark(bench, variant)
            if not r["results"]:
                results[key] = {"budget_limited": True, "sample_count": 0}
                print(f"{key:28s} no sample completed within the budget", flush=True)
                continue
            res = r["results"][0]
            results[key] = {"mean_ms": res["mean"]*1e3, "stddev_ms": None if res["stddev"] is None else res["stddev"]*1e3,
                            "min_ms": res["min"]*1e3, "peak_rss_mb": r.get("peak_rss_kb",0)/1024.0}
            stddev = results[key]["stddev_ms"]
            stddev_text = "n/a" if stddev is None else f"{stddev:.1f}"
            print(f'{key:28s} {results[key]["mean_ms"]:9.1f} ms ± {stddev_text:>6}  min {results[key]["min_ms"]:9.1f}  RSS {results[key]["peak_rss_mb"]:8.1f} MB', flush=True)
        except Exception as e:
            results[key] = {"error": str(e)}
            print(f"{key:28s} ERROR: {e}", flush=True)
with open(sys.argv[1] if len(sys.argv)>1 else "results.json","w") as f:
    json.dump(results, f, indent=2)
print("done", flush=True)
