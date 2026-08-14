# Reussir benchmark suite

Cross-language benchmarks comparing Reussir against Lean, Koka, Rust,
Haskell, and OCaml, organized as two sets:

| Set | Benchmarks | What it exercises |
|---|---|---|
| `functional-data-structures` | rbtree, rbtree-zipper, nbe-hoas, nbe-closure, derive, fingertree, functional-queue | allocation, pattern matching, persistence, and reuse/GC of linked structures |
| `large-aggregates` | life, qsort, heap-array, heap-functional | flat arrays plus matched array/tree heap workloads |
| `std-collections` | ordered-map, hash-map | each language's standard ordered map and hash map under one shared insert/remove/lookup workload |

Workloads use a roughly quarter-scale work factor while retaining the data
shape each benchmark is intended to exercise. Every program hard-codes its
workload, **verifies its own result**, and exits non-zero on a mismatch; the
checksums are representation independent (e.g. the heap checksum only depends
on heap *contents*, so tree-based and array-based implementations must agree).

Logical payload types are part of each workload contract. Red-black-tree
keys and the heap, finger-tree, and queue elements are signed 64-bit integers
in every port (`i64`, `Int64`, or `int64`). Loop indices and representation
metadata may use each language's native index type, and object layouts are
intentionally left idiomatic.

## Benchmarks

- **rbtree / rbtree-zipper** — insert 2.5M keys into a red-black tree
  (recursive balance vs. zipper-based), count the `true` values.
- **nbe-hoas / nbe-closure** — normalization by evaluation of a 1M-redex
  Church-numeral term (HOAS closures vs. defunctionalized env), repeated
  6/7 times with a per-round seed so no compiler can share rounds.
- **derive** — one symbolic derivative chain of `x^x` nested 10 deep.
- **life** — Conway's Game of Life, toroidal 64×64, 50k generations.
  Functional per-generation rebuild (tabulate / `vector-init` / `ofFn` /
  `listArray`), mutation double-buffer for the baselines.
- **qsort** — 100 rounds of in-place Lomuto quicksort over a fresh
  `[i64; 65536]` MINSTD-filled array. Persistent-array languages rely on
  uniqueness/COW for in-place sets; the Koka and pure Haskell variants use
  their existing list-quicksort sources — noted in those files.
- **heap-array / heap-functional** — two separately reported representations
  of one binary min-heap algorithm and workload: a mutable array/vector and a
  purely functional Braun tree. Both build by repeated insertion, contain
  65535 signed 64-bit values from an approximately Gaussian stream
  (Irwin–Hall, sum of 12 MINSTD draws), then perform 6.5M rounds of
  unconditional replace-top (evict min, insert draw, sift down). Both use the
  same content-based checksum. Rust's functional version path-copies through
  `Rc`; it does not use `Box` or unique-owner mutation.
- **fingertree** — build 65536 elements with `snoc`, perform 1M
  `viewl`/`snoc` rotations, then drain. Haskell uses the published
  `fingertree` package; the other ports implement the same unmeasured 1–4
  digit / 2–3 node algorithm. Rust uses persistent `Rc` paths. Reussir keeps
  persistent `Digit` nodes shared for elimination/construction reuse and uses
  `[value]` only for the temporary `ViewLeft` result.
- **ordered-map / hash-map** — associative workloads on each language's
  *standard-library* map: build under MINSTD keys, churn insert/remove
  rounds, sum lookups, then fold the final contents. The checksum depends
  only on final map contents plus the lookup stream, so ordered, hashed,
  mutable, and persistent representations must all agree. ordered-map is
  dense and narrow: 1M builds / 1M churn / 1M lookups over a 524287
  keyspace (~77% final occupancy, ~401k entries). hash-map is large and
  broad: keys are raw MINSTD draws, uniform over [1, 2^31-2] — a
  full-period permutation, so fresh draws never repeat, and removals plus
  the hit half of the lookups replay the build key stream through a second
  MINSTD state (4M builds / 2M churn / 2M lookups, final size 4,999,834,
  lookups split ~50/50 guaranteed-hit/guaranteed-miss). Reussir uses its std's `WavlMap`
  (persistent WAVL tree) and `HashMap` (persistent radix-32 HAMT with the
  pure FastHasher); Rust appears twice — `rust` uses std's `BTreeMap`/
  `HashMap` (mutable, SipHash-1-3) as the imperative baseline, and
  `rust-rpds` uses the `rpds` crate's `RedBlackTreeMap`/`HashTrieMap`
  (Rc-linked persistent structures, updated through the owned-`_mut`
  copy-on-write path) as the representation-matched comparison;
  Haskell uses `Data.Map.Strict` (containers) and `Data.HashMap.Strict`
  (unordered-containers, a HAMT like Reussir's); OCaml uses `Map.Make`
  (persistent AVL) and `Hashtbl` (mutable); Lean uses `Std.TreeMap` and
  `Std.HashMap` (in-place when uniquely referenced). Representations and
  hash functions are intentionally each library's stock choice — this set
  compares shipped standard libraries, not one algorithm. Koka's stdlib has
  no comparable containers and sits this set out. The Reussir cells compile
  against the pinned tree's bundled `core`+`std` packages (built once per
  configuration with the same flags and folded into the same ThinLTO link).
- **functional-queue** — strict Hood–Melville real-time queue with incremental
  `Reversing`/`Appending` rotation states. Build 65536 elements, perform 1M
  dequeue/enqueue rotations, then drain. The operation stream and schedule
  advancement are identical in every language; Rust shares list tails with
  `Rc`. Reussir keeps `Queue` and its recursive `QList` shared, while its
  nonrecursive `Rotation` and `Pop` contracts are inline `[value]` types.

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
| `rust-rpds` / `rust-rpds-with-mimalloc` | same flags, linking the prebuilt `rpds` persistent-collection rlibs (std-collections set only) |
| `haskell` | `ghc -O2 -rtsopts`, default RTS (purely functional sources) |
| `haskell-a1g` | same sources, `-with-rtsopts=-A1G` (1 GiB nursery) |
| `haskell-st` / `haskell-st-a1g` | mutable `Data.Array.ST` sources, both RTS configs (large-aggregates set only) |
| `ocaml` | `ocamlopt -O3` |

Both Haskell RTS configurations are first-class variants because the
default-vs-1 GiB-nursery choice swings results dramatically in both
directions: churn-heavy symbolic benchmarks (derive, nbe) run up to ~2.9×
faster with `-A1G` (zero minor GCs), while large-live-set benchmarks
(rbtree) run ~40% slower (cold-nursery cache effects).

Known toolchain quirks, encoded in the sources:

- Koka 3.2.x's `-O3` specializer diverges on a recursive call whose argument
  builds a closure (`vector-init` in life) — `noinline` on the offender is
  the workaround, commented in `koka/life.kk`.
- Koka emits binaries without the executable bit; `compile.py` fixes it up.

## Running

The checked-in flake is the one-shot bootstrap. It pins Reussir main at
`25f7884fde21165471487d522ec0272fc9c5668a` and builds only the `rrc`
dependency closure plus `libreussir_rt.a`; TPDE, tests, the REPL, and unrelated
tools are not built. For the std-collections set it additionally stages the
runtime's rlib closure (`REUSSIR_RUSTC`/`REUSSIR_RUSTC_DEPS`, consumed by
rrc's polymorphic-FFI compiles) and exports the pinned source tree as
`REUSSIR_SRC`, from which `compile.py` builds the bundled `core` and `std`
packages. It also supplies Clang/LLVM, Lean, Koka, Rust, GHC with the Hackage
`fingertree` and `unordered-containers` packages, OCaml (and its GCC linker),
hyperfine, GNU time, mimalloc, and the Python plotting dependencies.

```bash
direnv allow             # builds once, then reuses the Nix store result
# or: nix develop
python3 verify.py        # compile and execute every registered cell once
```

Benchmark commands:

```bash
python3 main.py                                   # full matrix, JSON to stdout
python3 main.py --set large-aggregates            # one set
python3 main.py --bench heap-array --variant reussir
python3 main.py --bench heap-functional --variant rust
python3 main.py --output-json out/results.json --plot-dir out/
python3 main.py --input-json out/results.json --plot-dir out/  # replot only
```

When stderr is an interactive terminal, `main.py` opens a Burn-style live TUI
dashboard while the matrix runs. Each completed benchmark/variant cell adds a
runtime and peak-RSS bar; both panels recompute their scale immediately as new
data arrives. The dashboard uses the alternate screen and writes only to
stderr, so JSON on stdout and `--output-json` remain unchanged. Use `--no-tui`
to keep the plain progress bar, or `--tui` to force the dashboard.

`--plot-dir` writes one SVG per set (`functional-data-structures.svg`,
`large-aggregates.svg`): grouped bars of mean runtime, log scale, one bar
group per benchmark, one bar per variant. Timing uses hyperfine
(`warmup-runs`/`runs` in `config.json`); peak RSS is sampled with
`time -f %M`, resolved from the Nix environment.

Toolchain paths live in `config.json` (`reussir-compiler`, `cc`,
`reussir-libs`, `koka-compiler`, `lean-compiler`/`leanc`, `rustc`, `ghc`,
`ocamlopt`, `hyperfine`). The flake exports absolute overrides for all of
these, so no manual path editing is needed inside `nix develop`/direnv.

## Extending

See the module docstring in `benches.py`: a new benchmark is one `BENCHES`
entry plus per-language sources that self-verify; a new language or
configuration is one `VARIANTS` entry (`kind` picks the toolchain in
`runner.py`, remaining keys are compile options).
