# spark: categorized runtime

Each cell is arithmetic mean / median of per-case mean runtimes in seconds, with equal weight per case. Missing measurements are excluded and coverage is shown in brackets. X — takes too long; * includes reduced-sample results. Categories with different coverage are not directly comparable.

| Configuration | Functional data structures | Large aggregates | Standard-library collections | Arbitrary-precision integers | Traversals of shared data |
| --- | --- | --- | --- | --- | --- |
| haskell | 0.487 / 0.272 | 1.597 / 1.799 [3/4] | 4.442 / 3.658 | 0.830 / 0.624 | 0.837 / 0.694 |
| haskell-a1g | 0.556 / 0.264 | 1.534 / 2.100 [3/4] | 3.277 / 3.109 | 1.293 / 1.148 | 0.780 / 0.701 |
| haskell-st | — | 0.943 / 0.931 [3/4] | — | — | — |
| haskell-st-a1g | — | 1.052 / 1.230 [3/4] | — | — | — |
| koka | 0.215 / 0.186 | 2.118 / 1.758 | 11.894 / 1.786* | 4.938 / 4.505 | 0.485 / 0.529 |
| lean | 0.378 / 0.183 | 2.124 / 2.097 | 16.232 / 2.943* | 0.973 / 0.934 | 0.648 / 0.402 |
| morphic | 0.874 / 0.503 | 0.696 / 0.780 [3/4] | 29.393 / 3.913* | — | 0.753 / 0.336 |
| ocaml | 0.749 / 0.539 | 1.528 / 1.429 | 16.063 / 2.962 [5/6]* + X | 0.913 / 0.811 | 0.830 / 0.338 |
| reussir | 0.206 / 0.188 | 0.217 / 0.228 | 1.951 / 1.479 | 0.545 / 0.456 | 0.351 / 0.324 |
| reussir-nrac | 0.281 / 0.194 | 0.217 / 0.228 | 1.970 / 1.485 | 0.572 / 0.457 | 0.500 / 0.324 |
| rust | 1.487 / 0.970 | 0.182 / 0.210 | 9.206 / 1.904* | 2.531 / 2.079 | 0.800 / 0.359 |
| rust-rpds | — | — | 4.371 / 4.215 | — | — |
| rust-rpds-with-mimalloc | — | — | 2.900 / 2.613 | — | — |
| rust-with-mimalloc | 0.980 / 0.512 | 0.182 / 0.210 | 3.258 / 0.785 | 2.103 / 1.758 | 0.859 / 0.355 |

| Category | Cases |
| --- | --- |
| Functional data structures | rbtree, rbtree-zipper, nbe-hoas, nbe-closure, derive, heap-functional, fingertree, functional-queue |
| Large aggregates | raytracer, life, qsort, heap-array |
| Standard-library collections | ordered-map-linear, ordered-map-shared, ordered-map-heavily-shared, hash-map-linear, hash-map-shared, hash-map-heavily-shared |
| Arbitrary-precision integers | bigint-fib, bigint-factorial, bigint-pidigits, bigint-rbtree, bigint-collatz, bigint-binomial |
| Traversals of shared data | list-membership, expr-replace, rbtree-lookup |
