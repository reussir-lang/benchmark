BENCHES = {
    "rbtree" : {
        "lean" : "lean/rbtree.lean",
        "reussir" : ("reussir/rbtree.rr", "reussir/rbtree.rr.c"),
        "koka" : "koka/rbtree.kk",
        "rust" : "rust/rbtree.rs",
        "haskell" : "haskell/rbtree.hs",
    },
    "rbtree-zipper" : {
        "lean" : "lean/rbtree-zipper.lean",
        "reussir" : ("reussir/rbtree-zipper.rr", "reussir/rbtree.rr.c"), # reuse rbtree.rr.c
        "koka" : "koka/rbtree-zipper.kk",
        "rust" : "rust/rbtree-zipper.rs",
        "haskell" : "haskell/rbtree-zipper.hs",
    },
    "nbe" : {
        "lean" : "lean/nbe.lean",
        "reussir" : ("reussir/nbe.rr", "reussir/nbe.rr.c"),
        "koka" : "koka/nbe.kk",
        "rust" : "rust/nbe.rs",
        "haskell" : "haskell/nbe.hs",
    },
    "hoascbv" : {
        "lean" : "lean/hoascbv.lean",
        "reussir" : ("reussir/hoascbv.rr", "reussir/hoascbv.rr.c"),
        "koka" : "koka/hoascbv.kk",
        "rust" : "rust/hoascbv.rs",
        "haskell" : "haskell/hoascbv.hs",
    },
    "rbtree-zipper-lambda" : {
        "lean" : "lean/rbtree-zipper-lambda.lean",
        "reussir" : ("reussir/rbtree-zipper-lambda.rr", "reussir/rbtree.rr.c"), # reuse rbtree.rr.c
        "koka" : "koka/rbtree-zipper-lambda.kk",
        "rust" : "rust/rbtree-zipper-lambda.rs",
        "haskell" : "haskell/rbtree-zipper-lambda.hs",
    },
    "derive" : {
        "lean" : "lean/derive.lean",
        "reussir" : ("reussir/derive.rr", "reussir/derive.rr.c"),
        "koka" : "koka/derive.kk",
        "rust" : "rust/derive.rs",
        "haskell" : "haskell/derive.hs",
    }
}
