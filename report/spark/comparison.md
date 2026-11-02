# spark benchmark comparison

spark: 288 recorded cells accounted for; timing 287/288, footprint 287/288. Statuses: budget_exhausted=1, budget_limited=5, complete=282.

The ocaml configuration uses OxCaml (Flambda 2). Time and RSS ratios are variant / default Reussir: above 1 means slower or more memory. Geometric means use only complete, non-budget-limited pairs with positive measurements. Timing and memory coverage can differ. X means takes too long (no completed measurement within 5 minutes). Blank CSV cells and — mean unavailable for other reasons; a single timing sample has no standard deviation.

Reussir: `36f05142f3b33f442f69afa421a10b7a39ee21f9`. Benchmark: `19efdd9334de1d1fb64bb32ff59e0a47aea7d039`. Architecture: aarch64; measurement CPU: 19.

Compiler and runtime hashes are recorded in `provenance/manifest.json`. The compiler hash identifies the native ELF; the compiler launcher environment is recorded separately in `provenance/compiler-launch-environment.json`.

## Complete paired comparisons

| Variant | Available pairs | Timing pairs | Time / Reussir | Memory pairs | RSS / Reussir |
| --- | --- | --- | --- | --- | --- |
| haskell | 27 | 27 | 2.14879 | 27 | 2.90362 |
| haskell-a1g | 27 | 27 | 2.51674 | 27 | 31.3624 |
| haskell-st | 3 | 3 | 3.26913 | 3 | 1.65341 |
| haskell-st-a1g | 3 | 3 | 3.64364 | 3 | 28.6487 |
| koka | 28 | 27 | 2.16541 | 27 | 1.29878 |
| lean | 28 | 27 | 2.07738 | 27 | 2.10146 |
| morphic | 20 | 19 | 2.53533 | 19 | 1.07673 |
| ocaml | 28 | 26 | 2.60236 | 26 | 3.58686 |
| reussir | 28 | 28 | 1 | 28 | 1 |
| reussir-nrac | 28 | 28 | 1.09554 | 28 | 1.03332 |
| rust | 28 | 27 | 2.33605 | 27 | 1.71905 |
| rust-rpds | 6 | 6 | 2.29976 | 6 | 2.13717 |
| rust-rpds-with-mimalloc | 6 | 6 | 1.56538 | 6 | 1.80948 |
| rust-with-mimalloc | 28 | 28 | 1.86152 | 28 | 2.99976 |

## Functional data structures

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| derive | haskell | 699.574 | 0.877911 | 10 | 572.242 | complete | false | hyperfine |
| derive | haskell-a1g | 269.829 | 1.67633 | 10 | 634.715 | complete | false | hyperfine |
| derive | koka | 255.745 | 0.52862 | 10 | 456.145 | complete | false | hyperfine |
| derive | lean | 296.021 | 0.330851 | 10 | 553.324 | complete | false | hyperfine |
| derive | morphic | 596.163 | 1.54492 | 10 | 765.242 | complete | false | hyperfine |
| derive | ocaml | 565.325 | 1.97521 | 10 | 375.418 | complete | false | hyperfine |
| derive | reussir | 238.743 | 0.276986 | 10 | 456.168 | complete | false | hyperfine |
| derive | reussir-nrac | 238.78 | 0.663488 | 10 | 456.355 | complete | false | hyperfine |
| derive | rust | 1061.81 | 5.68245 | 10 | 1530.02 | complete | false | hyperfine |
| derive | rust-with-mimalloc | 538.856 | 0.322926 | 10 | 1536.41 | complete | false | hyperfine |
| fingertree | haskell | 81.0348 | 0.261434 | 10 | 15.3359 | complete | false | hyperfine |
| fingertree | haskell-a1g | 257.216 | 1.91909 | 10 | 683.93 | complete | false | hyperfine |
| fingertree | koka | 50.8189 | 7.02968 | 10 | 5.97266 | complete | false | hyperfine |
| fingertree | lean | 59.0785 | 0.188769 | 10 | 14.1094 | complete | false | hyperfine |
| fingertree | morphic | 55.5025 | 0.142029 | 10 | 2.90234 | complete | false | hyperfine |
| fingertree | ocaml | 53.405 | 0.607744 | 10 | 17.4492 | complete | false | hyperfine |
| fingertree | reussir | 30.9151 | 0.102641 | 10 | 6.08984 | complete | false | hyperfine |
| fingertree | reussir-nrac | 34.098 | 0.400675 | 10 | 6.08984 | complete | false | hyperfine |
| fingertree | rust | 55.9973 | 0.336516 | 10 | 7.67969 | complete | false | hyperfine |
| fingertree | rust-with-mimalloc | 56.37 | 0.218688 | 10 | 10.168 | complete | false | hyperfine |
| functional-queue | haskell | 39.4057 | 0.258684 | 10 | 13.4609 | complete | false | hyperfine |
| functional-queue | haskell-a1g | 87.1812 | 0.513661 | 10 | 267.211 | complete | false | hyperfine |
| functional-queue | koka | 59.7767 | 0.222172 | 10 | 5.98047 | complete | false | hyperfine |
| functional-queue | lean | 61.318 | 0.0611493 | 10 | 14.1211 | complete | false | hyperfine |
| functional-queue | morphic | 73.372 | 0.427251 | 10 | 5.71484 | complete | false | hyperfine |
| functional-queue | ocaml | 87.7632 | 0.150906 | 10 | 18.543 | complete | false | hyperfine |
| functional-queue | reussir | 36.8747 | 0.097778 | 10 | 6.00391 | complete | false | hyperfine |
| functional-queue | reussir-nrac | 36.8505 | 0.0820036 | 10 | 5.94141 | complete | false | hyperfine |
| functional-queue | rust | 71.2906 | 6.5026 | 10 | 6.74219 | complete | false | hyperfine |
| functional-queue | rust-with-mimalloc | 61.1842 | 0.13626 | 10 | 8.72656 | complete | false | hyperfine |
| heap-functional | haskell | 1884.01 | 1.24688 | 10 | 13.4609 | complete | false | hyperfine |
| heap-functional | haskell-a1g | 1886.58 | 4.38463 | 10 | 1050.43 | complete | false | hyperfine |
| heap-functional | koka | 568.234 | 0.350276 | 10 | 5.96875 | complete | false | hyperfine |
| heap-functional | lean | 1440.6 | 3.21392 | 10 | 14.1133 | complete | false | hyperfine |
| heap-functional | morphic | 2466.06 | 11.827 | 10 | 4.92969 | complete | false | hyperfine |
| heap-functional | ocaml | 1939.39 | 12.2177 | 10 | 18.2305 | complete | false | hyperfine |
| heap-functional | reussir | 569.942 | 1.02498 | 10 | 5.99609 | complete | false | hyperfine |
| heap-functional | reussir-nrac | 965.535 | 2.89138 | 10 | 5.99609 | complete | false | hyperfine |
| heap-functional | rust | 2329.93 | 1.22869 | 10 | 7.86328 | complete | false | hyperfine |
| heap-functional | rust-with-mimalloc | 2642.41 | 3.33909 | 10 | 12.1758 | complete | false | hyperfine |
| mltt | haskell | 543.307 | 0.730202 | 10 | 17.3164 | complete | false | hyperfine |
| mltt | haskell-a1g | 1732.39 | 4.99199 | 10 | 60.1953 | complete | false | hyperfine |
| mltt | koka | 830.462 | 2.83885 | 10 | 11.8906 | complete | false | hyperfine |
| mltt | lean | 762.507 | 0.19719 | 10 | 15.5977 | complete | false | hyperfine |
| mltt | ocaml | 554.399 | 0.399312 | 10 | 18.293 | complete | false | hyperfine |
| mltt | reussir | 562.907 | 0.568339 | 10 | 12.5234 | complete | false | hyperfine |
| mltt | reussir-nrac | 575.538 | 2.47429 | 10 | 12.582 | complete | false | hyperfine |
| mltt | rust | 736.262 | 1.06896 | 10 | 29.2695 | complete | false | hyperfine |
| mltt | rust-with-mimalloc | 571.436 | 1.36612 | 10 | 31.9492 | complete | false | hyperfine |
| nbe-closure | haskell | 106.796 | 0.405532 | 10 | 83.3398 | complete | false | hyperfine |
| nbe-closure | haskell-a1g | 59.7129 | 0.273413 | 10 | 121.125 | complete | false | hyperfine |
| nbe-closure | koka | 180.271 | 1.60749 | 10 | 41.9766 | complete | false | hyperfine |
| nbe-closure | lean | 84.6803 | 0.129955 | 10 | 167.996 | complete | false | hyperfine |
| nbe-closure | morphic | 409.548 | 1.31835 | 10 | 168.84 | complete | false | hyperfine |
| nbe-closure | ocaml | 715.978 | 1.08067 | 10 | 129.77 | complete | false | hyperfine |
| nbe-closure | reussir | 157.679 | 0.107005 | 10 | 42.3398 | complete | false | hyperfine |
| nbe-closure | reussir-nrac | 173.331 | 0.949142 | 10 | 66.2812 | complete | false | hyperfine |
| nbe-closure | rust | 846.08 | 1.83512 | 10 | 444.086 | complete | false | hyperfine |
| nbe-closure | rust-with-mimalloc | 471.333 | 0.674138 | 10 | 386.551 | complete | false | hyperfine |
| nbe-hoas | haskell | 106.546 | 0.51357 | 10 | 79.2773 | complete | false | hyperfine |
| nbe-hoas | haskell-a1g | 76.9316 | 0.655336 | 10 | 165.031 | complete | false | hyperfine |
| nbe-hoas | koka | 168.293 | 2.0903 | 10 | 41.9766 | complete | false | hyperfine |
| nbe-hoas | lean | 82.0312 | 0.191275 | 10 | 152.734 | complete | false | hyperfine |
| nbe-hoas | morphic | 366.865 | 1.82352 | 10 | 153.527 | complete | false | hyperfine |
| nbe-hoas | ocaml | 572.992 | 2.23965 | 10 | 134.113 | complete | false | hyperfine |
| nbe-hoas | reussir | 179.404 | 0.969397 | 10 | 42.3477 | complete | false | hyperfine |
| nbe-hoas | reussir-nrac | 190.942 | 0.643636 | 10 | 66.3477 | complete | false | hyperfine |
| nbe-hoas | rust | 739.435 | 4.26285 | 10 | 428.93 | complete | false | hyperfine |
| nbe-hoas | rust-with-mimalloc | 446.321 | 7.69202 | 10 | 371.293 | complete | false | hyperfine |
| rbtree | haskell | 437.554 | 0.524666 | 10 | 174.398 | complete | false | hyperfine |
| rbtree | haskell-a1g | 797.777 | 5.76704 | 10 | 1175.34 | complete | false | hyperfine |
| rbtree | koka | 191.713 | 0.411722 | 10 | 100.152 | complete | false | hyperfine |
| rbtree | lean | 695.773 | 0.372078 | 10 | 123.547 | complete | false | hyperfine |
| rbtree | morphic | 1377.38 | 2.88507 | 10 | 191.648 | complete | false | hyperfine |
| rbtree | ocaml | 421.018 | 2.47634 | 10 | 183.23 | complete | false | hyperfine |
| rbtree | reussir | 237.716 | 0.374165 | 10 | 98.2148 | complete | false | hyperfine |
| rbtree | reussir-nrac | 402.651 | 0.207522 | 10 | 98.2148 | complete | false | hyperfine |
| rbtree | rust | 2822.91 | 41.1777 | 10 | 4963.15 | complete | false | hyperfine |
| rbtree | rust-with-mimalloc | 1350.89 | 5.823 | 10 | 3799.51 | complete | false | hyperfine |
| rbtree-zipper | haskell | 538.623 | 0.587276 | 10 | 159.406 | complete | false | hyperfine |
| rbtree-zipper | haskell-a1g | 1010.17 | 5.76104 | 10 | 1168 | complete | false | hyperfine |
| rbtree-zipper | koka | 242.881 | 0.471705 | 10 | 100.152 | complete | false | hyperfine |
| rbtree-zipper | lean | 349.727 | 0.210266 | 10 | 123.5 | complete | false | hyperfine |
| rbtree-zipper | morphic | 1646.78 | 19.3299 | 10 | 191.648 | complete | false | hyperfine |
| rbtree-zipper | ocaml | 457.881 | 0.590141 | 10 | 183.543 | complete | false | hyperfine |
| rbtree-zipper | reussir | 196.761 | 0.434874 | 10 | 98.0781 | complete | false | hyperfine |
| rbtree-zipper | reussir-nrac | 196.801 | 0.219343 | 10 | 97.9961 | complete | false | hyperfine |
| rbtree-zipper | rust | 3746.72 | 88.7048 | 10 | 5192.05 | complete | false | hyperfine |
| rbtree-zipper | rust-with-mimalloc | 2142.87 | 1.32799 | 10 | 4028.44 | complete | false | hyperfine |

## Large aggregates

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| heap-array | haskell-st | 930.581 | 0.575726 | 10 | 8.14844 | complete | false | hyperfine |
| heap-array | haskell-st-a1g | 1229.91 | 4.60482 | 10 | 1044.24 | complete | false | hyperfine |
| heap-array | koka | 2568.45 | 5.02091 | 10 | 4.12109 | complete | false | hyperfine |
| heap-array | lean | 1462.21 | 6.9298 | 10 | 14.7578 | complete | false | hyperfine |
| heap-array | morphic | 789.255 | 0.749001 | 10 | 1.14844 | complete | false | hyperfine |
| heap-array | ocaml | 1701.84 | 3.22498 | 10 | 15.7305 | complete | false | hyperfine |
| heap-array | reussir | 338.974 | 0.196098 | 10 | 3.99609 | complete | false | hyperfine |
| heap-array | reussir-nrac | 338.783 | 0.184287 | 10 | 3.99609 | complete | false | hyperfine |
| heap-array | rust | 332.381 | 0.21494 | 10 | 2.05469 | complete | false | hyperfine |
| heap-array | rust-with-mimalloc | 332.032 | 0.193875 | 10 | 6.16797 | complete | false | hyperfine |
| life | haskell | 1798.62 | 0.51113 | 10 | 9.36328 | complete | false | hyperfine |
| life | haskell-a1g | 2099.69 | 3.66032 | 10 | 1015.81 | complete | false | hyperfine |
| life | haskell-st | 1439.42 | 0.434221 | 10 | 3.77734 | complete | false | hyperfine |
| life | haskell-st-a1g | 1446.72 | 0.718584 | 10 | 20.0273 | complete | false | hyperfine |
| life | koka | 4614.97 | 10.0312 | 10 | 4.12109 | complete | false | hyperfine |
| life | lean | 4423.31 | 3.83417 | 10 | 10.1562 | complete | false | hyperfine |
| life | morphic | 779.638 | 0.237605 | 10 | 0.867188 | complete | false | hyperfine |
| life | ocaml | 2073 | 0.799183 | 10 | 6.39844 | complete | false | hyperfine |
| life | reussir | 216.745 | 1.91164 | 10 | 3.99609 | complete | false | hyperfine |
| life | reussir-nrac | 215.923 | 0.163893 | 10 | 3.99609 | complete | false | hyperfine |
| life | rust | 208.562 | 0.163334 | 10 | 1.58594 | complete | false | hyperfine |
| life | rust-with-mimalloc | 208.754 | 0.196015 | 10 | 6.16797 | complete | false | hyperfine |
| qsort | haskell | 2803.88 | 1.91506 | 10 | 29.082 | complete | false | hyperfine |
| qsort | haskell-a1g | 2262.44 | 6.97275 | 10 | 1052.44 | complete | false | hyperfine |
| qsort | haskell-st | 459.429 | 0.803333 | 10 | 9.37109 | complete | false | hyperfine |
| qsort | haskell-st-a1g | 478.862 | 0.838579 | 10 | 71.7461 | complete | false | hyperfine |
| qsort | koka | 947.227 | 0.463279 | 10 | 10.125 | complete | false | hyperfine |
| qsort | lean | 1141.63 | 14.6488 | 10 | 11.8164 | complete | false | hyperfine |
| qsort | morphic | 520.32 | 4.34008 | 10 | 1.43359 | complete | false | hyperfine |
| qsort | ocaml | 1138.78 | 2.22627 | 10 | 8.39453 | complete | false | hyperfine |
| qsort | reussir | 239.743 | 0.285271 | 10 | 3.99609 | complete | false | hyperfine |
| qsort | reussir-nrac | 239.678 | 0.074627 | 10 | 3.99609 | complete | false | hyperfine |
| qsort | rust | 204.584 | 0.307638 | 10 | 2.16406 | complete | false | hyperfine |
| qsort | rust-with-mimalloc | 204.913 | 0.404877 | 10 | 6.16797 | complete | false | hyperfine |
| raytracer | haskell | 189.469 | 0.147763 | 10 | 7.90625 | complete | false | hyperfine |
| raytracer | haskell-a1g | 239.13 | 0.272661 | 10 | 89.25 | complete | false | hyperfine |
| raytracer | koka | 341.933 | 1.01267 | 10 | 4.37109 | complete | false | hyperfine |
| raytracer | lean | 976.066 | 0.99078 | 10 | 10.543 | complete | false | hyperfine |
| raytracer | ocaml | 126.718 | 0.102774 | 10 | 11.2305 | complete | false | hyperfine |
| raytracer | reussir | 71.4252 | 0.10235 | 10 | 4.19531 | complete | false | hyperfine |
| raytracer | reussir-nrac | 71.5595 | 0.171947 | 10 | 4.36719 | complete | false | hyperfine |
| raytracer | rust | 72.5535 | 0.0601076 | 10 | 2.17578 | complete | false | hyperfine |
| raytracer | rust-with-mimalloc | 72.7411 | 0.0437558 | 10 | 6.55078 | complete | false | hyperfine |

## Standard-library collections

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hash-map-heavily-shared | haskell | 3928.91 | 3.61581 | 10 | 279.34 | complete | false | hyperfine |
| hash-map-heavily-shared | haskell-a1g | 3006.18 | 8.02403 | 10 | 1227.93 | complete | false | hyperfine |
| hash-map-heavily-shared | koka | 60064.5 | — | 1 | 634.949 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | lean | 73955 | 339.665 | 2 | 257.559 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | morphic | 153070 | — | 1 | 548.781 | budget_limited | true | gnu-time |
| hash-map-heavily-shared | ocaml | X (takes too long) | — | 0 | X (takes too long) | budget_exhausted | true | — |
| hash-map-heavily-shared | reussir | 3811.83 | 170.38 | 10 | 77.9844 | complete | false | hyperfine |
| hash-map-heavily-shared | reussir-nrac | 3784.8 | 37.2459 | 10 | 78.2305 | complete | false | hyperfine |
| hash-map-heavily-shared | rust | 40599.2 | 476.726 | 2 | 358.824 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | rust-rpds | 7213.1 | 24.7396 | 10 | 163.801 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-rpds-with-mimalloc | 5008.94 | 6.56202 | 10 | 148.195 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-with-mimalloc | 8293.87 | 18.5325 | 10 | 486.051 | complete | false | hyperfine |
| hash-map-linear | haskell | 2741.22 | 3.36747 | 10 | 264.34 | complete | false | hyperfine |
| hash-map-linear | haskell-a1g | 2777.95 | 9.38922 | 10 | 1222.62 | complete | false | hyperfine |
| hash-map-linear | koka | 1346.89 | 13.5201 | 10 | 584.109 | complete | false | hyperfine |
| hash-map-linear | lean | 1074.72 | 1.14642 | 10 | 96.4727 | complete | false | hyperfine |
| hash-map-linear | morphic | 835.059 | 8.87107 | 10 | 116.324 | complete | false | hyperfine |
| hash-map-linear | ocaml | 1922.76 | 17.6611 | 10 | 138.531 | complete | false | hyperfine |
| hash-map-linear | reussir | 969.313 | 1.84479 | 10 | 70.2266 | complete | false | hyperfine |
| hash-map-linear | reussir-nrac | 998.165 | 1.07598 | 10 | 70.2812 | complete | false | hyperfine |
| hash-map-linear | rust | 224.255 | 0.872683 | 10 | 52.7461 | complete | false | hyperfine |
| hash-map-linear | rust-rpds | 1541.43 | 3.86195 | 10 | 157.863 | complete | false | hyperfine |
| hash-map-linear | rust-rpds-with-mimalloc | 1353.82 | 3.34427 | 10 | 140.199 | complete | false | hyperfine |
| hash-map-linear | rust-with-mimalloc | 197.317 | 0.88728 | 10 | 82.1875 | complete | false | hyperfine |
| hash-map-shared | haskell | 3387.47 | 1.97031 | 10 | 321.996 | complete | false | hyperfine |
| hash-map-shared | haskell-a1g | 3211.48 | 9.43463 | 10 | 1255.12 | complete | false | hyperfine |
| hash-map-shared | koka | 5641.29 | 28.4249 | 10 | 629.703 | complete | false | hyperfine |
| hash-map-shared | lean | 6548.87 | 10.6963 | 10 | 278.523 | complete | false | hyperfine |
| hash-map-shared | morphic | 12735.3 | 17.4617 | 10 | 565.59 | complete | false | hyperfine |
| hash-map-shared | ocaml | 71710 | 2.18779 | 2 | 922.879 | budget_limited | true | hyperfine |
| hash-map-shared | reussir | 3411.97 | 8.41236 | 10 | 110.176 | complete | false | hyperfine |
| hash-map-shared | reussir-nrac | 3448.01 | 9.48395 | 10 | 110.043 | complete | false | hyperfine |
| hash-map-shared | rust | 2767.23 | 10.438 | 10 | 358.801 | complete | false | hyperfine |
| hash-map-shared | rust-rpds | 6768.35 | 24.3422 | 10 | 190.961 | complete | false | hyperfine |
| hash-map-shared | rust-rpds-with-mimalloc | 4131.71 | 12.4394 | 10 | 172.203 | complete | false | hyperfine |
| hash-map-shared | rust-with-mimalloc | 752.09 | 4.86598 | 10 | 518.238 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell | 7097.98 | 6.06511 | 10 | 2870.43 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell-a1g | 4181.17 | 2.51099 | 10 | 2165.59 | complete | false | hyperfine |
| ordered-map-heavily-shared | koka | 1667.73 | 2.32624 | 10 | 32.2969 | complete | false | hyperfine |
| ordered-map-heavily-shared | lean | 3002.57 | 3.18239 | 10 | 84.3594 | complete | false | hyperfine |
| ordered-map-heavily-shared | morphic | 3717.96 | 7.1397 | 10 | 48.2188 | complete | false | hyperfine |
| ordered-map-heavily-shared | ocaml | 3086.78 | 2.79061 | 10 | 95.2617 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir | 1389.66 | 1.07133 | 10 | 32.2305 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir-nrac | 1394.82 | 1.81358 | 10 | 32.043 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust | 10523.2 | 27.7883 | 10 | 126.742 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds | 4209.01 | 6.68882 | 10 | 73.1484 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds-with-mimalloc | 2536.35 | 3.3609 | 10 | 58.1719 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-with-mimalloc | 8868.71 | 53.2623 | 10 | 123.934 | complete | false | hyperfine |
| ordered-map-linear | haskell | 2391.63 | 2.63319 | 10 | 110.336 | complete | false | hyperfine |
| ordered-map-linear | haskell-a1g | 2296.85 | 5.57536 | 10 | 1093.62 | complete | false | hyperfine |
| ordered-map-linear | koka | 740.228 | 0.86513 | 10 | 24.2852 | complete | false | hyperfine |
| ordered-map-linear | lean | 1728.71 | 1.99119 | 10 | 72.3398 | complete | false | hyperfine |
| ordered-map-linear | morphic | 1890.32 | 2.55961 | 10 | 34.9375 | complete | false | hyperfine |
| ordered-map-linear | ocaml | 2557.05 | 2.22265 | 10 | 84.6367 | complete | false | hyperfine |
| ordered-map-linear | reussir | 639.495 | 0.379895 | 10 | 24.2188 | complete | false | hyperfine |
| ordered-map-linear | reussir-nrac | 648.712 | 0.47232 | 10 | 24.0352 | complete | false | hyperfine |
| ordered-map-linear | rust | 281.216 | 0.358895 | 10 | 14.0859 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds | 2024.02 | 3.88318 | 10 | 56.1172 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds-with-mimalloc | 1427.82 | 19.2067 | 10 | 46.1719 | complete | false | hyperfine |
| ordered-map-linear | rust-with-mimalloc | 252.819 | 0.487964 | 10 | 16.168 | complete | false | hyperfine |
| ordered-map-shared | haskell | 7104.59 | 8.7724 | 10 | 2870.43 | complete | false | hyperfine |
| ordered-map-shared | haskell-a1g | 4188.91 | 3.43899 | 10 | 2165.59 | complete | false | hyperfine |
| ordered-map-shared | koka | 1904.76 | 5.19555 | 10 | 60.2969 | complete | false | hyperfine |
| ordered-map-shared | lean | 2978.28 | 3.06386 | 10 | 131.898 | complete | false | hyperfine |
| ordered-map-shared | morphic | 4108.65 | 8.84807 | 10 | 97.2812 | complete | false | hyperfine |
| ordered-map-shared | ocaml | 2994.92 | 6.93945 | 10 | 150.105 | complete | false | hyperfine |
| ordered-map-shared | reussir | 1559.27 | 0.945611 | 10 | 58.2305 | complete | false | hyperfine |
| ordered-map-shared | reussir-nrac | 1569.11 | 7.22225 | 10 | 58.2305 | complete | false | hyperfine |
| ordered-map-shared | rust | 1037.74 | 3.59046 | 10 | 126.43 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds | 4031.25 | 8.88696 | 10 | 128.93 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds-with-mimalloc | 2533.2 | 1.51104 | 10 | 100.18 | complete | false | hyperfine |
| ordered-map-shared | rust-with-mimalloc | 803.563 | 4.34211 | 10 | 130.184 | complete | false | hyperfine |

## Arbitrary-precision integers

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| bigint-binomial | haskell | 1436.49 | 2.10284 | 10 | 15.6641 | complete | false | hyperfine |
| bigint-binomial | haskell-a1g | 1935.23 | 4.73967 | 10 | 1284.41 | complete | false | hyperfine |
| bigint-binomial | koka | 9161.66 | 78.2458 | 10 | 6.05859 | complete | false | hyperfine |
| bigint-binomial | lean | 1808.12 | 3.28759 | 10 | 10.3945 | complete | false | hyperfine |
| bigint-binomial | ocaml | 1463.38 | 4.32887 | 10 | 14.6484 | complete | false | hyperfine |
| bigint-binomial | reussir | 1353.94 | 0.860922 | 10 | 6.11328 | complete | false | hyperfine |
| bigint-binomial | reussir-nrac | 1354.76 | 3.46956 | 10 | 6.09766 | complete | false | hyperfine |
| bigint-binomial | rust | 5273.44 | 3.71099 | 10 | 2.17188 | complete | false | hyperfine |
| bigint-binomial | rust-with-mimalloc | 5276.39 | 3.23183 | 10 | 6.54688 | complete | false | hyperfine |
| bigint-collatz | haskell | 1366.41 | 10.9338 | 10 | 7.68359 | complete | false | hyperfine |
| bigint-collatz | haskell-a1g | 1665.74 | 12.958 | 10 | 1043.78 | complete | false | hyperfine |
| bigint-collatz | koka | 158.264 | 0.384883 | 10 | 4.11719 | complete | false | hyperfine |
| bigint-collatz | lean | 181.205 | 0.111057 | 10 | 10.0938 | complete | false | hyperfine |
| bigint-collatz | ocaml | 521.532 | 0.581216 | 10 | 3.63672 | complete | false | hyperfine |
| bigint-collatz | reussir | 121.534 | 0.15432 | 10 | 2.19531 | complete | false | hyperfine |
| bigint-collatz | reussir-nrac | 121.61 | 0.162574 | 10 | 2.19531 | complete | false | hyperfine |
| bigint-collatz | rust | 756.362 | 11.5236 | 10 | 1.76953 | complete | false | hyperfine |
| bigint-collatz | rust-with-mimalloc | 753.6 | 8.60393 | 10 | 6.17188 | complete | false | hyperfine |
| bigint-factorial | haskell | 645.719 | 0.715543 | 10 | 14.5742 | complete | false | hyperfine |
| bigint-factorial | haskell-a1g | 1126.68 | 5.94701 | 10 | 1347.39 | complete | false | hyperfine |
| bigint-factorial | koka | 11111.1 | 8.08605 | 10 | 5.99219 | complete | false | hyperfine |
| bigint-factorial | lean | 1189.81 | 1.75116 | 10 | 11.1484 | complete | false | hyperfine |
| bigint-factorial | ocaml | 3548.48 | 3.34249 | 10 | 12732.1 | complete | false | hyperfine |
| bigint-factorial | reussir | 633.139 | 0.740462 | 10 | 7.85938 | complete | false | hyperfine |
| bigint-factorial | reussir-nrac | 633.458 | 0.844328 | 10 | 7.85938 | complete | false | hyperfine |
| bigint-factorial | rust | 992.328 | 43.6852 | 10 | 2.30078 | complete | false | hyperfine |
| bigint-factorial | rust-with-mimalloc | 983.122 | 36.7632 | 10 | 10.5508 | complete | false | hyperfine |
| bigint-fib | haskell | 529.489 | 0.574188 | 10 | 16.6055 | complete | false | hyperfine |
| bigint-fib | haskell-a1g | 1169.91 | 9.2739 | 10 | 1409.57 | complete | false | hyperfine |
| bigint-fib | koka | 2104.44 | 0.812542 | 10 | 5.99219 | complete | false | hyperfine |
| bigint-fib | lean | 1028.09 | 0.359442 | 10 | 10.3945 | complete | false | hyperfine |
| bigint-fib | ocaml | 3888.56 | 7.51141 | 10 | 14921.6 | complete | false | hyperfine |
| bigint-fib | reussir | 499.562 | 0.508224 | 10 | 5.85938 | complete | false | hyperfine |
| bigint-fib | reussir-nrac | 499.803 | 0.537297 | 10 | 5.85938 | complete | false | hyperfine |
| bigint-fib | rust | 1955.49 | 0.696074 | 10 | 2.17188 | complete | false | hyperfine |
| bigint-fib | rust-with-mimalloc | 1955.64 | 0.614554 | 10 | 8.54688 | complete | false | hyperfine |
| bigint-pidigits | haskell | 401.999 | 0.691276 | 10 | 15.668 | complete | false | hyperfine |
| bigint-pidigits | haskell-a1g | 874.105 | 7.74912 | 10 | 1298.79 | complete | false | hyperfine |
| bigint-pidigits | koka | 6906.07 | 3.36045 | 10 | 41.7148 | complete | false | hyperfine |
| bigint-pidigits | lean | 744.972 | 0.828241 | 10 | 10.418 | complete | false | hyperfine |
| bigint-pidigits | ocaml | 653.469 | 0.580086 | 10 | 18.8164 | complete | false | hyperfine |
| bigint-pidigits | reussir | 411.67 | 0.32495 | 10 | 6.22656 | complete | false | hyperfine |
| bigint-pidigits | reussir-nrac | 411.663 | 0.415809 | 10 | 6.22656 | complete | false | hyperfine |
| bigint-pidigits | rust | 2197.2 | 2.6416 | 10 | 2.90625 | complete | false | hyperfine |
| bigint-pidigits | rust-with-mimalloc | 1634.74 | 1.52764 | 10 | 11.7422 | complete | false | hyperfine |
| bigint-rbtree | haskell | 601.413 | 0.798507 | 10 | 179.402 | complete | false | hyperfine |
| bigint-rbtree | haskell-a1g | 986.692 | 5.70554 | 10 | 1216.43 | complete | false | hyperfine |
| bigint-rbtree | koka | 188.383 | 0.96009 | 10 | 117.969 | complete | false | hyperfine |
| bigint-rbtree | lean | 673.751 | 0.342996 | 10 | 123.605 | complete | false | hyperfine |
| bigint-rbtree | ocaml | 361.895 | 0.406534 | 10 | 126.918 | complete | false | hyperfine |
| bigint-rbtree | reussir | 248.357 | 0.923631 | 10 | 118.023 | complete | false | hyperfine |
| bigint-rbtree | reussir-nrac | 406.356 | 0.679622 | 10 | 118.023 | complete | false | hyperfine |
| bigint-rbtree | rust | 3857.64 | 6.55127 | 10 | 7615.74 | complete | false | hyperfine |
| bigint-rbtree | rust-with-mimalloc | 1855.89 | 3.61396 | 10 | 7639.42 | complete | false | hyperfine |

## Traversals of shared data

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| expr-replace | haskell | 354.192 | 5.37211 | 10 | 3.92969 | complete | false | hyperfine |
| expr-replace | haskell-a1g | 366.07 | 10.2724 | 10 | 20.1797 | complete | false | hyperfine |
| expr-replace | koka | 586.102 | 1.90903 | 10 | 3.96094 | complete | false | hyperfine |
| expr-replace | lean | 427.163 | 7.05441 | 10 | 10.043 | complete | false | hyperfine |
| expr-replace | morphic | 289.781 | 0.392029 | 10 | 1.17969 | complete | false | hyperfine |
| expr-replace | ocaml | 309.931 | 1.94016 | 10 | 4.01172 | complete | false | hyperfine |
| expr-replace | reussir | 275.608 | 3.60774 | 10 | 4.26953 | complete | false | hyperfine |
| expr-replace | reussir-nrac | 274.081 | 1.07019 | 10 | 4.26953 | complete | false | hyperfine |
| expr-replace | rust | 360.073 | 0.287181 | 10 | 2.05469 | complete | false | hyperfine |
| expr-replace | rust-with-mimalloc | 357.398 | 4.60926 | 10 | 6.16797 | complete | false | hyperfine |
| list-membership | haskell | 693.923 | 1.48162 | 10 | 3.93359 | complete | false | hyperfine |
| list-membership | haskell-a1g | 701.494 | 1.07067 | 10 | 20.1836 | complete | false | hyperfine |
| list-membership | koka | 339.229 | 0.753992 | 10 | 3.95703 | complete | false | hyperfine |
| list-membership | lean | 353.591 | 0.369046 | 10 | 10.2383 | complete | false | hyperfine |
| list-membership | morphic | 335.543 | 0.431833 | 10 | 1.36328 | complete | false | hyperfine |
| list-membership | ocaml | 347.74 | 0.26821 | 10 | 3.38672 | complete | false | hyperfine |
| list-membership | reussir | 324.028 | 0.250162 | 10 | 3.99609 | complete | false | hyperfine |
| list-membership | reussir-nrac | 324.005 | 0.239068 | 10 | 3.99609 | complete | false | hyperfine |
| list-membership | rust | 340.682 | 0.201464 | 10 | 2.36719 | complete | false | hyperfine |
| list-membership | rust-with-mimalloc | 323.32 | 0.357075 | 10 | 6.32422 | complete | false | hyperfine |
| rbtree-lookup | haskell | 1463.43 | 2.52492 | 10 | 137.836 | complete | false | hyperfine |
| rbtree-lookup | haskell-a1g | 1271.21 | 2.14057 | 10 | 1081.59 | complete | false | hyperfine |
| rbtree-lookup | koka | 528.754 | 3.48537 | 10 | 41.9609 | complete | false | hyperfine |
| rbtree-lookup | lean | 1132.29 | 19.9799 | 10 | 55.0703 | complete | false | hyperfine |
| rbtree-lookup | morphic | 1634.33 | 0.860859 | 10 | 77.1172 | complete | false | hyperfine |
| rbtree-lookup | ocaml | 1895.88 | 1.7887 | 10 | 129.168 | complete | false | hyperfine |
| rbtree-lookup | reussir | 453.665 | 0.539519 | 10 | 42.2148 | complete | false | hyperfine |
| rbtree-lookup | reussir-nrac | 896.217 | 0.628264 | 10 | 42.2148 | complete | false | hyperfine |
| rbtree-lookup | rust | 1681.87 | 12.3415 | 10 | 123.773 | complete | false | hyperfine |
| rbtree-lookup | rust-with-mimalloc | 1878 | 2.08287 | 10 | 96.1797 | complete | false | hyperfine |
