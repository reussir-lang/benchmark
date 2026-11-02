# workstation: categorized runtime

Each cell is arithmetic mean / median of per-case mean runtimes in seconds, with equal weight per case. Missing measurements are excluded and coverage is shown in brackets. X — takes too long; * includes reduced-sample results. Categories with different coverage are not directly comparable.

| Configuration | Functional data structures | Large aggregates | Standard-library collections | Arbitrary-precision integers | Traversals of shared data |
| --- | --- | --- | --- | --- | --- |
| haskell | 0.486 / 0.359 | 1.386 / 1.242 [3/4] | 3.982 / 3.390 | 0.731 / 0.628 | 0.647 / 0.347 |
| haskell-a1g | 0.571 / 0.279 | 1.346 / 1.452 [3/4] | 2.881 / 2.741 | 1.191 / 1.181 | 0.598 / 0.358 |
| haskell-st | — | 0.772 / 0.702 [3/4] | — | — | — |
| haskell-st-a1g | — | 0.842 / 0.898 [3/4] | — | — | — |
| koka | 0.305 / 0.156 | 1.970 / 1.648 | 18.028 / 1.322* | 3.651 / 5.057 | 0.450 / 0.488 |
| lean | 0.426 / 0.297 | 1.800 / 1.068 | 19.728 / 2.327* | 1.008 / 0.989 | 0.530 / 0.456 |
| morphic | 0.781 / 0.606 [8/9] | 0.656 / 0.743 [3/4] | 26.009 / 2.861* | — | 0.593 / 0.361 |
| ocaml | 0.455 / 0.319 | 0.888 / 1.066 | 10.730 / 2.202 [5/6]* + X | 1.398 / 1.020 | 0.638 / 0.378 |
| reussir | 0.285 / 0.145 | 0.260 / 0.295 | 1.690 / 1.021 | 0.507 / 0.397 | 0.388 / 0.449 |
| reussir-nrac | 0.334 / 0.155 | 0.260 / 0.295 | 1.685 / 1.027 | 0.536 / 0.398 | 0.459 / 0.495 |
| rust | 1.545 / 2.013 | 0.226 / 0.227 | 5.134 / 1.075 | 1.366 / 1.157 | 0.613 / 0.360 |
| rust-rpds | — | — | 3.467 / 3.368 | — | — |
| rust-rpds-with-mimalloc | — | — | 2.207 / 2.077 | — | — |
| rust-with-mimalloc | 1.103 / 0.874 | 0.225 / 0.228 | 4.198 / 0.911 | 1.160 / 0.987 | 0.652 / 0.354 |

| Category | Cases |
| --- | --- |
| Functional data structures | mltt, rbtree, rbtree-zipper, nbe-hoas, nbe-closure, derive, heap-functional, fingertree, functional-queue |
| Large aggregates | raytracer, life, qsort, heap-array |
| Standard-library collections | ordered-map-linear, ordered-map-shared, ordered-map-heavily-shared, hash-map-linear, hash-map-shared, hash-map-heavily-shared |
| Arbitrary-precision integers | bigint-fib, bigint-factorial, bigint-pidigits, bigint-rbtree, bigint-collatz, bigint-binomial |
| Traversals of shared data | list-membership, expr-replace, rbtree-lookup |
