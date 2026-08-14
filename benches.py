"""Benchmark registry: sets, language variants, and benchmark sources.

The suite is organized as two benchmark sets:

- ``functional-data-structures``: constructor-based workloads (trees, terms,
  symbolic expressions, finger trees, and real-time queues) that exercise
  allocation, pattern matching, persistence, and reuse/GC.
- ``large-aggregates``: flat-array workloads plus the paired array and Braun
  binary heaps, keeping the two heap representations in one result set.

Extending the suite
===================

New benchmark: add one entry to ``BENCHES`` with its set and one source per
variant it supports, then drop the program files into the per-language
directories. Every program must hard-code its workload, verify its own
result, and exit non-zero on mismatch (the harness treats a non-zero exit as
failure) — see any existing benchmark for the pattern.

New language/configuration variant: add one entry to ``VARIANTS`` (the
``kind`` selects the toolchain in ``runner.py``; the remaining keys are
options passed to the corresponding ``compile_*`` function), then reference
it from the benchmarks that support it.

Toolchain configurations
========================

- reussir: ``-Oaggressive`` + clang ``-flto=thin -O3 -march=native`` against
  the static thin-LTO runtime (``reussir-libs`` in config.json). The
  ``-nrac`` variant disables ``--reuse-across-call``.
- koka: ``-O3`` with clang thin-LTO and ``-march=native``
  (``--ccopts``/``--cclinkopts``).
- lean: lean → C, then leanc ``-flto -O3``.
- rust: ``-C opt-level=3``; the ``-with-mimalloc`` variant preloads mimalloc.
  The ``rust-rpds`` variants additionally link the prebuilt ``rpds``
  persistent-collection rlibs (``extern_crates``, resolved via RPDS_LIBS).
- haskell: ghc ``-O2 -rtsopts``; the ``-a1g`` variants bake ``+RTS -A1G``
  (1 GiB nursery) via ``-with-rtsopts`` — both RTS configurations are
  first-class variants because the default-vs-large-nursery choice swings
  results by -40%..+190% depending on the benchmark's live-set size.
  The ``-st`` variants are separate sources using mutable ST arrays where
  the plain variant is purely functional.
- ocaml: ``ocamlopt -O3``.

For matched data-structure workloads, logical payloads have the same explicit
width in every language: signed 64-bit keys/elements for the red-black trees,
both heaps, the finger tree, and the functional queue. Native index/counter
types and runtime object layouts may differ.

Workloads use a roughly quarter-scale dominant work factor while retaining
the working-set shape that each benchmark is intended to measure.
"""

SETS = {
    "functional-data-structures": "Functional data structures",
    "large-aggregates": "Large aggregates",
    "std-collections": "Standard-library collections",
}

VARIANTS = {
    "reussir": {"kind": "reussir", "reuse_across_call": True},
    "reussir-nrac": {"kind": "reussir", "reuse_across_call": False},
    "reussir-dia": {
        "kind": "reussir",
        "reuse_across_call": True,
        "extra_flags": ["--disable-invariant-analysis"],
    },
    "koka": {"kind": "koka"},
    "lean": {"kind": "lean"},
    "rust": {"kind": "rust"},
    "rust-with-mimalloc": {"kind": "rust", "runtime_env_key": "rust-runtime-env"},
    "rust-rpds": {"kind": "rust", "extern_crates": ["rpds"]},
    "rust-rpds-with-mimalloc": {
        "kind": "rust",
        "extern_crates": ["rpds"],
        "runtime_env_key": "rust-runtime-env",
    },
    "haskell": {"kind": "haskell"},
    "haskell-a1g": {"kind": "haskell", "rts_opts": "-A1G"},
    "haskell-st": {"kind": "haskell"},
    "haskell-st-a1g": {"kind": "haskell", "rts_opts": "-A1G"},
    "ocaml": {"kind": "ocaml"},
}

_FUNCTIONAL = "functional-data-structures"
_AGGREGATES = "large-aggregates"
_STD = "std-collections"


def _sources(base, haskell=None, haskell_st=None):
    """Expand shared sources into per-variant entries.

    ``haskell`` feeds both the default and the -A1G RTS variant; likewise
    ``haskell_st``. Rust feeds both the plain and the mimalloc variant.
    """
    sources = dict(base)
    if "rust" in sources:
        sources["rust-with-mimalloc"] = sources["rust"]
    if "rust-rpds" in sources:
        sources["rust-rpds-with-mimalloc"] = sources["rust-rpds"]
    if haskell is not None:
        sources["haskell"] = haskell
        sources["haskell-a1g"] = haskell
    if haskell_st is not None:
        sources["haskell-st"] = haskell_st
        sources["haskell-st-a1g"] = haskell_st
    return sources


BENCHES = {
    "rbtree": {
        "set": _FUNCTIONAL,
        "sources": _sources(
            {
                "lean": "lean/rbtree.lean",
                "reussir": ("reussir/rbtree.rr", "reussir/rbtree.rr.c"),
                "reussir-nrac": ("reussir/rbtree.rr", "reussir/rbtree.rr.c"),
                "koka": "koka/rbtree.kk",
                "rust": "rust/rbtree.rs",
                "ocaml": "ocaml/rbtree.ml",
            },
            haskell="haskell/rbtree.hs",
        ),
    },
    "rbtree-zipper": {
        "set": _FUNCTIONAL,
        "sources": _sources(
            {
                "lean": "lean/rbtree-zipper.lean",
                # reuses rbtree's driver
                "reussir": ("reussir/rbtree-zipper.rr", "reussir/rbtree.rr.c"),
                "reussir-nrac": ("reussir/rbtree-zipper.rr", "reussir/rbtree.rr.c"),
                "koka": "koka/rbtree-zipper.kk",
                "rust": "rust/rbtree-zipper.rs",
                "ocaml": "ocaml/rbtree-zipper.ml",
            },
            haskell="haskell/rbtree-zipper.hs",
        ),
    },
    "nbe-hoas": {
        "set": _FUNCTIONAL,
        "sources": _sources(
            {
                "lean": "lean/nbe-hoas.lean",
                "reussir": ("reussir/nbe-hoas.rr", "reussir/nbe-hoas.rr.c"),
                "reussir-nrac": ("reussir/nbe-hoas.rr", "reussir/nbe-hoas.rr.c"),
                "koka": "koka/nbe-hoas.kk",
                "rust": "rust/nbe-hoas.rs",
                "ocaml": "ocaml/nbe-hoas.ml",
            },
            haskell="haskell/nbe-hoas.hs",
        ),
    },
    "nbe-closure": {
        "set": _FUNCTIONAL,
        "sources": _sources(
            {
                "lean": "lean/nbe-closure.lean",
                "reussir": ("reussir/nbe-closure.rr", "reussir/nbe-closure.rr.c"),
                "reussir-nrac": ("reussir/nbe-closure.rr", "reussir/nbe-closure.rr.c"),
                "koka": "koka/nbe-closure.kk",
                "rust": "rust/nbe-closure.rs",
                "ocaml": "ocaml/nbe-closure.ml",
            },
            haskell="haskell/nbe-closure.hs",
        ),
    },
    "derive": {
        "set": _FUNCTIONAL,
        "sources": _sources(
            {
                "lean": "lean/derive.lean",
                "reussir": ("reussir/derive.rr", "reussir/derive.rr.c"),
                "reussir-nrac": ("reussir/derive.rr", "reussir/derive.rr.c"),
                "koka": "koka/derive.kk",
                "rust": "rust/derive.rs",
                "ocaml": "ocaml/derive.ml",
            },
            haskell="haskell/derive.hs",
        ),
    },
    "life": {
        "set": _AGGREGATES,
        "sources": _sources(
            {
                "lean": "lean/life.lean",
                "reussir": ("reussir/life.rr", "reussir/life.rr.c"),
                "reussir-nrac": ("reussir/life.rr", "reussir/life.rr.c"),
                "koka": "koka/life.kk",
                "rust": "rust/life.rs",
                "ocaml": "ocaml/life.ml",
            },
            haskell="haskell/life.hs",
            haskell_st="haskell/life_st.hs",
        ),
    },
    "qsort": {
        "set": _AGGREGATES,
        "sources": _sources(
            {
                "lean": "lean/qsort.lean",
                "reussir": ("reussir/qsort.rr", "reussir/qsort.rr.c"),
                "reussir-nrac": ("reussir/qsort.rr", "reussir/qsort.rr.c"),
                "koka": "koka/qsort.kk",
                "rust": "rust/qsort.rs",
                "ocaml": "ocaml/qsort.ml",
            },
            haskell="haskell/qsort.hs",
            haskell_st="haskell/qsort_st.hs",
        ),
    },
    "heap-array": {
        "set": _AGGREGATES,
        "sources": _sources(
            {
                "lean": "lean/heap.lean",
                "reussir": ("reussir/heap.rr", "reussir/heap.rr.c"),
                "reussir-nrac": ("reussir/heap.rr", "reussir/heap.rr.c"),
                "koka": "koka/heap-array.kk",
                "rust": "rust/heap.rs",
                "ocaml": "ocaml/heap-array.ml",
            },
            haskell_st="haskell/heap_st.hs",
        ),
    },
    "heap-functional": {
        "set": _AGGREGATES,
        "sources": _sources(
            {
                "lean": "lean/heap-functional.lean",
                "reussir": ("reussir/heap-functional.rr", "reussir/heap.rr.c"),
                "reussir-nrac": ("reussir/heap-functional.rr", "reussir/heap.rr.c"),
                "koka": "koka/heap.kk",
                "rust": "rust/heap-functional.rs",
                "ocaml": "ocaml/heap-functional.ml",
            },
            haskell="haskell/heap.hs",
        ),
    },
    "fingertree": {
        "set": _FUNCTIONAL,
        "sources": _sources(
            {
                "lean": "lean/fingertree.lean",
                "reussir": ("reussir/fingertree.rr", "reussir/fingertree.rr.c"),
                "reussir-nrac": ("reussir/fingertree.rr", "reussir/fingertree.rr.c"),
                "koka": "koka/fingertree.kk",
                "rust": "rust/fingertree.rs",
                "ocaml": "ocaml/fingertree.ml",
            },
            haskell="haskell/fingertree.hs",
        ),
    },
    # Standard-library collection benchmarks: one shared map workload
    # (1M MINSTD-keyed builds, 1M insert/remove churn rounds, 1M lookups,
    # then a content fold) on each language's standard ordered map and
    # hash map. The Reussir cells use std's WavlMap/HashMap and compile
    # against the bundled core+std packages (``reussir-std``); Koka's
    # stdlib has no comparable containers, so it sits these two out.
    "ordered-map": {
        "set": _STD,
        "reussir-std": True,
        "sources": _sources(
            {
                "lean": "lean/ordered-map.lean",
                "reussir": ("reussir/ordered-map.rr", "reussir/map.rr.c"),
                "reussir-nrac": ("reussir/ordered-map.rr", "reussir/map.rr.c"),
                "rust": "rust/ordered-map.rs",
                "rust-rpds": "rust/ordered-map-rpds.rs",
                "ocaml": "ocaml/ordered-map.ml",
            },
            haskell="haskell/ordered-map.hs",
        ),
    },
    "hash-map": {
        "set": _STD,
        "reussir-std": True,
        "sources": _sources(
            {
                "lean": "lean/hash-map.lean",
                "reussir": ("reussir/hash-map.rr", "reussir/hash-map.rr.c"),
                "reussir-nrac": ("reussir/hash-map.rr", "reussir/hash-map.rr.c"),
                "rust": "rust/hash-map.rs",
                "rust-rpds": "rust/hash-map-rpds.rs",
                "ocaml": "ocaml/hash-map.ml",
            },
            haskell="haskell/hash-map.hs",
        ),
    },
    "functional-queue": {
        "set": _FUNCTIONAL,
        "sources": _sources(
            {
                "lean": "lean/functional-queue.lean",
                "reussir": (
                    "reussir/functional-queue.rr",
                    "reussir/functional-queue.rr.c",
                ),
                "reussir-nrac": (
                    "reussir/functional-queue.rr",
                    "reussir/functional-queue.rr.c",
                ),
                "koka": "koka/functional-queue.kk",
                "rust": "rust/functional-queue.rs",
                "ocaml": "ocaml/functional-queue.ml",
            },
            haskell="haskell/functional-queue.hs",
        ),
    },
}
