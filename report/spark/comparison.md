# spark default benchmark comparison

spark: 279 default cases accounted for; timing 278/279, footprint 278/279. Statuses: budget_exhausted=1, budget_limited=5, complete=273.

Time and RSS ratios are variant / default Reussir: above 1 means slower or more memory. Geometric means use only complete, non-budget-limited pairs with positive measurements. Timing and memory coverage can differ. X means takes too long (no completed measurement within 5 minutes). Blank CSV cells and — mean unavailable for other reasons; a single timing sample has no standard deviation.

Reussir: `bcfff8d419169a09509b963714de0675630c7bc1`. Baseline benchmark: `959c9ac4e1e956c8b7acff44f6298b6d52d46c15`. Raytracer benchmark: `2e1ec4fe82558112529c872733d3162a6e887e05`. Architecture: aarch64; measurement CPU: 19.

Compiler and runtime hashes are recorded in `provenance/manifest.json`. The compiler hash identifies the native ELF; the compiler launcher environment is recorded separately in `provenance/compiler-launch-environment.json`.

## Complete paired comparisons

| Variant | Available pairs | Timing pairs | Time / Reussir | Memory pairs | RSS / Reussir |
| --- | --- | --- | --- | --- | --- |
| haskell | 26 | 26 | 2.21506 | 26 | 2.99524 |
| haskell-a1g | 26 | 26 | 2.49632 | 26 | 33.7939 |
| haskell-st | 3 | 3 | 3.27116 | 3 | 1.65234 |
| haskell-st-a1g | 3 | 3 | 3.6459 | 3 | 28.6302 |
| koka | 27 | 26 | 2.19426 | 26 | 1.3179 |
| lean | 27 | 26 | 2.22038 | 26 | 2.14176 |
| morphic | 20 | 19 | 2.53106 | 19 | 1.07803 |
| ocaml | 27 | 25 | 2.70957 | 25 | 1.85625 |
| reussir | 27 | 27 | 1 | 27 | 1 |
| reussir-nrac | 27 | 27 | 1.09871 | 27 | 1.0367 |
| rust | 27 | 26 | 2.37664 | 26 | 1.67496 |
| rust-rpds | 6 | 6 | 2.34025 | 6 | 2.14116 |
| rust-rpds-with-mimalloc | 6 | 6 | 1.60096 | 6 | 1.81264 |
| rust-with-mimalloc | 27 | 27 | 1.90216 | 27 | 3.01877 |

## Functional data structures

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| derive | haskell | 699.574 | 0.877911 | 10 | 572.242 | complete | false | hyperfine |
| derive | haskell-a1g | 269.829 | 1.67633 | 10 | 634.715 | complete | false | hyperfine |
| derive | koka | 255.745 | 0.52862 | 10 | 456.145 | complete | false | hyperfine |
| derive | lean | 279.008 | 0.501739 | 10 | 553.266 | complete | false | hyperfine |
| derive | morphic | 596.163 | 1.54492 | 10 | 765.242 | complete | false | hyperfine |
| derive | ocaml | 609.28 | 2.86114 | 10 | 420.641 | complete | false | hyperfine |
| derive | reussir | 239.155 | 0.725069 | 10 | 456.418 | complete | false | hyperfine |
| derive | reussir-nrac | 238.813 | 0.527245 | 10 | 456.156 | complete | false | hyperfine |
| derive | rust | 1096.3 | 3.57177 | 10 | 1530.02 | complete | false | hyperfine |
| derive | rust-with-mimalloc | 545.098 | 0.686226 | 10 | 1536.41 | complete | false | hyperfine |
| fingertree | haskell | 81.0348 | 0.261434 | 10 | 15.3359 | complete | false | hyperfine |
| fingertree | haskell-a1g | 257.216 | 1.91909 | 10 | 683.93 | complete | false | hyperfine |
| fingertree | koka | 50.8189 | 7.02968 | 10 | 5.97266 | complete | false | hyperfine |
| fingertree | lean | 69.1569 | 0.371001 | 10 | 14.0391 | complete | false | hyperfine |
| fingertree | morphic | 55.5025 | 0.142029 | 10 | 2.90234 | complete | false | hyperfine |
| fingertree | ocaml | 48.4585 | 0.151323 | 10 | 16.582 | complete | false | hyperfine |
| fingertree | reussir | 30.9344 | 0.102407 | 10 | 6.07812 | complete | false | hyperfine |
| fingertree | reussir-nrac | 33.9351 | 0.165469 | 10 | 6.15234 | complete | false | hyperfine |
| fingertree | rust | 57.1122 | 0.265401 | 10 | 7.67578 | complete | false | hyperfine |
| fingertree | rust-with-mimalloc | 56.7188 | 0.236729 | 10 | 10.168 | complete | false | hyperfine |
| functional-queue | haskell | 39.4057 | 0.258684 | 10 | 13.4609 | complete | false | hyperfine |
| functional-queue | haskell-a1g | 87.1812 | 0.513661 | 10 | 267.211 | complete | false | hyperfine |
| functional-queue | koka | 59.7767 | 0.222172 | 10 | 5.98047 | complete | false | hyperfine |
| functional-queue | lean | 61.7077 | 0.250472 | 10 | 14.0391 | complete | false | hyperfine |
| functional-queue | morphic | 73.372 | 0.427251 | 10 | 5.71484 | complete | false | hyperfine |
| functional-queue | ocaml | 81.7642 | 0.195538 | 10 | 16.1133 | complete | false | hyperfine |
| functional-queue | reussir | 36.9353 | 0.147327 | 10 | 5.99219 | complete | false | hyperfine |
| functional-queue | reussir-nrac | 36.9161 | 0.0690453 | 10 | 6.01562 | complete | false | hyperfine |
| functional-queue | rust | 70.0909 | 0.55063 | 10 | 6.73828 | complete | false | hyperfine |
| functional-queue | rust-with-mimalloc | 62.0688 | 0.668352 | 10 | 8.72656 | complete | false | hyperfine |
| heap-functional | haskell | 1884.01 | 1.24688 | 10 | 13.4609 | complete | false | hyperfine |
| heap-functional | haskell-a1g | 1886.58 | 4.38463 | 10 | 1050.43 | complete | false | hyperfine |
| heap-functional | koka | 568.234 | 0.350276 | 10 | 5.96875 | complete | false | hyperfine |
| heap-functional | lean | 1199.39 | 6.76026 | 10 | 14.043 | complete | false | hyperfine |
| heap-functional | morphic | 2466.06 | 11.827 | 10 | 4.92969 | complete | false | hyperfine |
| heap-functional | ocaml | 2595.61 | 7.0773 | 10 | 16.918 | complete | false | hyperfine |
| heap-functional | reussir | 570.78 | 0.529345 | 10 | 5.98047 | complete | false | hyperfine |
| heap-functional | reussir-nrac | 969.552 | 0.39382 | 10 | 5.98047 | complete | false | hyperfine |
| heap-functional | rust | 2378.02 | 1.40796 | 10 | 7.67578 | complete | false | hyperfine |
| heap-functional | rust-with-mimalloc | 2654.64 | 2.79324 | 10 | 12.168 | complete | false | hyperfine |
| nbe-closure | haskell | 106.796 | 0.405532 | 10 | 83.3398 | complete | false | hyperfine |
| nbe-closure | haskell-a1g | 59.7129 | 0.273413 | 10 | 121.125 | complete | false | hyperfine |
| nbe-closure | koka | 180.271 | 1.60749 | 10 | 41.9766 | complete | false | hyperfine |
| nbe-closure | lean | 83.8853 | 0.320741 | 10 | 167.941 | complete | false | hyperfine |
| nbe-closure | morphic | 409.548 | 1.31835 | 10 | 168.84 | complete | false | hyperfine |
| nbe-closure | ocaml | 948.175 | 27.8756 | 10 | 153.004 | complete | false | hyperfine |
| nbe-closure | reussir | 157.867 | 0.255532 | 10 | 42.2773 | complete | false | hyperfine |
| nbe-closure | reussir-nrac | 174.087 | 1.01049 | 10 | 66.207 | complete | false | hyperfine |
| nbe-closure | rust | 844.129 | 2.19623 | 10 | 444.082 | complete | false | hyperfine |
| nbe-closure | rust-with-mimalloc | 479.265 | 2.95975 | 10 | 386.551 | complete | false | hyperfine |
| nbe-hoas | haskell | 106.546 | 0.51357 | 10 | 79.2773 | complete | false | hyperfine |
| nbe-hoas | haskell-a1g | 76.9316 | 0.655336 | 10 | 165.031 | complete | false | hyperfine |
| nbe-hoas | koka | 168.293 | 2.0903 | 10 | 41.9766 | complete | false | hyperfine |
| nbe-hoas | lean | 86.171 | 1.5247 | 10 | 167.941 | complete | false | hyperfine |
| nbe-hoas | morphic | 366.865 | 1.82352 | 10 | 153.527 | complete | false | hyperfine |
| nbe-hoas | ocaml | 819.925 | 1.11998 | 10 | 146.848 | complete | false | hyperfine |
| nbe-hoas | reussir | 179.124 | 0.937217 | 10 | 42.4102 | complete | false | hyperfine |
| nbe-hoas | reussir-nrac | 190.918 | 0.820559 | 10 | 66.1484 | complete | false | hyperfine |
| nbe-hoas | rust | 740.921 | 1.73395 | 10 | 428.926 | complete | false | hyperfine |
| nbe-hoas | rust-with-mimalloc | 454.602 | 8.99402 | 10 | 371.293 | complete | false | hyperfine |
| rbtree | haskell | 437.554 | 0.524666 | 10 | 174.398 | complete | false | hyperfine |
| rbtree | haskell-a1g | 797.777 | 5.76704 | 10 | 1175.34 | complete | false | hyperfine |
| rbtree | koka | 191.713 | 0.411722 | 10 | 100.152 | complete | false | hyperfine |
| rbtree | lean | 819.6 | 0.931045 | 10 | 123.609 | complete | false | hyperfine |
| rbtree | morphic | 1377.38 | 2.88507 | 10 | 191.648 | complete | false | hyperfine |
| rbtree | ocaml | 416.275 | 0.745568 | 10 | 177.516 | complete | false | hyperfine |
| rbtree | reussir | 237.959 | 0.602774 | 10 | 98.2773 | complete | false | hyperfine |
| rbtree | reussir-nrac | 403.414 | 0.349221 | 10 | 98.2773 | complete | false | hyperfine |
| rbtree | rust | 2854.1 | 53.2644 | 10 | 4963.14 | complete | false | hyperfine |
| rbtree | rust-with-mimalloc | 1384.79 | 3.32285 | 10 | 3799.51 | complete | false | hyperfine |
| rbtree-zipper | haskell | 538.623 | 0.587276 | 10 | 159.406 | complete | false | hyperfine |
| rbtree-zipper | haskell-a1g | 1010.17 | 5.76104 | 10 | 1168 | complete | false | hyperfine |
| rbtree-zipper | koka | 242.881 | 0.471705 | 10 | 100.152 | complete | false | hyperfine |
| rbtree-zipper | lean | 423.124 | 0.682461 | 10 | 123.602 | complete | false | hyperfine |
| rbtree-zipper | morphic | 1646.78 | 19.3299 | 10 | 191.648 | complete | false | hyperfine |
| rbtree-zipper | ocaml | 469.069 | 0.978634 | 10 | 179.078 | complete | false | hyperfine |
| rbtree-zipper | reussir | 197.045 | 0.546023 | 10 | 98.0039 | complete | false | hyperfine |
| rbtree-zipper | reussir-nrac | 197.083 | 0.663109 | 10 | 97.9844 | complete | false | hyperfine |
| rbtree-zipper | rust | 3851.56 | 65.0106 | 10 | 5192.05 | complete | false | hyperfine |
| rbtree-zipper | rust-with-mimalloc | 2200.69 | 2.06628 | 10 | 4028.45 | complete | false | hyperfine |

## Large aggregates

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| heap-array | haskell-st | 930.581 | 0.575726 | 10 | 8.14844 | complete | false | hyperfine |
| heap-array | haskell-st-a1g | 1229.91 | 4.60482 | 10 | 1044.24 | complete | false | hyperfine |
| heap-array | koka | 2568.45 | 5.02091 | 10 | 4.12109 | complete | false | hyperfine |
| heap-array | lean | 1484.1 | 0.778498 | 10 | 14.5195 | complete | false | hyperfine |
| heap-array | morphic | 789.255 | 0.749001 | 10 | 1.14844 | complete | false | hyperfine |
| heap-array | ocaml | 2859.27 | 5.00976 | 10 | 9.88672 | complete | false | hyperfine |
| heap-array | reussir | 339.12 | 0.460696 | 10 | 4.00781 | complete | false | hyperfine |
| heap-array | reussir-nrac | 339.092 | 0.41257 | 10 | 4.00781 | complete | false | hyperfine |
| heap-array | rust | 234.428 | 0.393809 | 10 | 1.86719 | complete | false | hyperfine |
| heap-array | rust-with-mimalloc | 233.333 | 0.318134 | 10 | 6.16797 | complete | false | hyperfine |
| life | haskell | 1798.62 | 0.51113 | 10 | 9.36328 | complete | false | hyperfine |
| life | haskell-a1g | 2099.69 | 3.66032 | 10 | 1015.81 | complete | false | hyperfine |
| life | haskell-st | 1439.42 | 0.434221 | 10 | 3.77734 | complete | false | hyperfine |
| life | haskell-st-a1g | 1446.72 | 0.718584 | 10 | 20.0273 | complete | false | hyperfine |
| life | koka | 4614.97 | 10.0312 | 10 | 4.12109 | complete | false | hyperfine |
| life | lean | 3264.44 | 1.47679 | 10 | 10.1133 | complete | false | hyperfine |
| life | morphic | 779.638 | 0.237605 | 10 | 0.867188 | complete | false | hyperfine |
| life | ocaml | 1637.54 | 0.594778 | 10 | 3.60938 | complete | false | hyperfine |
| life | reussir | 215.995 | 0.243027 | 10 | 4.00391 | complete | false | hyperfine |
| life | reussir-nrac | 215.938 | 0.231274 | 10 | 4.00391 | complete | false | hyperfine |
| life | rust | 208.639 | 0.513133 | 10 | 1.58203 | complete | false | hyperfine |
| life | rust-with-mimalloc | 209.065 | 0.382992 | 10 | 6.16797 | complete | false | hyperfine |
| qsort | haskell | 2803.88 | 1.91506 | 10 | 29.082 | complete | false | hyperfine |
| qsort | haskell-a1g | 2262.44 | 6.97275 | 10 | 1052.44 | complete | false | hyperfine |
| qsort | haskell-st | 459.429 | 0.803333 | 10 | 9.37109 | complete | false | hyperfine |
| qsort | haskell-st-a1g | 478.862 | 0.838579 | 10 | 71.7461 | complete | false | hyperfine |
| qsort | koka | 947.227 | 0.463279 | 10 | 10.125 | complete | false | hyperfine |
| qsort | lean | 1038.6 | 0.75394 | 10 | 11.6484 | complete | false | hyperfine |
| qsort | morphic | 520.32 | 4.34008 | 10 | 1.43359 | complete | false | hyperfine |
| qsort | ocaml | 1220.38 | 5.51289 | 10 | 4.66797 | complete | false | hyperfine |
| qsort | reussir | 240.026 | 0.509368 | 10 | 3.98438 | complete | false | hyperfine |
| qsort | reussir-nrac | 239.813 | 0.296135 | 10 | 4.00781 | complete | false | hyperfine |
| qsort | rust | 211.824 | 0.376305 | 10 | 2.16406 | complete | false | hyperfine |
| qsort | rust-with-mimalloc | 211.738 | 0.509828 | 10 | 6.16797 | complete | false | hyperfine |
| raytracer | haskell | 189.469 | 0.147763 | 10 | 7.90625 | complete | false | hyperfine |
| raytracer | haskell-a1g | 239.13 | 0.272661 | 10 | 89.25 | complete | false | hyperfine |
| raytracer | koka | 341.933 | 1.01267 | 10 | 4.37109 | complete | false | hyperfine |
| raytracer | lean | 2709.8 | 2.88057 | 10 | 9.87109 | complete | false | hyperfine |
| raytracer | ocaml | 395.895 | 0.417297 | 10 | 5.73047 | complete | false | hyperfine |
| raytracer | reussir | 71.6056 | 0.128519 | 10 | 4.36719 | complete | false | hyperfine |
| raytracer | reussir-nrac | 71.6743 | 0.0926614 | 10 | 4.36719 | complete | false | hyperfine |
| raytracer | rust | 71.683 | 0.0434398 | 10 | 2.17578 | complete | false | hyperfine |
| raytracer | rust-with-mimalloc | 71.9342 | 0.0557725 | 10 | 6.55078 | complete | false | hyperfine |

## Standard-library collections

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hash-map-heavily-shared | haskell | 3928.91 | 3.61581 | 10 | 279.34 | complete | false | hyperfine |
| hash-map-heavily-shared | haskell-a1g | 3006.18 | 8.02403 | 10 | 1227.93 | complete | false | hyperfine |
| hash-map-heavily-shared | koka | 60064.5 | — | 1 | 634.949 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | lean | 81712.5 | 57.5 | 2 | 260.227 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | morphic | 153070 | — | 1 | 548.781 | budget_limited | true | gnu-time |
| hash-map-heavily-shared | ocaml | X (takes too long) | — | 0 | X (takes too long) | budget_exhausted | true | — |
| hash-map-heavily-shared | reussir | 3704.46 | 5.04135 | 10 | 78.293 | complete | false | hyperfine |
| hash-map-heavily-shared | reussir-nrac | 3743.21 | 4.88068 | 10 | 78.293 | complete | false | hyperfine |
| hash-map-heavily-shared | rust | 40261 | 4.99857 | 2 | 358.824 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | rust-rpds | 7325.18 | 14.0194 | 10 | 163.801 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-rpds-with-mimalloc | 5136.69 | 8.78592 | 10 | 148.195 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-with-mimalloc | 8328.54 | 20.4493 | 10 | 485.863 | complete | false | hyperfine |
| hash-map-linear | haskell | 2741.22 | 3.36747 | 10 | 264.34 | complete | false | hyperfine |
| hash-map-linear | haskell-a1g | 2777.95 | 9.38922 | 10 | 1222.62 | complete | false | hyperfine |
| hash-map-linear | koka | 1346.89 | 13.5201 | 10 | 584.109 | complete | false | hyperfine |
| hash-map-linear | lean | 1075.16 | 10.6327 | 10 | 96.2852 | complete | false | hyperfine |
| hash-map-linear | morphic | 835.059 | 8.87107 | 10 | 116.324 | complete | false | hyperfine |
| hash-map-linear | ocaml | 1983.36 | 38.0925 | 10 | 159.977 | complete | false | hyperfine |
| hash-map-linear | reussir | 985.34 | 15.5042 | 10 | 70.0781 | complete | false | hyperfine |
| hash-map-linear | reussir-nrac | 998.735 | 1.46056 | 10 | 70.3438 | complete | false | hyperfine |
| hash-map-linear | rust | 222.239 | 1.07255 | 10 | 52.7461 | complete | false | hyperfine |
| hash-map-linear | rust-rpds | 1582.42 | 3.35896 | 10 | 157.68 | complete | false | hyperfine |
| hash-map-linear | rust-rpds-with-mimalloc | 1391.41 | 4.55187 | 10 | 140.191 | complete | false | hyperfine |
| hash-map-linear | rust-with-mimalloc | 196.973 | 1.1245 | 10 | 82.1836 | complete | false | hyperfine |
| hash-map-shared | haskell | 3387.47 | 1.97031 | 10 | 321.996 | complete | false | hyperfine |
| hash-map-shared | haskell-a1g | 3211.48 | 9.43463 | 10 | 1255.12 | complete | false | hyperfine |
| hash-map-shared | koka | 5641.29 | 28.4249 | 10 | 629.703 | complete | false | hyperfine |
| hash-map-shared | lean | 7068.35 | 9.26039 | 10 | 278.383 | complete | false | hyperfine |
| hash-map-shared | morphic | 12735.3 | 17.4617 | 10 | 565.59 | complete | false | hyperfine |
| hash-map-shared | ocaml | 69832.6 | 31.8382 | 2 | 1471.06 | budget_limited | true | hyperfine |
| hash-map-shared | reussir | 3420.01 | 6.58452 | 10 | 109.977 | complete | false | hyperfine |
| hash-map-shared | reussir-nrac | 3455.87 | 11.2128 | 10 | 110.293 | complete | false | hyperfine |
| hash-map-shared | rust | 2763.21 | 5.56836 | 10 | 358.801 | complete | false | hyperfine |
| hash-map-shared | rust-rpds | 6866.15 | 23.0471 | 10 | 191.273 | complete | false | hyperfine |
| hash-map-shared | rust-rpds-with-mimalloc | 4221.17 | 10.0468 | 10 | 172.141 | complete | false | hyperfine |
| hash-map-shared | rust-with-mimalloc | 754.26 | 2.22872 | 10 | 518.234 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell | 7097.98 | 6.06511 | 10 | 2870.43 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell-a1g | 4181.17 | 2.51099 | 10 | 2165.59 | complete | false | hyperfine |
| ordered-map-heavily-shared | koka | 1667.73 | 2.32624 | 10 | 32.2969 | complete | false | hyperfine |
| ordered-map-heavily-shared | lean | 2921.28 | 4.55309 | 10 | 84.2461 | complete | false | hyperfine |
| ordered-map-heavily-shared | morphic | 3717.96 | 7.1397 | 10 | 48.2188 | complete | false | hyperfine |
| ordered-map-heavily-shared | ocaml | 2961.93 | 2.62616 | 10 | 144.418 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir | 1393.27 | 1.21842 | 10 | 32.0938 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir-nrac | 1397.77 | 1.65856 | 10 | 32.0312 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust | 10662.6 | 18.4023 | 10 | 126.555 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds | 4309.35 | 5.28204 | 10 | 73.1484 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds-with-mimalloc | 2626.68 | 3.26691 | 10 | 58.1758 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-with-mimalloc | 9204.24 | 58.0338 | 10 | 123.934 | complete | false | hyperfine |
| ordered-map-linear | haskell | 2391.63 | 2.63319 | 10 | 110.336 | complete | false | hyperfine |
| ordered-map-linear | haskell-a1g | 2296.85 | 5.57536 | 10 | 1093.62 | complete | false | hyperfine |
| ordered-map-linear | koka | 740.228 | 0.86513 | 10 | 24.2852 | complete | false | hyperfine |
| ordered-map-linear | lean | 1648.01 | 1.91702 | 10 | 72.2617 | complete | false | hyperfine |
| ordered-map-linear | morphic | 1890.32 | 2.55961 | 10 | 34.9375 | complete | false | hyperfine |
| ordered-map-linear | ocaml | 2552.23 | 2.45848 | 10 | 131.762 | complete | false | hyperfine |
| ordered-map-linear | reussir | 639.956 | 0.757224 | 10 | 24.0859 | complete | false | hyperfine |
| ordered-map-linear | reussir-nrac | 649.518 | 0.947885 | 10 | 24.0234 | complete | false | hyperfine |
| ordered-map-linear | rust | 279.387 | 0.542492 | 10 | 13.8984 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds | 2025.14 | 4.36507 | 10 | 56.1133 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds-with-mimalloc | 1423.79 | 3.8178 | 10 | 46.1719 | complete | false | hyperfine |
| ordered-map-linear | rust-with-mimalloc | 250.117 | 0.450546 | 10 | 16.168 | complete | false | hyperfine |
| ordered-map-shared | haskell | 7104.59 | 8.7724 | 10 | 2870.43 | complete | false | hyperfine |
| ordered-map-shared | haskell-a1g | 4188.91 | 3.43899 | 10 | 2165.59 | complete | false | hyperfine |
| ordered-map-shared | koka | 1904.76 | 5.19555 | 10 | 60.2969 | complete | false | hyperfine |
| ordered-map-shared | lean | 2964.25 | 18.08 | 10 | 131.879 | complete | false | hyperfine |
| ordered-map-shared | morphic | 4108.65 | 8.84807 | 10 | 97.2812 | complete | false | hyperfine |
| ordered-map-shared | ocaml | 2983.23 | 3.1372 | 10 | 220.199 | complete | false | hyperfine |
| ordered-map-shared | reussir | 1565.07 | 0.542406 | 10 | 58.168 | complete | false | hyperfine |
| ordered-map-shared | reussir-nrac | 1572.64 | 2.04506 | 10 | 58.0312 | complete | false | hyperfine |
| ordered-map-shared | rust | 1044.83 | 4.29676 | 10 | 126.242 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds | 4120.14 | 4.03779 | 10 | 128.93 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds-with-mimalloc | 2599.64 | 2.60154 | 10 | 100.18 | complete | false | hyperfine |
| ordered-map-shared | rust-with-mimalloc | 816.679 | 4.73317 | 10 | 130.184 | complete | false | hyperfine |

## Arbitrary-precision integers

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| bigint-binomial | haskell | 1436.49 | 2.10284 | 10 | 15.6641 | complete | false | hyperfine |
| bigint-binomial | haskell-a1g | 1935.23 | 4.73967 | 10 | 1284.41 | complete | false | hyperfine |
| bigint-binomial | koka | 9161.66 | 78.2458 | 10 | 6.05859 | complete | false | hyperfine |
| bigint-binomial | lean | 1814.67 | 7.58112 | 10 | 10.3516 | complete | false | hyperfine |
| bigint-binomial | ocaml | 1717.98 | 5.00377 | 10 | 7.02344 | complete | false | hyperfine |
| bigint-binomial | reussir | 1356.2 | 0.70326 | 10 | 6.17578 | complete | false | hyperfine |
| bigint-binomial | reussir-nrac | 1355.03 | 3.71407 | 10 | 6.08984 | complete | false | hyperfine |
| bigint-binomial | rust | 5275.67 | 15.0271 | 10 | 1.98828 | complete | false | hyperfine |
| bigint-binomial | rust-with-mimalloc | 5272.19 | 6.19745 | 10 | 6.36328 | complete | false | hyperfine |
| bigint-collatz | haskell | 1366.41 | 10.9338 | 10 | 7.68359 | complete | false | hyperfine |
| bigint-collatz | haskell-a1g | 1665.74 | 12.958 | 10 | 1043.78 | complete | false | hyperfine |
| bigint-collatz | koka | 158.264 | 0.384883 | 10 | 4.11719 | complete | false | hyperfine |
| bigint-collatz | lean | 215.015 | 0.56461 | 10 | 10.0391 | complete | false | hyperfine |
| bigint-collatz | ocaml | 544.685 | 1.76563 | 10 | 3.23438 | complete | false | hyperfine |
| bigint-collatz | reussir | 121.701 | 0.325651 | 10 | 2.01172 | complete | false | hyperfine |
| bigint-collatz | reussir-nrac | 121.584 | 0.215619 | 10 | 2.08203 | complete | false | hyperfine |
| bigint-collatz | rust | 751.51 | 14.7543 | 10 | 1.83203 | complete | false | hyperfine |
| bigint-collatz | rust-with-mimalloc | 745.422 | 9.54334 | 10 | 6.36328 | complete | false | hyperfine |
| bigint-factorial | haskell | 645.719 | 0.715543 | 10 | 14.5742 | complete | false | hyperfine |
| bigint-factorial | haskell-a1g | 1126.68 | 5.94701 | 10 | 1347.39 | complete | false | hyperfine |
| bigint-factorial | koka | 11111.1 | 8.08605 | 10 | 5.99219 | complete | false | hyperfine |
| bigint-factorial | lean | 1192.22 | 0.91151 | 10 | 11.1094 | complete | false | hyperfine |
| bigint-factorial | ocaml | 1216.85 | 1.80344 | 10 | 7.92969 | complete | false | hyperfine |
| bigint-factorial | reussir | 633.504 | 0.74999 | 10 | 7.83594 | complete | false | hyperfine |
| bigint-factorial | reussir-nrac | 633.153 | 0.984066 | 10 | 7.85156 | complete | false | hyperfine |
| bigint-factorial | rust | 1130.57 | 1.67731 | 10 | 2.11719 | complete | false | hyperfine |
| bigint-factorial | rust-with-mimalloc | 1128.66 | 2.43878 | 10 | 10.3633 | complete | false | hyperfine |
| bigint-fib | haskell | 529.489 | 0.574188 | 10 | 16.6055 | complete | false | hyperfine |
| bigint-fib | haskell-a1g | 1169.91 | 9.2739 | 10 | 1409.57 | complete | false | hyperfine |
| bigint-fib | koka | 2104.44 | 0.812542 | 10 | 5.99219 | complete | false | hyperfine |
| bigint-fib | lean | 1031.06 | 0.826455 | 10 | 10.3555 | complete | false | hyperfine |
| bigint-fib | ocaml | 987.554 | 2.34018 | 10 | 7.04297 | complete | false | hyperfine |
| bigint-fib | reussir | 499.79 | 0.435479 | 10 | 5.85156 | complete | false | hyperfine |
| bigint-fib | reussir-nrac | 500.954 | 3.45096 | 10 | 5.85156 | complete | false | hyperfine |
| bigint-fib | rust | 1952.63 | 0.468213 | 10 | 1.98828 | complete | false | hyperfine |
| bigint-fib | rust-with-mimalloc | 1953.17 | 0.477308 | 10 | 8.36719 | complete | false | hyperfine |
| bigint-pidigits | haskell | 401.999 | 0.691276 | 10 | 15.668 | complete | false | hyperfine |
| bigint-pidigits | haskell-a1g | 874.105 | 7.74912 | 10 | 1298.79 | complete | false | hyperfine |
| bigint-pidigits | koka | 6906.07 | 3.36045 | 10 | 41.7148 | complete | false | hyperfine |
| bigint-pidigits | lean | 747.243 | 0.917964 | 10 | 10.25 | complete | false | hyperfine |
| bigint-pidigits | ocaml | 634.849 | 1.60165 | 10 | 7.54688 | complete | false | hyperfine |
| bigint-pidigits | reussir | 412.044 | 0.670011 | 10 | 6.21875 | complete | false | hyperfine |
| bigint-pidigits | reussir-nrac | 412.078 | 0.49791 | 10 | 6.24219 | complete | false | hyperfine |
| bigint-pidigits | rust | 2205.75 | 2.70178 | 10 | 2.71875 | complete | false | hyperfine |
| bigint-pidigits | rust-with-mimalloc | 1634.32 | 1.7442 | 10 | 11.5547 | complete | false | hyperfine |
| bigint-rbtree | haskell | 601.413 | 0.798507 | 10 | 179.402 | complete | false | hyperfine |
| bigint-rbtree | haskell-a1g | 986.692 | 5.70554 | 10 | 1216.43 | complete | false | hyperfine |
| bigint-rbtree | koka | 188.383 | 0.96009 | 10 | 117.969 | complete | false | hyperfine |
| bigint-rbtree | lean | 837.502 | 0.553482 | 10 | 123.609 | complete | false | hyperfine |
| bigint-rbtree | ocaml | 374.736 | 0.702892 | 10 | 121.23 | complete | false | hyperfine |
| bigint-rbtree | reussir | 248.398 | 0.994904 | 10 | 117.891 | complete | false | hyperfine |
| bigint-rbtree | reussir-nrac | 406.432 | 0.773101 | 10 | 118.078 | complete | false | hyperfine |
| bigint-rbtree | rust | 3869.24 | 5.98038 | 10 | 7615.74 | complete | false | hyperfine |
| bigint-rbtree | rust-with-mimalloc | 1882.67 | 2.79093 | 10 | 7639.41 | complete | false | hyperfine |

## Traversals of shared data

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| expr-replace | haskell | 354.192 | 5.37211 | 10 | 3.92969 | complete | false | hyperfine |
| expr-replace | haskell-a1g | 366.07 | 10.2724 | 10 | 20.1797 | complete | false | hyperfine |
| expr-replace | koka | 586.102 | 1.90903 | 10 | 3.96094 | complete | false | hyperfine |
| expr-replace | lean | 401.649 | 2.33032 | 10 | 9.87891 | complete | false | hyperfine |
| expr-replace | morphic | 289.781 | 0.392029 | 10 | 1.17969 | complete | false | hyperfine |
| expr-replace | ocaml | 324.755 | 0.422243 | 10 | 3.64062 | complete | false | hyperfine |
| expr-replace | reussir | 275.181 | 2.08788 | 10 | 4.25781 | complete | false | hyperfine |
| expr-replace | reussir-nrac | 274.432 | 1.6565 | 10 | 4.39453 | complete | false | hyperfine |
| expr-replace | rust | 358.979 | 0.42274 | 10 | 2.05078 | complete | false | hyperfine |
| expr-replace | rust-with-mimalloc | 354.951 | 0.605044 | 10 | 6.16797 | complete | false | hyperfine |
| list-membership | haskell | 693.923 | 1.48162 | 10 | 3.93359 | complete | false | hyperfine |
| list-membership | haskell-a1g | 701.494 | 1.07067 | 10 | 20.1836 | complete | false | hyperfine |
| list-membership | koka | 339.229 | 0.753992 | 10 | 3.95703 | complete | false | hyperfine |
| list-membership | lean | 357.174 | 0.22491 | 10 | 10.0273 | complete | false | hyperfine |
| list-membership | morphic | 335.543 | 0.431833 | 10 | 1.36328 | complete | false | hyperfine |
| list-membership | ocaml | 337.683 | 2.62195 | 10 | 3.94922 | complete | false | hyperfine |
| list-membership | reussir | 324.098 | 0.347909 | 10 | 3.98438 | complete | false | hyperfine |
| list-membership | reussir-nrac | 324.212 | 0.315869 | 10 | 3.98438 | complete | false | hyperfine |
| list-membership | rust | 340.822 | 0.343959 | 10 | 2.36328 | complete | false | hyperfine |
| list-membership | rust-with-mimalloc | 324.766 | 0.187806 | 10 | 6.32422 | complete | false | hyperfine |
| rbtree-lookup | haskell | 1463.43 | 2.52492 | 10 | 137.836 | complete | false | hyperfine |
| rbtree-lookup | haskell-a1g | 1271.21 | 2.14057 | 10 | 1081.59 | complete | false | hyperfine |
| rbtree-lookup | koka | 528.754 | 3.48537 | 10 | 41.9609 | complete | false | hyperfine |
| rbtree-lookup | lean | 1183.69 | 0.569427 | 10 | 55.0703 | complete | false | hyperfine |
| rbtree-lookup | morphic | 1634.33 | 0.860859 | 10 | 77.1172 | complete | false | hyperfine |
| rbtree-lookup | ocaml | 1826.66 | 1.59908 | 10 | 162.203 | complete | false | hyperfine |
| rbtree-lookup | reussir | 454.508 | 1.22599 | 10 | 42.2773 | complete | false | hyperfine |
| rbtree-lookup | reussir-nrac | 901.382 | 9.30954 | 10 | 42.2773 | complete | false | hyperfine |
| rbtree-lookup | rust | 1698.82 | 0.959315 | 10 | 123.77 | complete | false | hyperfine |
| rbtree-lookup | rust-with-mimalloc | 1896.43 | 2.60203 | 10 | 96.1797 | complete | false | hyperfine |
