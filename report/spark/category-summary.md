# spark: categorized runtime

Each cell is arithmetic mean / median of per-case mean runtimes in seconds, with equal weight per case. Missing measurements are excluded and coverage is shown in brackets. X — takes too long; * includes reduced-sample results. Categories with different coverage are not directly comparable.

| Configuration | Functional data structures | Large aggregates | Standard-library collections | Arbitrary-precision integers | Traversals of shared data |
| --- | --- | --- | --- | --- | --- |
| haskell | 0.493 / 0.438 | 1.597 / 1.799 [3/6] | 4.442 / 3.658 | 0.830 / 0.624 | 0.837 / 0.694 |
| haskell-a1g | 0.686 / 0.270 | 1.534 / 2.100 [3/6] | 3.277 / 3.109 | 1.293 / 1.148 | 0.780 / 0.701 |
| haskell-st | — | 3.381 / 1.439 [5/6] | — | — | — |
| haskell-st-a1g | — | 3.447 / 1.447 [5/6] | — | — | — |
| koka | 0.283 / 0.192 | 9.051 / 3.475* | 11.894 / 1.786* | 4.938 / 4.505 | 0.485 / 0.529 |
| lean | 0.426 / 0.296 | 3.333 / 2.338 | 14.881 / 2.990* | 0.938 / 0.887 | 0.638 / 0.427 |
| morphic | 0.874 / 0.503 [8/9] | 2.301 / 0.811 [5/6] | 29.393 / 3.913* | — | 0.753 / 0.336 |
| ocaml | 0.596 / 0.554 | 3.015 / 1.881 | 16.454 / 2.995 [5/6]* + X | 1.740 / 1.058 | 0.851 / 0.348 |
| reussir | 0.235 / 0.183 | 0.379 / 0.280 | 1.914 / 1.386 | 0.542 / 0.459 | 0.349 / 0.323 |
| reussir-nrac | 0.313 / 0.197 | 0.216 / 0.228 [4/6] | 1.974 / 1.482 | 0.571 / 0.456 | 0.498 / 0.324 |
| rust | 1.379 / 0.846 | 0.368 / 0.288 | 9.239 / 1.902* | 2.505 / 2.076 | 0.794 / 0.360 |
| rust-rpds | — | — | 4.298 / 4.120 | — | — |
| rust-rpds-with-mimalloc | — | — | 2.832 / 2.535 | — | — |
| rust-with-mimalloc | 0.920 / 0.539 | 0.369 / 0.290 | 3.195 / 0.778 | 2.077 / 1.745 | 0.853 / 0.357 |

| Category | Cases |
| --- | --- |
| Functional data structures | mltt, rbtree, rbtree-zipper, nbe-hoas, nbe-closure, derive, heap-functional, fingertree, functional-queue |
| Large aggregates | rgba-composite, pcm-mix-limit, raytracer, life, qsort, heap-array |
| Standard-library collections | ordered-map-linear, ordered-map-shared, ordered-map-heavily-shared, hash-map-linear, hash-map-shared, hash-map-heavily-shared |
| Arbitrary-precision integers | bigint-fib, bigint-factorial, bigint-pidigits, bigint-rbtree, bigint-collatz, bigint-binomial |
| Traversals of shared data | list-membership, expr-replace, rbtree-lookup |
