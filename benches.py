BENCHES = {
    "rbtree" : {
        "lean" : "lean/rbtree.lean",
        "reussir" : ("reussir/rbtree.rr", "reussir/rbtree.rr.c"),
        "reussir-nrac" : ("reussir/rbtree.rr", "reussir/rbtree.rr.c"),
        "koka" : "koka/rbtree.kk",
        "rust" : "rust/rbtree.rs",
        "rust-with-mimalloc" : "rust/rbtree.rs",
        "haskell" : "haskell/rbtree.hs",
    },
    "rbtree-zipper" : {
        "lean" : "lean/rbtree-zipper.lean",
        "reussir" : ("reussir/rbtree-zipper.rr", "reussir/rbtree.rr.c"), # reuse rbtree.rr.c
        "reussir-nrac" : ("reussir/rbtree-zipper.rr", "reussir/rbtree.rr.c"),
        "koka" : "koka/rbtree-zipper.kk",
        "rust" : "rust/rbtree-zipper.rs",
        "rust-with-mimalloc" : "rust/rbtree-zipper.rs",
        "haskell" : "haskell/rbtree-zipper.hs",
    },
    "nbe-hoas" : {
        "lean" : "lean/nbe-hoas.lean",
        "reussir" : ("reussir/nbe-hoas.rr", "reussir/nbe-hoas.rr.c"),
        "reussir-nrac" : ("reussir/nbe-hoas.rr", "reussir/nbe-hoas.rr.c"),
        "koka" : "koka/nbe-hoas.kk",
        "rust" : "rust/nbe-hoas.rs",
        "rust-with-mimalloc" : "rust/nbe-hoas.rs",
        "haskell" : "haskell/nbe-hoas.hs",
    },
    "nbe-closure" : {
        "lean" : "lean/nbe-closure.lean",
        "reussir" : ("reussir/nbe-closure.rr", "reussir/nbe-closure.rr.c"),
        "reussir-nrac" : ("reussir/nbe-closure.rr", "reussir/nbe-closure.rr.c"),
        "koka" : "koka/nbe-closure.kk",
        "rust" : "rust/nbe-closure.rs",
        "rust-with-mimalloc" : "rust/nbe-closure.rs",
        "haskell" : "haskell/nbe-closure.hs",
    },
    # Skip lambda test for now
    # "rbtree-zipper-lambda" : {
    #     "lean" : "lean/rbtree-zipper-lambda.lean",
    #     "reussir" : ("reussir/rbtree-zipper-lambda.rr", "reussir/rbtree.rr.c"),
    #     "koka" : "koka/rbtree-zipper-lambda.kk",
    #     "rust" : "rust/rbtree-zipper-lambda.rs",
    #     "haskell" : "haskell/rbtree-zipper-lambda.hs",
    # },
    "derive" : {
        "lean" : "lean/derive.lean",
        "reussir" : ("reussir/derive.rr", "reussir/derive.rr.c"),
        "reussir-nrac" : ("reussir/derive.rr", "reussir/derive.rr.c"),
        "koka" : "koka/derive.kk",
        "rust" : "rust/derive.rs",
        "rust-with-mimalloc" : "rust/derive.rs",
        "haskell" : "haskell/derive.hs",
    }
}
