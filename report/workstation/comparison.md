# workstation benchmark comparison

workstation: 288 recorded cells accounted for; timing 287/288, footprint 287/288. Statuses: budget_exhausted=1, budget_limited=4, complete=283.

The ocaml configuration uses OxCaml (Flambda 2). Time and RSS ratios are variant / default Reussir: above 1 means slower or more memory. Geometric means use only complete, non-budget-limited pairs with positive measurements. Timing and memory coverage can differ. X means takes too long (no completed measurement within 5 minutes). Blank CSV cells and — mean unavailable for other reasons; a single timing sample has no standard deviation.

Reussir: `36f05142f3b33f442f69afa421a10b7a39ee21f9`. Benchmark: `19efdd9334de1d1fb64bb32ff59e0a47aea7d039`. Architecture: x86_64; measurement CPU: 1.

Compiler and runtime hashes are recorded in `provenance/manifest.json`. The compiler hash identifies the native ELF; the compiler launcher environment is recorded separately in `provenance/compiler-launch-environment.json`.

## Complete paired comparisons

| Variant | Available pairs | Timing pairs | Time / Reussir | Memory pairs | RSS / Reussir |
| --- | --- | --- | --- | --- | --- |
| haskell | 27 | 27 | 1.96719 | 27 | 2.98376 |
| haskell-a1g | 27 | 27 | 2.24975 | 27 | 32.5043 |
| haskell-st | 3 | 3 | 2.76126 | 3 | 1.72545 |
| haskell-st-a1g | 3 | 3 | 3.04662 | 3 | 29.789 |
| koka | 28 | 27 | 2.0642 | 27 | 1.2666 |
| lean | 28 | 27 | 2.09329 | 27 | 2.04248 |
| morphic | 20 | 19 | 2.48196 | 19 | 1.06884 |
| ocaml | 28 | 26 | 2.14425 | 26 | 4.14563 |
| reussir | 28 | 28 | 1 | 28 | 1 |
| reussir-nrac | 28 | 28 | 1.102 | 28 | 1.03292 |
| rust | 28 | 28 | 2.14813 | 28 | 1.60234 |
| rust-rpds | 6 | 6 | 2.34716 | 6 | 2.14405 |
| rust-rpds-with-mimalloc | 6 | 6 | 1.53059 | 6 | 1.81259 |
| rust-with-mimalloc | 28 | 28 | 1.86774 | 28 | 2.97071 |

## Functional data structures

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| derive | haskell | 722.469 | 5.36045 | 10 | 572.234 | complete | false | hyperfine |
| derive | haskell-a1g | 221.13 | 0.624647 | 10 | 634.734 | complete | false | hyperfine |
| derive | koka | 294.463 | 0.710041 | 10 | 455.492 | complete | false | hyperfine |
| derive | lean | 353.443 | 2.73465 | 10 | 552.191 | complete | false | hyperfine |
| derive | morphic | 605.301 | 2.43886 | 10 | 765.035 | complete | false | hyperfine |
| derive | ocaml | 429.82 | 5.27671 | 10 | 376.293 | complete | false | hyperfine |
| derive | reussir | 368.344 | 4.05425 | 10 | 455.773 | complete | false | hyperfine |
| derive | reussir-nrac | 374.611 | 1.29694 | 10 | 455.773 | complete | false | hyperfine |
| derive | rust | 1310.58 | 7.68812 | 10 | 1529.28 | complete | false | hyperfine |
| derive | rust-with-mimalloc | 874.151 | 8.18012 | 10 | 1535.82 | complete | false | hyperfine |
| fingertree | haskell | 68.998 | 0.288692 | 10 | 15.2422 | complete | false | hyperfine |
| fingertree | haskell-a1g | 278.764 | 1.342 | 10 | 683.742 | complete | false | hyperfine |
| fingertree | koka | 41.484 | 0.218411 | 10 | 5.50391 | complete | false | hyperfine |
| fingertree | lean | 48.9617 | 0.244492 | 10 | 12.9258 | complete | false | hyperfine |
| fingertree | morphic | 53.3253 | 0.189714 | 10 | 2.76172 | complete | false | hyperfine |
| fingertree | ocaml | 41.7282 | 0.159352 | 10 | 18.2539 | complete | false | hyperfine |
| fingertree | reussir | 28.3035 | 0.434115 | 10 | 5.75 | complete | false | hyperfine |
| fingertree | reussir-nrac | 28.9986 | 0.609991 | 10 | 5.75 | complete | false | hyperfine |
| fingertree | rust | 53.8282 | 0.657772 | 10 | 7.06641 | complete | false | hyperfine |
| fingertree | rust-with-mimalloc | 53.7476 | 0.238186 | 10 | 9.57812 | complete | false | hyperfine |
| functional-queue | haskell | 31.3731 | 0.335341 | 10 | 13.2422 | complete | false | hyperfine |
| functional-queue | haskell-a1g | 84.6543 | 2.69664 | 10 | 266.992 | complete | false | hyperfine |
| functional-queue | koka | 55.057 | 0.804633 | 10 | 5.50391 | complete | false | hyperfine |
| functional-queue | lean | 53.0952 | 0.38713 | 10 | 12.918 | complete | false | hyperfine |
| functional-queue | morphic | 68.941 | 0.618883 | 10 | 5.51172 | complete | false | hyperfine |
| functional-queue | ocaml | 53.6324 | 0.273515 | 10 | 18.2305 | complete | false | hyperfine |
| functional-queue | reussir | 34.8724 | 0.0912892 | 10 | 5.92188 | complete | false | hyperfine |
| functional-queue | reussir-nrac | 34.9368 | 0.121551 | 10 | 5.92188 | complete | false | hyperfine |
| functional-queue | rust | 92.6586 | 0.35518 | 10 | 6.06641 | complete | false | hyperfine |
| functional-queue | rust-with-mimalloc | 93.316 | 3.81095 | 10 | 8.07031 | complete | false | hyperfine |
| heap-functional | haskell | 1682.12 | 3.29891 | 10 | 13.4961 | complete | false | hyperfine |
| heap-functional | haskell-a1g | 1682.04 | 10.3988 | 10 | 1050.43 | complete | false | hyperfine |
| heap-functional | koka | 676.69 | 2.21859 | 10 | 5.50391 | complete | false | hyperfine |
| heap-functional | lean | 1371.69 | 16.0218 | 10 | 12.9688 | complete | false | hyperfine |
| heap-functional | morphic | 1913.37 | 18.9155 | 10 | 4.78516 | complete | false | hyperfine |
| heap-functional | ocaml | 1544.61 | 7.24382 | 10 | 18.2148 | complete | false | hyperfine |
| heap-functional | reussir | 672.249 | 0.536054 | 10 | 5.90625 | complete | false | hyperfine |
| heap-functional | reussir-nrac | 920.373 | 8.63966 | 10 | 5.91016 | complete | false | hyperfine |
| heap-functional | rust | 2013.32 | 16.4874 | 10 | 7.06641 | complete | false | hyperfine |
| heap-functional | rust-with-mimalloc | 2431.46 | 15.8975 | 10 | 11.5742 | complete | false | hyperfine |
| mltt | haskell | 913.594 | 0.531892 | 10 | 17.2109 | complete | false | hyperfine |
| mltt | haskell-a1g | 1408.37 | 40.9908 | 10 | 59.9609 | complete | false | hyperfine |
| mltt | koka | 1047.3 | 8.02559 | 10 | 11.4297 | complete | false | hyperfine |
| mltt | lean | 904.609 | 0.559588 | 10 | 14.5 | complete | false | hyperfine |
| mltt | ocaml | 319.287 | 3.93934 | 10 | 18.3672 | complete | false | hyperfine |
| mltt | reussir | 878.749 | 4.03089 | 10 | 12.2578 | complete | false | hyperfine |
| mltt | reussir-nrac | 881.912 | 1.3407 | 10 | 12.2578 | complete | false | hyperfine |
| mltt | rust | 529.834 | 2.15567 | 10 | 28.6055 | complete | false | hyperfine |
| mltt | rust-with-mimalloc | 890.181 | 1.61781 | 10 | 31.0898 | complete | false | hyperfine |
| nbe-closure | haskell | 83.7381 | 0.862059 | 10 | 82.9648 | complete | false | hyperfine |
| nbe-closure | haskell-a1g | 44.0252 | 0.186465 | 10 | 120.957 | complete | false | hyperfine |
| nbe-closure | koka | 148.333 | 1.2133 | 10 | 41.4492 | complete | false | hyperfine |
| nbe-closure | lean | 98.4306 | 5.68674 | 10 | 167.113 | complete | false | hyperfine |
| nbe-closure | morphic | 606.377 | 10.5443 | 10 | 168.512 | complete | false | hyperfine |
| nbe-closure | ocaml | 621.479 | 4.16823 | 10 | 129.617 | complete | false | hyperfine |
| nbe-closure | reussir | 121.742 | 0.953462 | 10 | 41.7695 | complete | false | hyperfine |
| nbe-closure | reussir-nrac | 134.08 | 0.5218 | 10 | 65.7031 | complete | false | hyperfine |
| nbe-closure | rust | 2449.12 | 43.8076 | 10 | 428.367 | complete | false | hyperfine |
| nbe-closure | rust-with-mimalloc | 774.868 | 110.822 | 10 | 370.699 | complete | false | hyperfine |
| nbe-hoas | haskell | 90.6694 | 0.852838 | 10 | 78.9648 | complete | false | hyperfine |
| nbe-hoas | haskell-a1g | 68.5672 | 0.271442 | 10 | 164.957 | complete | false | hyperfine |
| nbe-hoas | koka | 155.618 | 1.38356 | 10 | 41.5039 | complete | false | hyperfine |
| nbe-hoas | lean | 98.8975 | 3.79158 | 10 | 136.594 | complete | false | hyperfine |
| nbe-hoas | morphic | 482.597 | 10.1752 | 10 | 153.262 | complete | false | hyperfine |
| nbe-hoas | ocaml | 492.154 | 2.90181 | 10 | 133.242 | complete | false | hyperfine |
| nbe-hoas | reussir | 145.128 | 1.48566 | 10 | 41.7695 | complete | false | hyperfine |
| nbe-hoas | reussir-nrac | 155.309 | 1.21709 | 10 | 65.7695 | complete | false | hyperfine |
| nbe-hoas | rust | 2058.48 | 32.2658 | 10 | 413.117 | complete | false | hyperfine |
| nbe-hoas | rust-with-mimalloc | 640.461 | 8.26301 | 10 | 355.438 | complete | false | hyperfine |
| rbtree | haskell | 424.525 | 2.31641 | 10 | 174.242 | complete | false | hyperfine |
| rbtree | haskell-a1g | 662.415 | 2.36243 | 10 | 1175.24 | complete | false | hyperfine |
| rbtree | koka | 176.031 | 2.22676 | 10 | 99.5039 | complete | false | hyperfine |
| rbtree | lean | 608.264 | 3.92835 | 10 | 122.441 | complete | false | hyperfine |
| rbtree | morphic | 1181.79 | 8.01604 | 10 | 191.535 | complete | false | hyperfine |
| rbtree | ocaml | 315.403 | 2.00014 | 10 | 184.273 | complete | false | hyperfine |
| rbtree | reussir | 188.518 | 0.751906 | 10 | 97.875 | complete | false | hyperfine |
| rbtree | reussir-nrac | 343.031 | 2.72278 | 10 | 97.8789 | complete | false | hyperfine |
| rbtree | rust | 2300.23 | 9.40383 | 10 | 4924.32 | complete | false | hyperfine |
| rbtree | rust-with-mimalloc | 1383.7 | 16.0068 | 10 | 3760.79 | complete | false | hyperfine |
| rbtree-zipper | haskell | 359.135 | 1.24371 | 10 | 158.961 | complete | false | hyperfine |
| rbtree-zipper | haskell-a1g | 690.115 | 2.26726 | 10 | 1167.71 | complete | false | hyperfine |
| rbtree-zipper | koka | 151.252 | 0.412688 | 10 | 99.5039 | complete | false | hyperfine |
| rbtree-zipper | lean | 296.867 | 0.827013 | 10 | 122.398 | complete | false | hyperfine |
| rbtree-zipper | morphic | 1335.24 | 18.3278 | 10 | 191.535 | complete | false | hyperfine |
| rbtree-zipper | ocaml | 272.51 | 0.467967 | 10 | 184.285 | complete | false | hyperfine |
| rbtree-zipper | reussir | 129.214 | 0.550089 | 10 | 97.9062 | complete | false | hyperfine |
| rbtree-zipper | reussir-nrac | 129.22 | 0.354298 | 10 | 97.9062 | complete | false | hyperfine |
| rbtree-zipper | rust | 3094.53 | 8.93124 | 10 | 5115.03 | complete | false | hyperfine |
| rbtree-zipper | rust-with-mimalloc | 2782.62 | 15.5531 | 10 | 3951.44 | complete | false | hyperfine |

## Large aggregates

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| heap-array | haskell-st | 723.541 | 3.25812 | 10 | 8.41406 | complete | false | hyperfine |
| heap-array | haskell-st-a1g | 943.696 | 2.03507 | 10 | 1044.62 | complete | false | hyperfine |
| heap-array | koka | 1999.07 | 25.8085 | 10 | 3.78516 | complete | false | hyperfine |
| heap-array | lean | 1425.34 | 2.88892 | 10 | 14.0117 | complete | false | hyperfine |
| heap-array | morphic | 736.613 | 3.51957 | 10 | 1 | complete | false | hyperfine |
| heap-array | ocaml | 1269.46 | 2.25217 | 10 | 16.0195 | complete | false | hyperfine |
| heap-array | reussir | 198.87 | 0.0608765 | 10 | 3.82031 | complete | false | hyperfine |
| heap-array | reussir-nrac | 375.163 | 1.16499 | 10 | 3.90625 | complete | false | hyperfine |
| heap-array | rust | 217.837 | 0.218533 | 10 | 1.56641 | complete | false | hyperfine |
| heap-array | rust-with-mimalloc | 217.218 | 0.0795143 | 10 | 5.83203 | complete | false | hyperfine |
| life | haskell | 1241.91 | 0.704053 | 10 | 9.36719 | complete | false | hyperfine |
| life | haskell-a1g | 1451.81 | 1.22146 | 10 | 1015.74 | complete | false | hyperfine |
| life | haskell-st | 1191.56 | 0.790879 | 10 | 3.74219 | complete | false | hyperfine |
| life | haskell-st-a1g | 1195.43 | 0.816876 | 10 | 19.9922 | complete | false | hyperfine |
| life | koka | 4320.05 | 2.97305 | 10 | 3.47656 | complete | false | hyperfine |
| life | lean | 4231.71 | 7.44177 | 10 | 9.00391 | complete | false | hyperfine |
| life | morphic | 777.331 | 0.46477 | 10 | 0.785156 | complete | false | hyperfine |
| life | ocaml | 1209.82 | 1.11904 | 10 | 9.46875 | complete | false | hyperfine |
| life | reussir | 298.493 | 0.139179 | 10 | 3.91406 | complete | false | hyperfine |
| life | reussir-nrac | 298.525 | 0.206639 | 10 | 3.91406 | complete | false | hyperfine |
| life | rust | 180.08 | 3.2885 | 10 | 1.07031 | complete | false | hyperfine |
| life | rust-with-mimalloc | 180.278 | 3.19877 | 10 | 5.57812 | complete | false | hyperfine |
| qsort | haskell | 2714.06 | 33.2654 | 10 | 29.1406 | complete | false | hyperfine |
| qsort | haskell-a1g | 2352.61 | 45.0201 | 10 | 1052.41 | complete | false | hyperfine |
| qsort | haskell-st | 421.149 | 0.419614 | 10 | 9.21484 | complete | false | hyperfine |
| qsort | haskell-st-a1g | 432.306 | 2.22116 | 10 | 71.4922 | complete | false | hyperfine |
| qsort | koka | 913.751 | 1.62802 | 10 | 9.47266 | complete | false | hyperfine |
| qsort | lean | 1049.63 | 0.584781 | 10 | 10.8203 | complete | false | hyperfine |
| qsort | morphic | 448.162 | 1.08908 | 10 | 1.39453 | complete | false | hyperfine |
| qsort | ocaml | 922.482 | 5.39871 | 10 | 11.7578 | complete | false | hyperfine |
| qsort | reussir | 290.531 | 0.180084 | 10 | 3.77734 | complete | false | hyperfine |
| qsort | reussir-nrac | 290.714 | 0.179692 | 10 | 3.77734 | complete | false | hyperfine |
| qsort | rust | 274.445 | 0.20897 | 10 | 1.69922 | complete | false | hyperfine |
| qsort | rust-with-mimalloc | 275.254 | 1.13185 | 10 | 5.57812 | complete | false | hyperfine |
| raytracer | haskell | 202.545 | 1.03392 | 10 | 7.46875 | complete | false | hyperfine |
| raytracer | haskell-a1g | 233.157 | 1.62212 | 10 | 88.9766 | complete | false | hyperfine |
| raytracer | koka | 265.861 | 1.40276 | 10 | 3.76953 | complete | false | hyperfine |
| raytracer | lean | 833.335 | 1.74812 | 10 | 9.23828 | complete | false | hyperfine |
| raytracer | ocaml | 112.223 | 0.0704392 | 10 | 12.5352 | complete | false | hyperfine |
| raytracer | reussir | 73.9417 | 0.115531 | 10 | 3.87109 | complete | false | hyperfine |
| raytracer | reussir-nrac | 73.9435 | 0.0697648 | 10 | 3.87109 | complete | false | hyperfine |
| raytracer | rust | 64.957 | 0.0872523 | 10 | 1.62109 | complete | false | hyperfine |
| raytracer | rust-with-mimalloc | 65.1583 | 0.0667311 | 10 | 6.07812 | complete | false | hyperfine |

## Standard-library collections

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hash-map-heavily-shared | haskell | 3658.21 | 19.3206 | 10 | 279.238 | complete | false | hyperfine |
| hash-map-heavily-shared | haskell-a1g | 2683.62 | 7.89965 | 10 | 1227.99 | complete | false | hyperfine |
| hash-map-heavily-shared | koka | 96394.8 | 945.792 | 2 | 633.891 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | lean | 103561 | — | 1 | 262.867 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | morphic | 138258 | — | 1 | 548.656 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | ocaml | X (takes too long) | — | 0 | X (takes too long) | budget_exhausted | true | — |
| hash-map-heavily-shared | reussir | 3348.42 | 9.47602 | 10 | 77.9062 | complete | false | hyperfine |
| hash-map-heavily-shared | reussir-nrac | 3321.67 | 19.447 | 10 | 77.9648 | complete | false | hyperfine |
| hash-map-heavily-shared | rust | 16303 | 34.4664 | 10 | 358.359 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-rpds | 5445.16 | 70.277 | 10 | 163.332 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-rpds-with-mimalloc | 3522.23 | 33.3288 | 10 | 147.609 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-with-mimalloc | 11927.5 | 86.6565 | 10 | 484.453 | complete | false | hyperfine |
| hash-map-linear | haskell | 2465.92 | 7.44193 | 10 | 264.242 | complete | false | hyperfine |
| hash-map-linear | haskell-a1g | 2341.16 | 9.22725 | 10 | 1222.74 | complete | false | hyperfine |
| hash-map-linear | koka | 1106.68 | 2.79575 | 10 | 583.477 | complete | false | hyperfine |
| hash-map-linear | lean | 758.809 | 4.89124 | 10 | 95.2852 | complete | false | hyperfine |
| hash-map-linear | morphic | 649.004 | 18.1238 | 10 | 116.074 | complete | false | hyperfine |
| hash-map-linear | ocaml | 1372.96 | 5.22536 | 10 | 138.488 | complete | false | hyperfine |
| hash-map-linear | reussir | 746.97 | 3.18881 | 10 | 69.8828 | complete | false | hyperfine |
| hash-map-linear | reussir-nrac | 770.924 | 2.15768 | 10 | 69.8828 | complete | false | hyperfine |
| hash-map-linear | rust | 172.905 | 0.627025 | 10 | 52.2617 | complete | false | hyperfine |
| hash-map-linear | rust-rpds | 1242.49 | 8.20124 | 10 | 157.344 | complete | false | hyperfine |
| hash-map-linear | rust-rpds-with-mimalloc | 1035.24 | 7.57576 | 10 | 139.871 | complete | false | hyperfine |
| hash-map-linear | rust-with-mimalloc | 169.585 | 0.707756 | 10 | 81.5898 | complete | false | hyperfine |
| hash-map-shared | haskell | 3122.66 | 11.401 | 10 | 321.992 | complete | false | hyperfine |
| hash-map-shared | haskell-a1g | 2797.75 | 15.9862 | 10 | 1254.99 | complete | false | hyperfine |
| hash-map-shared | koka | 7622.15 | 105.593 | 10 | 628.938 | complete | false | hyperfine |
| hash-map-shared | lean | 8224.17 | 66.1315 | 10 | 261.469 | complete | false | hyperfine |
| hash-map-shared | morphic | 10060.5 | 27.6651 | 10 | 565.465 | complete | false | hyperfine |
| hash-map-shared | ocaml | 46093.9 | 126.376 | 2 | 925.496 | budget_limited | true | hyperfine |
| hash-map-shared | reussir | 3526.39 | 8.22705 | 10 | 109.965 | complete | false | hyperfine |
| hash-map-shared | reussir-nrac | 3491.96 | 27.3564 | 10 | 109.949 | complete | false | hyperfine |
| hash-map-shared | rust | 1201.72 | 2.97985 | 10 | 366.73 | complete | false | hyperfine |
| hash-map-shared | rust-rpds | 5843.38 | 39.5339 | 10 | 190.328 | complete | false | hyperfine |
| hash-map-shared | rust-rpds-with-mimalloc | 3583.39 | 12.9492 | 10 | 171.562 | complete | false | hyperfine |
| hash-map-shared | rust-with-mimalloc | 941.269 | 1.97813 | 10 | 503.641 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell | 6320.94 | 62.6601 | 10 | 2870.25 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell-a1g | 3775.18 | 12.651 | 10 | 2165.5 | complete | false | hyperfine |
| ordered-map-heavily-shared | koka | 936.248 | 6.43139 | 10 | 31.7227 | complete | false | hyperfine |
| ordered-map-heavily-shared | lean | 2083.67 | 12.5454 | 10 | 83.2461 | complete | false | hyperfine |
| ordered-map-heavily-shared | morphic | 2484.51 | 45.5989 | 10 | 48.0156 | complete | false | hyperfine |
| ordered-map-heavily-shared | ocaml | 2235.67 | 5.20521 | 10 | 96.418 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir | 758.959 | 0.813311 | 10 | 31.7695 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir-nrac | 754.095 | 0.77974 | 10 | 31.7734 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust | 11936.5 | 113.359 | 10 | 126.367 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds | 3211.68 | 23.3588 | 10 | 72.6172 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds-with-mimalloc | 1870.1 | 13.6178 | 10 | 57.582 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-with-mimalloc | 11047.7 | 66.5338 | 10 | 123.527 | complete | false | hyperfine |
| ordered-map-linear | haskell | 1998.82 | 5.51877 | 10 | 110.246 | complete | false | hyperfine |
| ordered-map-linear | haskell-a1g | 1912 | 4.06187 | 10 | 1093.5 | complete | false | hyperfine |
| ordered-map-linear | koka | 571.397 | 2.64032 | 10 | 23.7266 | complete | false | hyperfine |
| ordered-map-linear | lean | 1169.16 | 3.62175 | 10 | 71.3047 | complete | false | hyperfine |
| ordered-map-linear | morphic | 1362.33 | 8.16361 | 10 | 34.7656 | complete | false | hyperfine |
| ordered-map-linear | ocaml | 1743.74 | 12.4593 | 10 | 84.3984 | complete | false | hyperfine |
| ordered-map-linear | reussir | 477.349 | 2.33207 | 10 | 23.7578 | complete | false | hyperfine |
| ordered-map-linear | reussir-nrac | 485.149 | 0.938246 | 10 | 23.7617 | complete | false | hyperfine |
| ordered-map-linear | rust | 241.773 | 0.43368 | 10 | 13.5273 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds | 1532.31 | 24.6451 | 10 | 55.6172 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds-with-mimalloc | 945.052 | 6.4879 | 10 | 45.5781 | complete | false | hyperfine |
| ordered-map-linear | rust-with-mimalloc | 223.062 | 0.295828 | 10 | 15.582 | complete | false | hyperfine |
| ordered-map-shared | haskell | 6327.87 | 48.3155 | 10 | 2870.25 | complete | false | hyperfine |
| ordered-map-shared | haskell-a1g | 3776.93 | 15.296 | 10 | 2165.5 | complete | false | hyperfine |
| ordered-map-shared | koka | 1537.17 | 7.07054 | 10 | 59.7227 | complete | false | hyperfine |
| ordered-map-shared | lean | 2570.84 | 6.47621 | 10 | 131.012 | complete | false | hyperfine |
| ordered-map-shared | morphic | 3237.33 | 28.7245 | 10 | 97.0156 | complete | false | hyperfine |
| ordered-map-shared | ocaml | 2202.21 | 6.04915 | 10 | 150.414 | complete | false | hyperfine |
| ordered-map-shared | reussir | 1283.41 | 2.90382 | 10 | 57.7695 | complete | false | hyperfine |
| ordered-map-shared | reussir-nrac | 1283.46 | 9.39323 | 10 | 57.7734 | complete | false | hyperfine |
| ordered-map-shared | rust | 948.806 | 5.4975 | 10 | 126.117 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds | 3524.55 | 22.8201 | 10 | 128.367 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds-with-mimalloc | 2283.38 | 4.51639 | 10 | 99.5859 | complete | false | hyperfine |
| ordered-map-shared | rust-with-mimalloc | 880.741 | 3.29218 | 10 | 129.59 | complete | false | hyperfine |

## Arbitrary-precision integers

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| bigint-binomial | haskell | 1245.01 | 1.04846 | 10 | 15.1836 | complete | false | hyperfine |
| bigint-binomial | haskell-a1g | 1740.54 | 1.52757 | 10 | 1283.93 | complete | false | hyperfine |
| bigint-binomial | koka | 5421.95 | 2.08458 | 10 | 4.78906 | complete | false | hyperfine |
| bigint-binomial | lean | 1828.53 | 1.37789 | 10 | 9.19922 | complete | false | hyperfine |
| bigint-binomial | ocaml | 1313.05 | 0.809008 | 10 | 16.8359 | complete | false | hyperfine |
| bigint-binomial | reussir | 1195.64 | 0.393876 | 10 | 5.69531 | complete | false | hyperfine |
| bigint-binomial | reussir-nrac | 1195.64 | 0.646559 | 10 | 5.69531 | complete | false | hyperfine |
| bigint-binomial | rust | 1797.07 | 0.364715 | 10 | 1.37891 | complete | false | hyperfine |
| bigint-binomial | rust-with-mimalloc | 1798.17 | 0.261817 | 10 | 5.82031 | complete | false | hyperfine |
| bigint-collatz | haskell | 1053.55 | 1.86326 | 10 | 7.48047 | complete | false | hyperfine |
| bigint-collatz | haskell-a1g | 1265.82 | 2.79162 | 10 | 1043.73 | complete | false | hyperfine |
| bigint-collatz | koka | 176.558 | 0.300063 | 10 | 3.48047 | complete | false | hyperfine |
| bigint-collatz | lean | 218.414 | 0.186727 | 10 | 8.94531 | complete | false | hyperfine |
| bigint-collatz | ocaml | 726.571 | 7.88149 | 10 | 6.60547 | complete | false | hyperfine |
| bigint-collatz | reussir | 161.122 | 0.13066 | 10 | 1.64844 | complete | false | hyperfine |
| bigint-collatz | reussir-nrac | 150.202 | 1.28156 | 10 | 1.60938 | complete | false | hyperfine |
| bigint-collatz | rust | 418.212 | 1.11087 | 10 | 1.06641 | complete | false | hyperfine |
| bigint-collatz | rust-with-mimalloc | 421.523 | 2.59393 | 10 | 5.57422 | complete | false | hyperfine |
| bigint-factorial | haskell | 718.093 | 0.530022 | 10 | 14.207 | complete | false | hyperfine |
| bigint-factorial | haskell-a1g | 1096.64 | 2.11178 | 10 | 1346.96 | complete | false | hyperfine |
| bigint-factorial | koka | 5638.53 | 3.34569 | 10 | 5.46875 | complete | false | hyperfine |
| bigint-factorial | lean | 1408.91 | 4.52225 | 10 | 10.1094 | complete | false | hyperfine |
| bigint-factorial | ocaml | 2688.84 | 5.83689 | 10 | 12733.1 | complete | false | hyperfine |
| bigint-factorial | reussir | 699.408 | 0.139553 | 10 | 7.44531 | complete | false | hyperfine |
| bigint-factorial | reussir-nrac | 699.357 | 0.124075 | 10 | 7.44531 | complete | false | hyperfine |
| bigint-factorial | rust | 712.912 | 0.431036 | 10 | 1.625 | complete | false | hyperfine |
| bigint-factorial | rust-with-mimalloc | 712.491 | 0.454575 | 10 | 9.81641 | complete | false | hyperfine |
| bigint-fib | haskell | 419.341 | 0.566818 | 10 | 16.2109 | complete | false | hyperfine |
| bigint-fib | haskell-a1g | 1335.23 | 4.87029 | 10 | 1409.21 | complete | false | hyperfine |
| bigint-fib | koka | 5784.69 | 2.03221 | 10 | 5.38672 | complete | false | hyperfine |
| bigint-fib | lean | 1135.43 | 2.24321 | 10 | 9.19922 | complete | false | hyperfine |
| bigint-fib | ocaml | 2744.64 | 8.96024 | 10 | 14922.3 | complete | false | hyperfine |
| bigint-fib | reussir | 379.046 | 0.601696 | 10 | 5.81641 | complete | false | hyperfine |
| bigint-fib | reussir-nrac | 379.244 | 0.329335 | 10 | 5.81641 | complete | false | hyperfine |
| bigint-fib | rust | 449.325 | 0.137339 | 10 | 1.625 | complete | false | hyperfine |
| bigint-fib | rust-with-mimalloc | 447.337 | 0.0757719 | 10 | 7.81641 | complete | false | hyperfine |
| bigint-pidigits | haskell | 413.892 | 0.272756 | 10 | 15.418 | complete | false | hyperfine |
| bigint-pidigits | haskell-a1g | 858.393 | 1.29536 | 10 | 1298.44 | complete | false | hyperfine |
| bigint-pidigits | koka | 4691.86 | 3.53594 | 10 | 41.1992 | complete | false | hyperfine |
| bigint-pidigits | lean | 843.066 | 0.932031 | 10 | 9.44531 | complete | false | hyperfine |
| bigint-pidigits | ocaml | 574.123 | 0.714721 | 10 | 19.6211 | complete | false | hyperfine |
| bigint-pidigits | reussir | 415.916 | 0.178034 | 10 | 5.82812 | complete | false | hyperfine |
| bigint-pidigits | reussir-nrac | 416.184 | 0.163068 | 10 | 5.82812 | complete | false | hyperfine |
| bigint-pidigits | rust | 1600.67 | 47.0689 | 10 | 2.375 | complete | false | hyperfine |
| bigint-pidigits | rust-with-mimalloc | 1262.15 | 17.1175 | 10 | 11.8203 | complete | false | hyperfine |
| bigint-rbtree | haskell | 538.251 | 3.47269 | 10 | 179.234 | complete | false | hyperfine |
| bigint-rbtree | haskell-a1g | 847.812 | 3.07647 | 10 | 1216.23 | complete | false | hyperfine |
| bigint-rbtree | koka | 191.5 | 0.876325 | 10 | 117.5 | complete | false | hyperfine |
| bigint-rbtree | lean | 613.254 | 4.92542 | 10 | 122.445 | complete | false | hyperfine |
| bigint-rbtree | ocaml | 342.53 | 6.76735 | 10 | 126.898 | complete | false | hyperfine |
| bigint-rbtree | reussir | 203.441 | 1.42216 | 10 | 117.922 | complete | false | hyperfine |
| bigint-rbtree | reussir-nrac | 377.897 | 2.54524 | 10 | 117.922 | complete | false | hyperfine |
| bigint-rbtree | rust | 3215.91 | 12.6778 | 10 | 7577.12 | complete | false | hyperfine |
| bigint-rbtree | rust-with-mimalloc | 2319.7 | 54.1902 | 10 | 7600.73 | complete | false | hyperfine |

## Traversals of shared data

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| expr-replace | haskell | 346.955 | 11.1108 | 10 | 3.98828 | complete | false | hyperfine |
| expr-replace | haskell-a1g | 358.316 | 11.1463 | 10 | 19.9883 | complete | false | hyperfine |
| expr-replace | koka | 576.43 | 12.645 | 10 | 3.50391 | complete | false | hyperfine |
| expr-replace | lean | 455.692 | 7.22752 | 10 | 8.94922 | complete | false | hyperfine |
| expr-replace | morphic | 361.255 | 2.15807 | 10 | 1.03516 | complete | false | hyperfine |
| expr-replace | ocaml | 377.71 | 0.378486 | 10 | 6.17969 | complete | false | hyperfine |
| expr-replace | reussir | 497.419 | 12.7313 | 10 | 3.86719 | complete | false | hyperfine |
| expr-replace | reussir-nrac | 494.669 | 3.22661 | 10 | 3.86719 | complete | false | hyperfine |
| expr-replace | rust | 360.264 | 3.23822 | 10 | 1.52734 | complete | false | hyperfine |
| expr-replace | rust-with-mimalloc | 353.849 | 6.42709 | 10 | 5.57812 | complete | false | hyperfine |
| list-membership | haskell | 249.798 | 0.133281 | 10 | 3.71094 | complete | false | hyperfine |
| list-membership | haskell-a1g | 253.911 | 0.46876 | 10 | 19.9609 | complete | false | hyperfine |
| list-membership | koka | 284.073 | 0.723236 | 10 | 3.50781 | complete | false | hyperfine |
| list-membership | lean | 255.074 | 0.624667 | 10 | 8.94531 | complete | false | hyperfine |
| list-membership | morphic | 219.584 | 0.0960786 | 10 | 1.28125 | complete | false | hyperfine |
| list-membership | ocaml | 219.663 | 0.685763 | 10 | 6.18359 | complete | false | hyperfine |
| list-membership | reussir | 217.99 | 0.117161 | 10 | 3.77344 | complete | false | hyperfine |
| list-membership | reussir-nrac | 218.002 | 0.0944206 | 10 | 3.77344 | complete | false | hyperfine |
| list-membership | rust | 221.425 | 0.0768874 | 10 | 1.86719 | complete | false | hyperfine |
| list-membership | rust-with-mimalloc | 220.586 | 0.124492 | 10 | 5.82422 | complete | false | hyperfine |
| rbtree-lookup | haskell | 1345.68 | 7.31001 | 10 | 137.742 | complete | false | hyperfine |
| rbtree-lookup | haskell-a1g | 1183.02 | 3.86017 | 10 | 1081.49 | complete | false | hyperfine |
| rbtree-lookup | koka | 488.322 | 2.48181 | 10 | 41.4492 | complete | false | hyperfine |
| rbtree-lookup | lean | 879.423 | 7.48008 | 10 | 54.1758 | complete | false | hyperfine |
| rbtree-lookup | morphic | 1197.15 | 5.63297 | 10 | 77.0352 | complete | false | hyperfine |
| rbtree-lookup | ocaml | 1315.76 | 4.23953 | 10 | 130.266 | complete | false | hyperfine |
| rbtree-lookup | reussir | 448.805 | 3.02596 | 10 | 41.875 | complete | false | hyperfine |
| rbtree-lookup | reussir-nrac | 664.334 | 2.78568 | 10 | 41.875 | complete | false | hyperfine |
| rbtree-lookup | rust | 1257.46 | 5.55759 | 10 | 123.027 | complete | false | hyperfine |
| rbtree-lookup | rust-with-mimalloc | 1383 | 5.73881 | 10 | 95.5898 | complete | false | hyperfine |
