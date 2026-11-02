# workstation: categorized runtime

Each cell is arithmetic mean / median of per-case mean runtimes in seconds, with equal weight per case. Missing measurements are excluded and coverage is shown in brackets. X — takes too long; * includes reduced-sample results. Categories with different coverage are not directly comparable.

| Configuration | Functional data structures | Large aggregates | Standard-library collections | Arbitrary-precision integers | Traversals of shared data |
| --- | --- | --- | --- | --- | --- |
| haskell | 0.486 / 0.359 | 1.386 / 1.242 [3/4] | 3.982 / 3.390 | 0.731 / 0.628 | 0.647 / 0.347 |
| haskell-a1g | 0.571 / 0.279 | 1.346 / 1.452 [3/4] | 2.881 / 2.741 | 1.191 / 1.181 | 0.598 / 0.358 |
| haskell-st | — | 0.772 / 0.702 [3/4] | — | — | — |
| haskell-st-a1g | — | 0.842 / 0.898 [3/4] | — | — | — |
| koka | 0.305 / 0.156 | 1.970 / 1.648 | 18.028 / 1.322* | 3.651 / 5.057 | 0.450 / 0.488 |
| lean | 0.478 / 0.401 | 1.962 / 1.935 | 21.689 / 2.298* | 1.054 / 1.009 | 0.538 / 0.391 |
| morphic | 0.781 / 0.606 [8/9] | 0.656 / 0.743 [3/4] | 26.009 / 2.861* | — | 0.593 / 0.361 |
| ocaml | 0.576 / 0.343 | 1.092 / 1.087 | 10.720 / 2.636 [5/6]* + X | 0.875 / 0.779 | 0.697 / 0.387 |
| reussir | 0.285 / 0.145 | 0.260 / 0.295 | 1.690 / 1.021 | 0.507 / 0.397 | 0.388 / 0.449 |
| reussir-nrac | 0.334 / 0.155 | 0.260 / 0.295 | 1.685 / 1.027 | 0.536 / 0.398 | 0.459 / 0.495 |
| rust | 1.591 / 2.071 | 0.238 / 0.245 | 5.212 / 1.085 | 1.393 / 1.157 | 0.618 / 0.367 |
| rust-rpds | — | — | 3.596 / 3.476 | — | — |
| rust-rpds-with-mimalloc | — | — | 2.306 / 2.132 | — | — |
| rust-with-mimalloc | 1.115 / 0.888 | 0.238 / 0.248 | 4.268 / 0.922 | 1.165 / 1.005 | 0.663 / 0.363 |

| Category | Cases |
| --- | --- |
| Functional data structures | mltt, rbtree, rbtree-zipper, nbe-hoas, nbe-closure, derive, heap-functional, fingertree, functional-queue |
| Large aggregates | raytracer, life, qsort, heap-array |
| Standard-library collections | ordered-map-linear, ordered-map-shared, ordered-map-heavily-shared, hash-map-linear, hash-map-shared, hash-map-heavily-shared |
| Arbitrary-precision integers | bigint-fib, bigint-factorial, bigint-pidigits, bigint-rbtree, bigint-collatz, bigint-binomial |
| Traversals of shared data | list-membership, expr-replace, rbtree-lookup |
