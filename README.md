# Reussir benchmark suite

Cross-language benchmarks comparing Reussir against Lean, Koka, Rust, and
Haskell, organized as two sets:

| Set | Benchmarks | What it exercises |
|---|---|---|
| `functional-data-structures` | rbtree, rbtree-zipper, nbe-hoas, nbe-closure, derive | allocation, pattern matching, and reuse/GC of linked structures |
| `large-aggregates` | life, qsort, heap | flat arrays: bulk memory, in-place update under persistence (COW / uniqueness), bounds handling |

Workloads are sized so the Reussir variant runs ≈1 s per benchmark. Every
program hard-codes its workload, **verifies its own result**, and exits
non-zero on a mismatch; the checksums are chosen to be representation
independent (e.g. the heap checksum only depends on heap *contents*, so
tree-based and array-based implementations must agree).

## Benchmarks

- **rbtree / rbtree-zipper** — insert 10M keys into a red-black tree
  (recursive balance vs. zipper-based), count the `true` values.
- **nbe-hoas / nbe-closure** — normalization by evaluation of a 4M-redex
  Church-numeral term (HOAS closures vs. defunctionalized env), repeated
  6/7 times with a per-round seed so no compiler can share rounds.
- **derive** — symbolic derivative of `x^x` nested 10 deep, 3 rounds.
- **life** — Conway's Game of Life, toroidal 64×64, 200k generations.
  Functional per-generation rebuild (tabulate / `vector-init` / `ofFn` /
  `listArray`), mutation double-buffer for the baselines.
- **qsort** — 400 rounds of in-place Lomuto quicksort over a fresh
  `[i64; 65536]` MINSTD-filled array. Persistent-array languages rely on
  uniqueness/COW for in-place sets; languages without arrays (Koka 3.2.2,
  pure Haskell) use the idiomatic list quicksort — noted in the sources.
- **heap** — binary min-heap maintenance: 65535 values from an
  approximately Gaussian stream (Irwin–Hall, sum of 12 MINSTD draws), then
  26M rounds of unconditional replace-top (evict min, insert draw, sift
  down). Array-backed where possible, Braun-tree heap for Koka and pure
  Haskell.

## Variants and toolchain configurations

| Variant | Configuration |
|---|---|
| `reussir` | `rrc -Oaggressive --reuse-across-call` → clang `-flto=thin -O3 -march=native`, static thin-LTO runtime (`reussir-libs`) |
| `reussir-nrac` | same without `--reuse-across-call` |
| `reussir-dia` | same with `--disable-invariant-analysis` (not in the default matrix) |
| `koka` | `-O3`, clang thin-LTO + `-march=native` via `--ccopts`/`--cclinkopts` |
| `lean` | `lean -c` → `leanc -flto -O3` |
| `rust` | `rustc -C opt-level=3` |
| `rust-with-mimalloc` | same binary, `LD_PRELOAD` mimalloc |
| `haskell` | `ghc -O2 -rtsopts`, default RTS (purely functional sources) |
| `haskell-a1g` | same sources, `-with-rtsopts=-A1G` (1 GiB nursery) |
| `haskell-st` / `haskell-st-a1g` | mutable `Data.Array.ST` sources, both RTS configs (large-aggregates set only) |

Both Haskell RTS configurations are first-class variants because the
default-vs-1 GiB-nursery choice swings results dramatically in both
directions: churn-heavy symbolic benchmarks (derive, nbe) run up to ~2.9×
faster with `-A1G` (zero minor GCs), while large-live-set benchmarks
(rbtree) run ~40% slower (cold-nursery cache effects).

Known toolchain quirks, encoded in the sources:

- Koka 3.2.2's `-O3` specializer diverges on a recursive call whose argument
  builds a closure (`vector-init` in life) — `noinline` on the offender is
  the workaround, commented in `koka/life.kk`.
- Koka emits binaries without the executable bit; `compile.py` fixes it up.

## Running

```bash
python3 main.py                                   # full matrix, JSON to stdout
python3 main.py --set large-aggregates            # one set
python3 main.py --bench heap --variant reussir    # one cell
python3 main.py --output-json out/results.json --plot-dir out/
python3 main.py --input-json out/results.json --plot-dir out/  # replot only
```

`--plot-dir` writes one SVG per set (`functional-data-structures.svg`,
`large-aggregates.svg`): grouped bars of mean runtime, log scale, one bar
group per benchmark, one bar per variant. Timing uses hyperfine
(`warmup-runs`/`runs` in `config.json`); peak RSS is sampled with
`/usr/bin/time -f %M`.

Toolchain paths live in `config.json` (`reussir-compiler`, `cc`,
`reussir-libs`, `koka-compiler`, `lean-compiler`/`leanc`, `rustc`, `ghc`,
`hyperfine`).

## Extending

See the module docstring in `benches.py`: a new benchmark is one `BENCHES`
entry plus per-language sources that self-verify; a new language or
configuration is one `VARIANTS` entry (`kind` picks the toolchain in
`runner.py`, remaining keys are compile options).
