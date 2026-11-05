# Reussir benchmark suite

Cross-language benchmarks comparing Reussir against Lean, Koka, Rust,
Haskell, OCaml, and Morphic, organized as five sets:

| Set | Benchmarks | What it exercises |
|---|---|---|
| `functional-data-structures` | rbtree, rbtree-zipper, nbe-hoas, nbe-closure, derive, fingertree, functional-queue, heap-functional, mltt | allocation, pattern matching, persistence, and reuse/GC of linked structures |
| `large-aggregates` | life, qsort, heap-array, raytracer, rgba-composite, pcm-mix-limit | flat arrays, array heaps, rendering, image compositing, and audio processing |
| `std-collections` | ordered-map-linear, ordered-map-shared, ordered-map-heavily-shared, hash-map-linear, hash-map-shared, hash-map-heavily-shared | each language's standard ordered map and hash map under matched insert/remove/lookup workloads at three retention tiers: none, sparse, and heavy |
| `big-integers` | bigint-fib, bigint-factorial, bigint-pidigits, bigint-binomial, bigint-rbtree, bigint-collatz | each language's arbitrary-precision integers on heap-sized values (sums, products and quotients by a word, spigot arithmetic) and on values that stay word-sized |
| `shared-traversals` | list-membership, expr-replace, rbtree-lookup | read-only traversals of data the caller keeps: what borrowed parameters save a reference-counted runtime |

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

Each benchmark/variant has a five-minute measurement budget (`case-time-budget-seconds`
in `config.json`), including warmups and peak-RSS measurement; compilation is separate.
Compilation and linking share their own five-minute deadline per cell. Set
`--compile-timeout SECONDS` in `main.py` or `verify.py`, or change
`compile-timeout-seconds` in `config.json`. On expiry, the compiler and its child
processes are stopped. The benchmark runner records `status: "compile_timeout"`
with no timing or RSS sample and continues; verification reports a failure and
continues its sweep.
Slow cases use fewer warmups and timing samples. Results retain completed samples,
their sample count and standard deviation, and indicate when the budget limited
measurement. If only the RSS run fits, its elapsed time is retained and labeled
`gnu-time`; other timing samples come from hyperfine. A single sample has no
standard deviation; an interrupted RSS run
does not supply a footprint.

## Benchmarks

- **raytracer** — sequential rendering of 128×85 pixels, four samples per
  pixel, depth ten, and the original Lean StdGen stream seeded with zero.
  Every port checks the weighted RGB checksum `64158141444`; image-file
  writing is excluded. Reussir uses `World` member methods and a `RefCell`
  RNG, so repeated calls always advance the same state. Morphic is blocked:
  its current compiler has no required floating-point math intrinsics or
  source FFI. Upstream attribution is in `licenses/raytracer-NOTICE`.
- **rbtree / rbtree-zipper** — insert 2.5M keys into a red-black tree
  (recursive balance vs. zipper-based), count the `true` values.
- **nbe-hoas / nbe-closure** — normalization by evaluation of a 1M-redex
  Church-numeral term (HOAS closures vs. defunctionalized env), repeated
  6/7 times with a per-round seed so no compiler can share rounds.
- **derive** — one symbolic derivative chain of `x^x` nested 10 deep.
- **life** — Conway's Game of Life, toroidal 64×64, 50k generations.
  Functional per-generation rebuild (tabulate / `vector-init` / `ofFn` /
  `listArray`), mutation double-buffer for the baselines.
- **rgba-composite** — 4096 source-over passes over 262144 packed RGBA8
  pixels, with per-pass opacity and an opaque destination. Each pass reads
  one source image and updates the destination in contiguous order; setup
  and the checksum are outside the pass loop. Every port checks
  `1123699998887936`.
- **pcm-mix-limit** — 8192 mixing passes over 262144 signed PCM samples.
  Each pass applies a Q15 gain, a linear fade, a symmetric soft knee, and
  hard saturation. Signed division truncates toward zero; all intermediate
  products fit in signed 32 bits. Every port checks energy
  `124776496343097`.
  Both workloads use 32-bit element types in Reussir, Lean, Koka, Rust,
  and Haskell; OCaml uses native integers and Morphic uses `I64`. Haskell uses mutable unboxed ST
  arrays. Independent scalar C references are in `tests/reference/`.
- **qsort** — 100 rounds of in-place Lomuto quicksort over a fresh
  `[i64; 65536]` MINSTD-filled array. Persistent-array languages rely on
  uniqueness/COW for in-place sets; the Koka and pure Haskell variants use
  their existing list-quicksort sources — noted in those files.
- **mltt** — a small bidirectional MLTT checker with stratified universes,
  dependent functions and pairs, natural-number induction, and identity types
  with based path induction. All seven ports use explicit term/value variants,
  closures over linked environments, and signed 64-bit binder IDs and universe
  levels. Haskell uses strict fields and bindings. Rust uses shared `Rc` nodes.
  Every run performs ten kernel checks, then checks valid and deliberately
  corrupted associativity, equality-chain, and dependent-pair proof bundles at
  size 4096. Each bundle checks all six supporting definitions from scratch;
  no lemma is trusted. The expected check total is 16. Timing includes term
  construction, checking, and cleanup, including the invalid proofs. These are
  generated standalone proofs, not Lean/Arena imports. This benchmark requires
  Reussir's borrowed-callable inliner fix (#917); the pinned compiler also
  includes guarded last-use traversal borrowing (#919).
  The Morphic port is retained but not registered in the default suite: native
  compilation was stopped after 18.6 CPU minutes at about 55 GiB RSS. Its OCaml
  backend compiles and returns 16; this does not validate the native RC backend.
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
- **ordered-map / hash-map (`-linear` and `-shared`)** — associative
  workloads on each language's *standard-library* map: build under MINSTD
  keys, churn insert/remove rounds, sum lookups, then fold the final
  contents. The checksum depends only on final map contents plus the
  lookup stream, so ordered, hashed, mutable, and persistent
  representations must all agree. The ordered-map workload is dense and
  narrow: build/churn/lookup rounds over a 524287 keyspace. The hash-map
  workload is a Zipfian mixed-op stream: keys follow an integer-only
  octave Zipf (theta ~ 1; a stratum s uniform in [0, 24), then a key
  uniform in [2^s, 2^(s+1)), so per-key probability decays as 1/key with
  no floating point involved), and each round draws op/stratum/key from
  one MINSTD stream — 9/16 insert, 5/16 delete, 2/16 lookup, with deletes
  landing on present keys ~48% of the time. Each structure runs in two
  configurations, and every configuration of a structure runs the same
  round counts (ordered: 1M builds / 1M churn / 1M lookups; hash: 8M
  rounds), so the per-configuration segments of a stacked plot weigh the
  same workload. The `-linear` cells thread exactly one live version and
  retain nothing (ordered ends at 400,944 entries; hash at 1,120,773),
  so in-place and uniqueness-reuse updates stay unobstructed. The
  `-shared` cells add version retention: during mutating rounds one more
  draw per round parks the current version in an eight-slot ring when
  divisible by 8192 (265 events for ordered, 977 for hash), where it
  stays shared until the slot is overwritten; the checksum folds the
  working map plus every ring slot, so persistent maps pay path copies
  while a version is parked and mutable maps pay a full copy per parked
  version (ordered ends at 401,258 entries with ~401k-entry ring slots;
  hash at 1,120,619 with ~1.1M-entry slots — the retention bill for an
  explicit-copy representation is deliberately part of the score). The
  `-heavily-shared` cells are the same shared workloads with the
  retention modulus dropped from 8192 to 512 (~3.9k ordered and ~15.6k
  hash events): far past the crossover where per-event full copies
  dominate a mutable representation, while persistent maps are
  insensitive to retention frequency. Reussir uses its std's `WavlMap`
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
  compares shipped standard libraries, not one algorithm. Koka's bundled
  stdlib has no comparable containers, so its cells use the community
  standard library ([koka-community/std](https://github.com/koka-community/std),
  vendored under `koka/community-std`): `std/data/rbtree-bu` (persistent
  red-black tree with bottom-up insert/remove) for the ordered map and
  `std/data/hashmap` (bucket hash map over a uniqueness-adaptive vector,
  copied in full when an update hits a shared table) for the hash map.
  The Reussir cells compile
  against the pinned tree's bundled `core`+`std` packages (built once per
  configuration with the same flags and folded into the same ThinLTO link).
  Morphic's library has no ordered map, and its only hash map is the sample
  `samples/lib/hashmap.mor` (separate chaining over copy-on-write arrays,
  updated in place while the table is uniquely referenced and copied when
  shared); its cells use that hash map (vendored under `morphic/lib`) and a
  plain persistent red-black tree written for the suite (`morphic/lib/ordmap.mor`).
- **functional-queue** — strict Hood–Melville real-time queue with incremental
  `Reversing`/`Appending` rotation states. Build 65536 elements, perform 1M
  dequeue/enqueue rotations, then drain. The operation stream and schedule
  advancement are identical in every language; Rust shares list tails with
  `Rc`. Reussir keeps `Queue` and its recursive `QList` shared, while its
  nonrecursive `Rotation` and `Pop` contracts are inline `[value]` types.
- **big integers** — each language's built-in or de-facto standard
  arbitrary-precision integers: Reussir `Nat`/`Int` (compiled to the rcgmp
  dialect and runtime, so the cells compile against the bundled `core`),
  Lean `Nat`/`Int`, GHC `Integer`, Koka `int`, OCaml Zarith, and Rust
  num-bigint (std has no big integers; the cells link the prebuilt crate, and
  update in place where the API allows). Loop counters use native integers
  where the language has them. Each program checks a residue modulo
  1000000007 (or an exact small result), so no decimal conversion is timed.
  - **bigint-fib** — iterative Fibonacci to F(600000): 600k additions of
    operands growing to 416k bits.
  - **bigint-factorial** — 120000! by sequential products 2 · 3 · … · n: a
    growing integer times a word.
  - **bigint-pidigits** — the first 10000 digits of pi with Gibbons'
    unbounded spigot (the Benchmarks Game algorithm), hashed. The
    accumulator goes negative between digits, so every port uses signed
    integers.
  - **bigint-binomial** — the row C(200000, i) by C(n, i+1) = C(n, i) · (n−i)
    / (i+1): exact divisions by a word; the row must sum to 2^n and end at 1.
  - **bigint-rbtree** — rbtree's 2.5M descending inserts with big-integer
    keys and values (each key mapped to itself), then the sum of the values.
  - **bigint-collatz** — total Collatz trajectory length for starting values
    1 … 999999 (131M steps; values stay below 2^37).
  The last two keep every value word-sized and so measure the small-integer
  path: tagged immediates in Reussir, Lean, Koka, and Zarith, GHC's
  small-`Integer` constructor, and a heap-allocated `BigUint` in Rust.
  Morphic has no arbitrary-precision integers, so this set has no Morphic
  cells.
- **shared traversals** — traversals that only read data the caller keeps
  afterwards. A reference-counted runtime that can borrow the traversed
  structure (Lean's inferred borrowed parameters, Morphic's borrow-inferred
  RC, Rust's `&`) only reads it. One that cannot updates a count on every
  visited node, and those counts are written into shared, often cold, cache
  lines. The cases come from lean2reussir's measurements of what Reussir's
  missing borrowed parameters cost (reussir-lang/reussir#762).
  - **list-membership** — #762's repro at scale: 40000 membership queries
    against one list of 10000 integers that stays live between queries (half
    of the queries miss and walk the whole list).
  - **expr-replace** — the `Expr.replace` shape: substitution that returns
    every unchanged subterm itself. The term is a balanced sum of 256
    summands `Var(i % 16) * P` that all share one polynomial `P` of 4096
    literals, and each of 100 rounds substitutes one variable of the same
    retained term. A subterm is rebuilt only where the variable occurs,
    which an occurs check decides first; Lean caches that answer in each
    `Expr`, here it is recomputed, so the check reads all of `P` at every
    summand. Native Lean borrows the check's argument (no count updates). In
    the formulation that returns `Option` and keeps unchanged children, Lean
    instead takes the argument owned to reuse its cell, which is why the
    occurs-check form is used.
  - **rbtree-lookup** — rbtree's tree with 1M scattered inserts, each
    followed by 8 lookups in the current tree, which stays live for the next
    insert. The inserts own the tree and can update it in place, while the
    lookups only read it. A compiler that borrows must keep the inserts'
    in-place reuse.
  Every port uses the same algorithm and checksums (20000 hits, 259584, and
  2059798 hits).

## Variants and toolchain configurations

| Variant | Configuration |
|---|---|
| `reussir` | `rrc -Oaggressive --reuse-across-call` → clang `-flto=thin -O3 -march=native`, static thin-LTO runtime (`reussir-libs`) |
| `reussir-nrac` | same without `--reuse-across-call` |
| `reussir-dia` | same with `--disable-invariant-analysis` (not in the default matrix) |
| `koka` | `-O3`, clang thin-LTO + `-march=native` via `--ccopts`/`--cclinkopts` |
| `lean` | `lean -c` → Clang `-O3 -flto=thin -fuse-ld=lld`, host CPU; ThinLTO runtime/stdlib |
| `rust` | `rustc -C opt-level=3 -C lto=thin -C target-cpu=native` |
| `rust-with-mimalloc` | same binary, `LD_PRELOAD` mimalloc |
| `rust-rpds` / `rust-rpds-with-mimalloc` | same flags, linking the prebuilt `rpds` persistent-collection rlibs (std-collections set only) |
| `haskell` | `ghc -O2 -rtsopts`, default RTS (purely functional sources) |
| `haskell-a1g` | same sources, `-with-rtsopts=-A1G` (1 GiB nursery) |
| `haskell-st` / `haskell-st-a1g` | mutable `Data.Array.ST` sources, both RTS configs (large-aggregates set only) |
| `ocaml` | OxCaml (Flambda 2), `ocamlopt -O3` |
| `morphic` | `morphic build --llvm-opt-level 3` (host CPU), default borrow-inferred RC and copy-on-write arrays |

The big-integer cells of `rust` and `rust-with-mimalloc` also link the
prebuilt num-bigint rlibs, and those of `ocaml` link Zarith through
`ocamlfind`.

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

## Native optimization

Rust uses `-C opt-level=3 -C lto=thin -C target-cpu=native`; external crate
archives retain LLVM bitcode for cross-crate optimization. Lean uses Clang through
`LEAN_CC`, `-O3 -flto=thin -fuse-ld=lld`, and `-march=native` on x86_64 or
`-mcpu=native` on AArch64. Its pinned runtime and standard-library archives are
rebuilt with ThinLTO. CPU-specific benchmark executables are built on the host
where they are measured; Rust and Lean dependency packages retain portable
CPU targets.

The `ocaml` configuration uses pinned [OxCaml](https://github.com/oxcaml/oxcaml)
(OCaml 5.4 based, Flambda 2) with `-O3` and its native backend defaults.
Findlib and Zarith are rebuilt against
that compiler. `ocamlopt -config` reports `flambda2: true`.
Existing benchmark sources and result keys remain `ocaml`;
the recorded toolchain identifies OxCaml. External native libraries such as
GMP remain outside LLVM LTO.

## Running

The checked-in flake is the one-shot bootstrap. It pins Reussir main at
`36f05142f3b33f442f69afa421a10b7a39ee21f9` and builds only the `rrc`
dependency closure plus `libreussir_rt.a` and `libRCGMPRuntime.a`
(`REUSSIR_RCGMP_RUNTIME`); TPDE, tests, the REPL, and unrelated tools are
not built. For the std-collections and big-integers sets it additionally
stages the runtime's rlib closure (`REUSSIR_RUSTC`/`REUSSIR_RUSTC_DEPS`,
consumed by rrc's polymorphic-FFI compiles) and exports the pinned source
tree as `REUSSIR_SRC`, from which `compile.py` builds the bundled `core` and
`std` packages. It also supplies Clang/LLVM, Lean, Koka, Rust with the
prebuilt `rpds` and num-bigint crates (`RUST_EXTERN_LIBS`), GHC with the
Hackage `fingertree` and `unordered-containers` packages, OCaml (and its GCC
linker) with findlib and Zarith, GMP, hyperfine, GNU time, mimalloc, and the
Python plotting dependencies, and the Morphic compiler
(`morphic-lang/morphic` at the revision `morphic/lib` was vendored from),
built against LLVM 16 from nixos-25.05 since nixos-unstable has dropped it.

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
`ocamlopt`, `morphic-compiler`/`morphic-clang`, `hyperfine`). The flake exports absolute overrides for all of
these, so no manual path editing is needed inside `nix develop`/direnv.

## Extending

See the module docstring in `benches.py`: a new benchmark is one `BENCHES`
entry plus per-language sources that self-verify; a new language or
configuration is one `VARIANTS` entry (`kind` picks the toolchain in
`runner.py`, remaining keys are compile options).
