"""Benchmark registry: sets, language variants, and benchmark sources.

The suite is organized as two benchmark sets:

- ``functional-data-structures``: constructor-based workloads (trees, terms,
  symbolic expressions) that exercise allocation, pattern matching, and
  reuse/GC of linked structures.
- ``large-aggregates``: flat-array workloads (grids, sort buffers, binary
  heaps) that exercise bulk memory, in-place update under persistence
  (copy-on-write / uniqueness), and bounds handling.

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
- haskell: ghc ``-O2 -rtsopts``; the ``-a1g`` variants bake ``+RTS -A1G``
  (1 GiB nursery) via ``-with-rtsopts`` — both RTS configurations are
  first-class variants because the default-vs-large-nursery choice swings
  results by -40%..+190% depending on the benchmark's live-set size.
  The ``-st`` variants are separate sources using mutable ST arrays where
  the plain variant is purely functional.
"""

SETS = {
    "functional-data-structures": "Functional data structures",
    "large-aggregates": "Large aggregates",
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
    "haskell": {"kind": "haskell"},
    "haskell-a1g": {"kind": "haskell", "rts_opts": "-A1G"},
    "haskell-st": {"kind": "haskell"},
    "haskell-st-a1g": {"kind": "haskell", "rts_opts": "-A1G"},
}

_FUNCTIONAL = "functional-data-structures"
_AGGREGATES = "large-aggregates"


def _sources(base, haskell=None, haskell_st=None):
    """Expand shared sources into per-variant entries.

    ``haskell`` feeds both the default and the -A1G RTS variant; likewise
    ``haskell_st``. Rust feeds both the plain and the mimalloc variant.
    """
    sources = dict(base)
    if "rust" in sources:
        sources["rust-with-mimalloc"] = sources["rust"]
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
            },
            haskell="haskell/qsort.hs",
            haskell_st="haskell/qsort_st.hs",
        ),
    },
    "heap": {
        "set": _AGGREGATES,
        "sources": _sources(
            {
                "lean": "lean/heap.lean",
                "reussir": ("reussir/heap.rr", "reussir/heap.rr.c"),
                "reussir-nrac": ("reussir/heap.rr", "reussir/heap.rr.c"),
                "koka": "koka/heap.kk",
                "rust": "rust/heap.rs",
            },
            haskell="haskell/heap.hs",
            haskell_st="haskell/heap_st.hs",
        ),
    },
}
