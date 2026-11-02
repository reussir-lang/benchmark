# workstation benchmark comparison

workstation: 288 recorded cells accounted for; timing 287/288, footprint 287/288. Statuses: budget_exhausted=1, budget_limited=4, complete=283.

Time and RSS ratios are variant / default Reussir: above 1 means slower or more memory. Geometric means use only complete, non-budget-limited pairs with positive measurements. Timing and memory coverage can differ. X means takes too long (no completed measurement within 5 minutes). Blank CSV cells and — mean unavailable for other reasons; a single timing sample has no standard deviation.

Reussir: `36f05142f3b33f442f69afa421a10b7a39ee21f9`. Benchmark: `10f3826d1525903de23a92bae1d005094d838609`. Architecture: x86_64; measurement CPU: 1.

Compiler and runtime hashes are recorded in `provenance/manifest.json`. The compiler hash identifies the native ELF; the compiler launcher environment is recorded separately in `provenance/compiler-launch-environment.json`.

## Complete paired comparisons

| Variant | Available pairs | Timing pairs | Time / Reussir | Memory pairs | RSS / Reussir |
| --- | --- | --- | --- | --- | --- |
| haskell | 27 | 27 | 1.97228 | 27 | 2.98642 |
| haskell-a1g | 27 | 27 | 2.25557 | 27 | 32.5332 |
| haskell-st | 3 | 3 | 2.21164 | 3 | 1.68386 |
| haskell-st-a1g | 3 | 3 | 2.42482 | 3 | 29.5653 |
| koka | 28 | 27 | 2.03456 | 27 | 1.2627 |
| lean | 28 | 27 | 2.25658 | 27 | 2.01813 |
| morphic | 20 | 19 | 2.40134 | 19 | 1.06824 |
| ocaml | 28 | 26 | 2.27414 | 26 | 1.89661 |
| reussir | 28 | 28 | 1 | 28 | 1 |
| reussir-nrac | 28 | 28 | 1.07996 | 28 | 1.03298 |
| rust | 28 | 28 | 2.19282 | 28 | 1.59942 |
| rust-rpds | 6 | 6 | 2.43882 | 6 | 2.14318 |
| rust-rpds-with-mimalloc | 6 | 6 | 1.60113 | 6 | 1.81163 |
| rust-with-mimalloc | 28 | 28 | 1.89323 | 28 | 2.95668 |

## Functional data structures

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| derive | haskell | 722.469 | 5.36045 | 10 | 572.234 | complete | false | hyperfine |
| derive | haskell-a1g | 221.13 | 0.624647 | 10 | 634.734 | complete | false | hyperfine |
| derive | koka | 294.463 | 0.710041 | 10 | 455.492 | complete | false | hyperfine |
| derive | lean | 400.761 | 2.46841 | 10 | 552.117 | complete | false | hyperfine |
| derive | morphic | 605.301 | 2.43886 | 10 | 765.035 | complete | false | hyperfine |
| derive | ocaml | 499.298 | 1.77837 | 10 | 420.262 | complete | false | hyperfine |
| derive | reussir | 368.344 | 4.05425 | 10 | 455.773 | complete | false | hyperfine |
| derive | reussir-nrac | 374.611 | 1.29694 | 10 | 455.773 | complete | false | hyperfine |
| derive | rust | 1356.7 | 6.89457 | 10 | 1529.36 | complete | false | hyperfine |
| derive | rust-with-mimalloc | 911.278 | 8.93778 | 10 | 1535.8 | complete | false | hyperfine |
| fingertree | haskell | 68.998 | 0.288692 | 10 | 15.2422 | complete | false | hyperfine |
| fingertree | haskell-a1g | 278.764 | 1.342 | 10 | 683.742 | complete | false | hyperfine |
| fingertree | koka | 41.484 | 0.218411 | 10 | 5.50391 | complete | false | hyperfine |
| fingertree | lean | 68.3141 | 0.357573 | 10 | 12.6367 | complete | false | hyperfine |
| fingertree | morphic | 53.3253 | 0.189714 | 10 | 2.76172 | complete | false | hyperfine |
| fingertree | ocaml | 40.642 | 0.133966 | 10 | 16.2617 | complete | false | hyperfine |
| fingertree | reussir | 28.3035 | 0.434115 | 10 | 5.75 | complete | false | hyperfine |
| fingertree | reussir-nrac | 28.9986 | 0.609991 | 10 | 5.75 | complete | false | hyperfine |
| fingertree | rust | 55.7702 | 0.422362 | 10 | 7.0625 | complete | false | hyperfine |
| fingertree | rust-with-mimalloc | 56.6532 | 0.919987 | 10 | 9.55469 | complete | false | hyperfine |
| functional-queue | haskell | 31.3731 | 0.335341 | 10 | 13.2422 | complete | false | hyperfine |
| functional-queue | haskell-a1g | 84.6543 | 2.69664 | 10 | 266.992 | complete | false | hyperfine |
| functional-queue | koka | 55.057 | 0.804633 | 10 | 5.50391 | complete | false | hyperfine |
| functional-queue | lean | 60.402 | 0.346358 | 10 | 12.6836 | complete | false | hyperfine |
| functional-queue | morphic | 68.941 | 0.618883 | 10 | 5.51172 | complete | false | hyperfine |
| functional-queue | ocaml | 61.7829 | 0.347716 | 10 | 15.2734 | complete | false | hyperfine |
| functional-queue | reussir | 34.8724 | 0.0912892 | 10 | 5.92188 | complete | false | hyperfine |
| functional-queue | reussir-nrac | 34.9368 | 0.121551 | 10 | 5.92188 | complete | false | hyperfine |
| functional-queue | rust | 71.7264 | 1.30753 | 10 | 6.10938 | complete | false | hyperfine |
| functional-queue | rust-with-mimalloc | 66.1529 | 0.311724 | 10 | 8.04688 | complete | false | hyperfine |
| heap-functional | haskell | 1682.12 | 3.29891 | 10 | 13.4961 | complete | false | hyperfine |
| heap-functional | haskell-a1g | 1682.04 | 10.3988 | 10 | 1050.43 | complete | false | hyperfine |
| heap-functional | koka | 676.69 | 2.21859 | 10 | 5.50391 | complete | false | hyperfine |
| heap-functional | lean | 1220.6 | 15.3688 | 10 | 12.6875 | complete | false | hyperfine |
| heap-functional | morphic | 1913.37 | 18.9155 | 10 | 4.78516 | complete | false | hyperfine |
| heap-functional | ocaml | 2069.89 | 4.42893 | 10 | 16.2734 | complete | false | hyperfine |
| heap-functional | reussir | 672.249 | 0.536054 | 10 | 5.90625 | complete | false | hyperfine |
| heap-functional | reussir-nrac | 920.373 | 8.63966 | 10 | 5.91016 | complete | false | hyperfine |
| heap-functional | rust | 2081.34 | 35.6605 | 10 | 7.05859 | complete | false | hyperfine |
| heap-functional | rust-with-mimalloc | 2485.61 | 23.0962 | 10 | 11.5508 | complete | false | hyperfine |
| mltt | haskell | 913.594 | 0.531892 | 10 | 17.2109 | complete | false | hyperfine |
| mltt | haskell-a1g | 1408.37 | 40.9908 | 10 | 59.9609 | complete | false | hyperfine |
| mltt | koka | 1047.3 | 8.02559 | 10 | 11.4297 | complete | false | hyperfine |
| mltt | lean | 996.955 | 0.853582 | 10 | 14.7695 | complete | false | hyperfine |
| mltt | ocaml | 307.641 | 0.545259 | 10 | 11.793 | complete | false | hyperfine |
| mltt | reussir | 878.749 | 4.03089 | 10 | 12.2578 | complete | false | hyperfine |
| mltt | reussir-nrac | 881.912 | 1.3407 | 10 | 12.2578 | complete | false | hyperfine |
| mltt | rust | 531.899 | 1.92211 | 10 | 28.3594 | complete | false | hyperfine |
| mltt | rust-with-mimalloc | 888.297 | 1.62474 | 10 | 31.3672 | complete | false | hyperfine |
| nbe-closure | haskell | 83.7381 | 0.862059 | 10 | 82.9648 | complete | false | hyperfine |
| nbe-closure | haskell-a1g | 44.0252 | 0.186465 | 10 | 120.957 | complete | false | hyperfine |
| nbe-closure | koka | 148.333 | 1.2133 | 10 | 41.4492 | complete | false | hyperfine |
| nbe-closure | lean | 98.9593 | 1.18593 | 10 | 167.043 | complete | false | hyperfine |
| nbe-closure | morphic | 606.377 | 10.5443 | 10 | 168.512 | complete | false | hyperfine |
| nbe-closure | ocaml | 839.834 | 4.57252 | 10 | 152.23 | complete | false | hyperfine |
| nbe-closure | reussir | 121.742 | 0.953462 | 10 | 41.7695 | complete | false | hyperfine |
| nbe-closure | reussir-nrac | 134.08 | 0.5218 | 10 | 65.7031 | complete | false | hyperfine |
| nbe-closure | rust | 2537.95 | 65.7047 | 10 | 428.359 | complete | false | hyperfine |
| nbe-closure | rust-with-mimalloc | 735.247 | 66.9251 | 10 | 370.676 | complete | false | hyperfine |
| nbe-hoas | haskell | 90.6694 | 0.852838 | 10 | 78.9648 | complete | false | hyperfine |
| nbe-hoas | haskell-a1g | 68.5672 | 0.271442 | 10 | 164.957 | complete | false | hyperfine |
| nbe-hoas | koka | 155.618 | 1.38356 | 10 | 41.5039 | complete | false | hyperfine |
| nbe-hoas | lean | 107.305 | 1.05227 | 10 | 151.781 | complete | false | hyperfine |
| nbe-hoas | morphic | 482.597 | 10.1752 | 10 | 153.262 | complete | false | hyperfine |
| nbe-hoas | ocaml | 719.361 | 10.0768 | 10 | 147.234 | complete | false | hyperfine |
| nbe-hoas | reussir | 145.128 | 1.48566 | 10 | 41.7695 | complete | false | hyperfine |
| nbe-hoas | reussir-nrac | 155.309 | 1.21709 | 10 | 65.7695 | complete | false | hyperfine |
| nbe-hoas | rust | 2070.82 | 21.1579 | 10 | 413.062 | complete | false | hyperfine |
| nbe-hoas | rust-with-mimalloc | 675.279 | 18.2526 | 10 | 355.422 | complete | false | hyperfine |
| rbtree | haskell | 424.525 | 2.31641 | 10 | 174.242 | complete | false | hyperfine |
| rbtree | haskell-a1g | 662.415 | 2.36243 | 10 | 1175.24 | complete | false | hyperfine |
| rbtree | koka | 176.031 | 2.22676 | 10 | 99.5039 | complete | false | hyperfine |
| rbtree | lean | 834.918 | 5.75132 | 10 | 122.359 | complete | false | hyperfine |
| rbtree | morphic | 1181.79 | 8.01604 | 10 | 191.535 | complete | false | hyperfine |
| rbtree | ocaml | 343.299 | 1.65832 | 10 | 177.012 | complete | false | hyperfine |
| rbtree | reussir | 188.518 | 0.751906 | 10 | 97.875 | complete | false | hyperfine |
| rbtree | reussir-nrac | 343.031 | 2.72278 | 10 | 97.8789 | complete | false | hyperfine |
| rbtree | rust | 2368.46 | 10.9474 | 10 | 4924.31 | complete | false | hyperfine |
| rbtree | rust-with-mimalloc | 1390.54 | 9.06139 | 10 | 3760.77 | complete | false | hyperfine |
| rbtree-zipper | haskell | 359.135 | 1.24371 | 10 | 158.961 | complete | false | hyperfine |
| rbtree-zipper | haskell-a1g | 690.115 | 2.26726 | 10 | 1167.71 | complete | false | hyperfine |
| rbtree-zipper | koka | 151.252 | 0.412688 | 10 | 99.5039 | complete | false | hyperfine |
| rbtree-zipper | lean | 517.325 | 6.77323 | 10 | 122.367 | complete | false | hyperfine |
| rbtree-zipper | morphic | 1335.24 | 18.3278 | 10 | 191.535 | complete | false | hyperfine |
| rbtree-zipper | ocaml | 302.076 | 0.629605 | 10 | 178.766 | complete | false | hyperfine |
| rbtree-zipper | reussir | 129.214 | 0.550089 | 10 | 97.9062 | complete | false | hyperfine |
| rbtree-zipper | reussir-nrac | 129.22 | 0.354298 | 10 | 97.9062 | complete | false | hyperfine |
| rbtree-zipper | rust | 3248.17 | 17.3813 | 10 | 5153.36 | complete | false | hyperfine |
| rbtree-zipper | rust-with-mimalloc | 2828.45 | 33.3243 | 10 | 3989.54 | complete | false | hyperfine |

## Large aggregates

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| heap-array | haskell-st | 701.989 | 3.68757 | 10 | 7.99609 | complete | false | hyperfine |
| heap-array | haskell-st-a1g | 898.382 | 1.8752 | 10 | 1044.25 | complete | false | hyperfine |
| heap-array | koka | 2382.18 | 25.5549 | 10 | 3.47656 | complete | false | hyperfine |
| heap-array | lean | 1405.25 | 6.30181 | 10 | 13.6797 | complete | false | hyperfine |
| heap-array | morphic | 742.695 | 1.60469 | 10 | 1.01172 | complete | false | hyperfine |
| heap-array | ocaml | 1820.47 | 9.73382 | 10 | 9.27344 | complete | false | hyperfine |
| heap-array | reussir | 375.502 | 0.888047 | 10 | 3.90625 | complete | false | hyperfine |
| heap-array | reussir-nrac | 375.163 | 1.16499 | 10 | 3.90625 | complete | false | hyperfine |
| heap-array | rust | 386.538 | 4.83083 | 10 | 1.55859 | complete | false | hyperfine |
| heap-array | rust-with-mimalloc | 383.761 | 5.38994 | 10 | 5.55078 | complete | false | hyperfine |
| life | haskell | 1241.91 | 0.704053 | 10 | 9.36719 | complete | false | hyperfine |
| life | haskell-a1g | 1451.81 | 1.22146 | 10 | 1015.74 | complete | false | hyperfine |
| life | haskell-st | 1191.56 | 0.790879 | 10 | 3.74219 | complete | false | hyperfine |
| life | haskell-st-a1g | 1195.43 | 0.816876 | 10 | 19.9922 | complete | false | hyperfine |
| life | koka | 4320.05 | 2.97305 | 10 | 3.47656 | complete | false | hyperfine |
| life | lean | 3012.81 | 2.17219 | 10 | 8.73438 | complete | false | hyperfine |
| life | morphic | 777.331 | 0.46477 | 10 | 0.785156 | complete | false | hyperfine |
| life | ocaml | 1229.59 | 2.11149 | 10 | 5.02734 | complete | false | hyperfine |
| life | reussir | 298.493 | 0.139179 | 10 | 3.91406 | complete | false | hyperfine |
| life | reussir-nrac | 298.525 | 0.206639 | 10 | 3.91406 | complete | false | hyperfine |
| life | rust | 213.941 | 0.0670228 | 10 | 1.05469 | complete | false | hyperfine |
| life | rust-with-mimalloc | 218.599 | 0.0646049 | 10 | 5.54688 | complete | false | hyperfine |
| qsort | haskell | 2714.06 | 33.2654 | 10 | 29.1406 | complete | false | hyperfine |
| qsort | haskell-a1g | 2352.61 | 45.0201 | 10 | 1052.41 | complete | false | hyperfine |
| qsort | haskell-st | 421.149 | 0.419614 | 10 | 9.21484 | complete | false | hyperfine |
| qsort | haskell-st-a1g | 432.306 | 2.22116 | 10 | 71.4922 | complete | false | hyperfine |
| qsort | koka | 913.751 | 1.62802 | 10 | 9.47266 | complete | false | hyperfine |
| qsort | lean | 966.256 | 2.40802 | 10 | 10.8047 | complete | false | hyperfine |
| qsort | morphic | 448.162 | 1.08908 | 10 | 1.39453 | complete | false | hyperfine |
| qsort | ocaml | 945.338 | 1.56546 | 10 | 6.26562 | complete | false | hyperfine |
| qsort | reussir | 290.531 | 0.180084 | 10 | 3.77734 | complete | false | hyperfine |
| qsort | reussir-nrac | 290.714 | 0.179692 | 10 | 3.77734 | complete | false | hyperfine |
| qsort | rust | 276.351 | 0.669931 | 10 | 1.6875 | complete | false | hyperfine |
| qsort | rust-with-mimalloc | 276.487 | 0.302242 | 10 | 5.55078 | complete | false | hyperfine |
| raytracer | haskell | 202.545 | 1.03392 | 10 | 7.46875 | complete | false | hyperfine |
| raytracer | haskell-a1g | 233.157 | 1.62212 | 10 | 88.9766 | complete | false | hyperfine |
| raytracer | koka | 265.861 | 1.40276 | 10 | 3.76953 | complete | false | hyperfine |
| raytracer | lean | 2465.13 | 39.2822 | 10 | 8.64844 | complete | false | hyperfine |
| raytracer | ocaml | 373.094 | 0.300026 | 10 | 4.82031 | complete | false | hyperfine |
| raytracer | reussir | 73.9417 | 0.115531 | 10 | 3.87109 | complete | false | hyperfine |
| raytracer | reussir-nrac | 73.9435 | 0.0697648 | 10 | 3.87109 | complete | false | hyperfine |
| raytracer | rust | 73.7202 | 0.051417 | 10 | 1.35547 | complete | false | hyperfine |
| raytracer | rust-with-mimalloc | 73.8475 | 0.0311567 | 10 | 5.80469 | complete | false | hyperfine |

## Standard-library collections

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hash-map-heavily-shared | haskell | 3658.21 | 19.3206 | 10 | 279.238 | complete | false | hyperfine |
| hash-map-heavily-shared | haskell-a1g | 2683.62 | 7.89965 | 10 | 1227.99 | complete | false | hyperfine |
| hash-map-heavily-shared | koka | 96394.8 | 945.792 | 2 | 633.891 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | lean | 114790 | — | 1 | 262.391 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | morphic | 138258 | — | 1 | 548.656 | budget_limited | true | hyperfine |
| hash-map-heavily-shared | ocaml | X (takes too long) | — | 0 | X (takes too long) | budget_exhausted | true | — |
| hash-map-heavily-shared | reussir | 3348.42 | 9.47602 | 10 | 77.9062 | complete | false | hyperfine |
| hash-map-heavily-shared | reussir-nrac | 3321.67 | 19.447 | 10 | 77.9648 | complete | false | hyperfine |
| hash-map-heavily-shared | rust | 16305.2 | 24.5539 | 10 | 358.406 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-rpds | 5681.95 | 45.4734 | 10 | 163.113 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-rpds-with-mimalloc | 3698.81 | 37.3513 | 10 | 147.582 | complete | false | hyperfine |
| hash-map-heavily-shared | rust-with-mimalloc | 12025.9 | 143.166 | 10 | 456.496 | complete | false | hyperfine |
| hash-map-linear | haskell | 2465.92 | 7.44193 | 10 | 264.242 | complete | false | hyperfine |
| hash-map-linear | haskell-a1g | 2341.16 | 9.22725 | 10 | 1222.74 | complete | false | hyperfine |
| hash-map-linear | koka | 1106.68 | 2.79575 | 10 | 583.477 | complete | false | hyperfine |
| hash-map-linear | lean | 781.685 | 14.5788 | 10 | 94.9219 | complete | false | hyperfine |
| hash-map-linear | morphic | 649.004 | 18.1238 | 10 | 116.074 | complete | false | hyperfine |
| hash-map-linear | ocaml | 1577.78 | 7.27839 | 10 | 159.172 | complete | false | hyperfine |
| hash-map-linear | reussir | 746.97 | 3.18881 | 10 | 69.8828 | complete | false | hyperfine |
| hash-map-linear | reussir-nrac | 770.924 | 2.15768 | 10 | 69.8828 | complete | false | hyperfine |
| hash-map-linear | rust | 172.044 | 1.31197 | 10 | 52.3086 | complete | false | hyperfine |
| hash-map-linear | rust-rpds | 1350.58 | 9.00103 | 10 | 157.348 | complete | false | hyperfine |
| hash-map-linear | rust-rpds-with-mimalloc | 1146.68 | 10.4474 | 10 | 139.582 | complete | false | hyperfine |
| hash-map-linear | rust-with-mimalloc | 168.094 | 0.600927 | 10 | 81.5703 | complete | false | hyperfine |
| hash-map-shared | haskell | 3122.66 | 11.401 | 10 | 321.992 | complete | false | hyperfine |
| hash-map-shared | haskell-a1g | 2797.75 | 15.9862 | 10 | 1254.99 | complete | false | hyperfine |
| hash-map-shared | koka | 7622.15 | 105.593 | 10 | 628.938 | complete | false | hyperfine |
| hash-map-shared | lean | 8852.76 | 29.9677 | 10 | 256.176 | complete | false | hyperfine |
| hash-map-shared | morphic | 10060.5 | 27.6651 | 10 | 565.465 | complete | false | hyperfine |
| hash-map-shared | ocaml | 44527.9 | 36.2669 | 2 | 1470.55 | budget_limited | true | hyperfine |
| hash-map-shared | reussir | 3526.39 | 8.22705 | 10 | 109.965 | complete | false | hyperfine |
| hash-map-shared | reussir-nrac | 3491.96 | 27.3564 | 10 | 109.949 | complete | false | hyperfine |
| hash-map-shared | rust | 1198.79 | 2.72314 | 10 | 358.277 | complete | false | hyperfine |
| hash-map-shared | rust-rpds | 6049.59 | 48.3112 | 10 | 190.363 | complete | false | hyperfine |
| hash-map-shared | rust-rpds-with-mimalloc | 3765.14 | 8.45261 | 10 | 171.586 | complete | false | hyperfine |
| hash-map-shared | rust-with-mimalloc | 939.273 | 3.5566 | 10 | 503.621 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell | 6320.94 | 62.6601 | 10 | 2870.25 | complete | false | hyperfine |
| ordered-map-heavily-shared | haskell-a1g | 3775.18 | 12.651 | 10 | 2165.5 | complete | false | hyperfine |
| ordered-map-heavily-shared | koka | 936.248 | 6.43139 | 10 | 31.7227 | complete | false | hyperfine |
| ordered-map-heavily-shared | lean | 2055.15 | 10.8488 | 10 | 82.9141 | complete | false | hyperfine |
| ordered-map-heavily-shared | morphic | 2484.51 | 45.5989 | 10 | 48.0156 | complete | false | hyperfine |
| ordered-map-heavily-shared | ocaml | 2639.1 | 7.80301 | 10 | 143.766 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir | 758.959 | 0.813311 | 10 | 31.7695 | complete | false | hyperfine |
| ordered-map-heavily-shared | reussir-nrac | 754.095 | 0.77974 | 10 | 31.7734 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust | 12379.6 | 99.2198 | 10 | 126.363 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds | 3309.36 | 12.0304 | 10 | 72.5625 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-rpds-with-mimalloc | 1930.27 | 14.32 | 10 | 57.5625 | complete | false | hyperfine |
| ordered-map-heavily-shared | rust-with-mimalloc | 11346.9 | 36.9172 | 10 | 123.504 | complete | false | hyperfine |
| ordered-map-linear | haskell | 1998.82 | 5.51877 | 10 | 110.246 | complete | false | hyperfine |
| ordered-map-linear | haskell-a1g | 1912 | 4.06187 | 10 | 1093.5 | complete | false | hyperfine |
| ordered-map-linear | koka | 571.397 | 2.64032 | 10 | 23.7266 | complete | false | hyperfine |
| ordered-map-linear | lean | 1110.6 | 6.5832 | 10 | 70.9609 | complete | false | hyperfine |
| ordered-map-linear | morphic | 1362.33 | 8.16361 | 10 | 34.7656 | complete | false | hyperfine |
| ordered-map-linear | ocaml | 2218.17 | 9.61307 | 10 | 131.051 | complete | false | hyperfine |
| ordered-map-linear | reussir | 477.349 | 2.33207 | 10 | 23.7578 | complete | false | hyperfine |
| ordered-map-linear | reussir-nrac | 485.149 | 0.938246 | 10 | 23.7617 | complete | false | hyperfine |
| ordered-map-linear | rust | 243.021 | 0.644163 | 10 | 13.6094 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds | 1542.06 | 11.6624 | 10 | 55.6094 | complete | false | hyperfine |
| ordered-map-linear | rust-rpds-with-mimalloc | 960.567 | 4.52156 | 10 | 45.5547 | complete | false | hyperfine |
| ordered-map-linear | rust-with-mimalloc | 224.197 | 0.852011 | 10 | 15.5547 | complete | false | hyperfine |
| ordered-map-shared | haskell | 6327.87 | 48.3155 | 10 | 2870.25 | complete | false | hyperfine |
| ordered-map-shared | haskell-a1g | 3776.93 | 15.296 | 10 | 2165.5 | complete | false | hyperfine |
| ordered-map-shared | koka | 1537.17 | 7.07054 | 10 | 59.7227 | complete | false | hyperfine |
| ordered-map-shared | lean | 2540.77 | 5.814 | 10 | 130.656 | complete | false | hyperfine |
| ordered-map-shared | morphic | 3237.33 | 28.7245 | 10 | 97.0156 | complete | false | hyperfine |
| ordered-map-shared | ocaml | 2635.53 | 14.1501 | 10 | 219.516 | complete | false | hyperfine |
| ordered-map-shared | reussir | 1283.41 | 2.90382 | 10 | 57.7695 | complete | false | hyperfine |
| ordered-map-shared | reussir-nrac | 1283.46 | 9.39323 | 10 | 57.7734 | complete | false | hyperfine |
| ordered-map-shared | rust | 971.929 | 13.8805 | 10 | 126.113 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds | 3642.4 | 14.9105 | 10 | 128.312 | complete | false | hyperfine |
| ordered-map-shared | rust-rpds-with-mimalloc | 2333.62 | 8.04666 | 10 | 99.5664 | complete | false | hyperfine |
| ordered-map-shared | rust-with-mimalloc | 905.1 | 2.77839 | 10 | 129.57 | complete | false | hyperfine |

## Arbitrary-precision integers

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| bigint-binomial | haskell | 1245.01 | 1.04846 | 10 | 15.1836 | complete | false | hyperfine |
| bigint-binomial | haskell-a1g | 1740.54 | 1.52757 | 10 | 1283.93 | complete | false | hyperfine |
| bigint-binomial | koka | 5421.95 | 2.08458 | 10 | 4.78906 | complete | false | hyperfine |
| bigint-binomial | lean | 1835.39 | 4.12611 | 10 | 8.91797 | complete | false | hyperfine |
| bigint-binomial | ocaml | 1546.6 | 8.43389 | 10 | 5.92578 | complete | false | hyperfine |
| bigint-binomial | reussir | 1195.64 | 0.393876 | 10 | 5.69531 | complete | false | hyperfine |
| bigint-binomial | reussir-nrac | 1195.64 | 0.646559 | 10 | 5.69531 | complete | false | hyperfine |
| bigint-binomial | rust | 1823.3 | 0.848789 | 10 | 1.35156 | complete | false | hyperfine |
| bigint-binomial | rust-with-mimalloc | 1824.48 | 3.39161 | 10 | 5.79688 | complete | false | hyperfine |
| bigint-collatz | haskell | 1053.55 | 1.86326 | 10 | 7.48047 | complete | false | hyperfine |
| bigint-collatz | haskell-a1g | 1265.82 | 2.79162 | 10 | 1043.73 | complete | false | hyperfine |
| bigint-collatz | koka | 176.558 | 0.300063 | 10 | 3.48047 | complete | false | hyperfine |
| bigint-collatz | lean | 214.418 | 1.41921 | 10 | 8.64062 | complete | false | hyperfine |
| bigint-collatz | ocaml | 700.488 | 0.473931 | 10 | 4.45312 | complete | false | hyperfine |
| bigint-collatz | reussir | 150.262 | 1.44927 | 10 | 1.60938 | complete | false | hyperfine |
| bigint-collatz | reussir-nrac | 150.202 | 1.28156 | 10 | 1.60938 | complete | false | hyperfine |
| bigint-collatz | rust | 419.412 | 0.314679 | 10 | 1.34766 | complete | false | hyperfine |
| bigint-collatz | rust-with-mimalloc | 419.205 | 0.294039 | 10 | 5.80078 | complete | false | hyperfine |
| bigint-factorial | haskell | 718.093 | 0.530022 | 10 | 14.207 | complete | false | hyperfine |
| bigint-factorial | haskell-a1g | 1096.64 | 2.11178 | 10 | 1346.96 | complete | false | hyperfine |
| bigint-factorial | koka | 5638.53 | 3.34569 | 10 | 5.46875 | complete | false | hyperfine |
| bigint-factorial | lean | 1409.63 | 1.2988 | 10 | 9.83203 | complete | false | hyperfine |
| bigint-factorial | ocaml | 1177.92 | 7.70821 | 10 | 7.73828 | complete | false | hyperfine |
| bigint-factorial | reussir | 699.408 | 0.139553 | 10 | 7.44531 | complete | false | hyperfine |
| bigint-factorial | reussir-nrac | 699.357 | 0.124075 | 10 | 7.44531 | complete | false | hyperfine |
| bigint-factorial | rust | 716.98 | 0.136115 | 10 | 1.60156 | complete | false | hyperfine |
| bigint-factorial | rust-with-mimalloc | 717.284 | 0.214194 | 10 | 9.80469 | complete | false | hyperfine |
| bigint-fib | haskell | 419.341 | 0.566818 | 10 | 16.2109 | complete | false | hyperfine |
| bigint-fib | haskell-a1g | 1335.23 | 4.87029 | 10 | 1409.21 | complete | false | hyperfine |
| bigint-fib | koka | 5784.69 | 2.03221 | 10 | 5.38672 | complete | false | hyperfine |
| bigint-fib | lean | 1143.26 | 4.16925 | 10 | 8.91406 | complete | false | hyperfine |
| bigint-fib | ocaml | 857.996 | 10.3898 | 10 | 6.29688 | complete | false | hyperfine |
| bigint-fib | reussir | 379.046 | 0.601696 | 10 | 5.81641 | complete | false | hyperfine |
| bigint-fib | reussir-nrac | 379.244 | 0.329335 | 10 | 5.81641 | complete | false | hyperfine |
| bigint-fib | rust | 537.381 | 0.131039 | 10 | 1.60156 | complete | false | hyperfine |
| bigint-fib | rust-with-mimalloc | 535.736 | 0.102117 | 10 | 7.80469 | complete | false | hyperfine |
| bigint-pidigits | haskell | 413.892 | 0.272756 | 10 | 15.418 | complete | false | hyperfine |
| bigint-pidigits | haskell-a1g | 858.393 | 1.29536 | 10 | 1298.44 | complete | false | hyperfine |
| bigint-pidigits | koka | 4691.86 | 3.53594 | 10 | 41.1992 | complete | false | hyperfine |
| bigint-pidigits | lean | 845.027 | 1.31752 | 10 | 9.13281 | complete | false | hyperfine |
| bigint-pidigits | ocaml | 625.597 | 6.30876 | 10 | 6.78906 | complete | false | hyperfine |
| bigint-pidigits | reussir | 415.916 | 0.178034 | 10 | 5.82812 | complete | false | hyperfine |
| bigint-pidigits | reussir-nrac | 416.184 | 0.163068 | 10 | 5.82812 | complete | false | hyperfine |
| bigint-pidigits | rust | 1597.46 | 23.193 | 10 | 2.35938 | complete | false | hyperfine |
| bigint-pidigits | rust-with-mimalloc | 1293.44 | 33.7489 | 10 | 11.8125 | complete | false | hyperfine |
| bigint-rbtree | haskell | 538.251 | 3.47269 | 10 | 179.234 | complete | false | hyperfine |
| bigint-rbtree | haskell-a1g | 847.812 | 3.07647 | 10 | 1216.23 | complete | false | hyperfine |
| bigint-rbtree | koka | 191.5 | 0.876325 | 10 | 117.5 | complete | false | hyperfine |
| bigint-rbtree | lean | 873.917 | 6.22418 | 10 | 122.109 | complete | false | hyperfine |
| bigint-rbtree | ocaml | 341.531 | 2.73363 | 10 | 120.199 | complete | false | hyperfine |
| bigint-rbtree | reussir | 203.441 | 1.42216 | 10 | 117.922 | complete | false | hyperfine |
| bigint-rbtree | reussir-nrac | 377.897 | 2.54524 | 10 | 117.922 | complete | false | hyperfine |
| bigint-rbtree | rust | 3260.66 | 25.3159 | 10 | 7577.11 | complete | false | hyperfine |
| bigint-rbtree | rust-with-mimalloc | 2202.52 | 19.5038 | 10 | 7600.72 | complete | false | hyperfine |

## Traversals of shared data

| Benchmark | Variant | Mean ms | SD ms | n | Peak RSS MiB | Status | Budget limited | Timing source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| expr-replace | haskell | 346.955 | 11.1108 | 10 | 3.98828 | complete | false | hyperfine |
| expr-replace | haskell-a1g | 358.316 | 11.1463 | 10 | 19.9883 | complete | false | hyperfine |
| expr-replace | koka | 576.43 | 12.645 | 10 | 3.50391 | complete | false | hyperfine |
| expr-replace | lean | 390.878 | 12.758 | 10 | 8.66016 | complete | false | hyperfine |
| expr-replace | morphic | 361.255 | 2.15807 | 10 | 1.03516 | complete | false | hyperfine |
| expr-replace | ocaml | 387.201 | 7.34595 | 10 | 4.00781 | complete | false | hyperfine |
| expr-replace | reussir | 497.419 | 12.7313 | 10 | 3.86719 | complete | false | hyperfine |
| expr-replace | reussir-nrac | 494.669 | 3.22661 | 10 | 3.86719 | complete | false | hyperfine |
| expr-replace | rust | 367.488 | 8.52366 | 10 | 1.55859 | complete | false | hyperfine |
| expr-replace | rust-with-mimalloc | 363.305 | 5.44175 | 10 | 5.55078 | complete | false | hyperfine |
| list-membership | haskell | 249.798 | 0.133281 | 10 | 3.71094 | complete | false | hyperfine |
| list-membership | haskell-a1g | 253.911 | 0.46876 | 10 | 19.9609 | complete | false | hyperfine |
| list-membership | koka | 284.073 | 0.723236 | 10 | 3.50781 | complete | false | hyperfine |
| list-membership | lean | 294.31 | 0.0761133 | 10 | 8.66406 | complete | false | hyperfine |
| list-membership | morphic | 219.584 | 0.0960786 | 10 | 1.28125 | complete | false | hyperfine |
| list-membership | ocaml | 222.428 | 0.127838 | 10 | 4.01953 | complete | false | hyperfine |
| list-membership | reussir | 217.99 | 0.117161 | 10 | 3.77344 | complete | false | hyperfine |
| list-membership | reussir-nrac | 218.002 | 0.0944206 | 10 | 3.77344 | complete | false | hyperfine |
| list-membership | rust | 220.015 | 0.123585 | 10 | 1.80469 | complete | false | hyperfine |
| list-membership | rust-with-mimalloc | 219.163 | 0.0544479 | 10 | 5.79688 | complete | false | hyperfine |
| rbtree-lookup | haskell | 1345.68 | 7.31001 | 10 | 137.742 | complete | false | hyperfine |
| rbtree-lookup | haskell-a1g | 1183.02 | 3.86017 | 10 | 1081.49 | complete | false | hyperfine |
| rbtree-lookup | koka | 488.322 | 2.48181 | 10 | 41.4492 | complete | false | hyperfine |
| rbtree-lookup | lean | 927.85 | 3.77981 | 10 | 54.1055 | complete | false | hyperfine |
| rbtree-lookup | morphic | 1197.15 | 5.63297 | 10 | 77.0352 | complete | false | hyperfine |
| rbtree-lookup | ocaml | 1482.11 | 6.8576 | 10 | 161.766 | complete | false | hyperfine |
| rbtree-lookup | reussir | 448.805 | 3.02596 | 10 | 41.875 | complete | false | hyperfine |
| rbtree-lookup | reussir-nrac | 664.334 | 2.78568 | 10 | 41.875 | complete | false | hyperfine |
| rbtree-lookup | rust | 1266.27 | 5.44986 | 10 | 123.059 | complete | false | hyperfine |
| rbtree-lookup | rust-with-mimalloc | 1406.72 | 8.53381 | 10 | 95.5625 | complete | false | hyperfine |
