BENCHES = {
    "rbtree" : {
        "lean" : "lean/rbtree.lean",
        "reussir" : ("reussir/rbtree.rr", "reussir/rbtree.rr.c"),
        "koka" : "koka/rbtree.kk",
    },
    "rbtree-zipper" : {
        "lean" : "lean/rbtree-zipper.lean",
        "reussir" : ("reussir/rbtree-zipper.rr", "reussir/rbtree.rr.c"), # reuse rbtree.rr.c
        "koka" : "koka/rbtree-zipper.kk",
    },
    "nbe" : {
        "lean" : "lean/nbe.lean",
        "reussir" : ("reussir/nbe.rr", "reussir/nbe.rr.c"),
        "koka" : "koka/nbe.kk",
    }
}