# Vendored subset of koka-community/std

Source: https://github.com/koka-community/std
Commit: f79a7cadd9bbdbeac67f9f1a11d800b7f292a9fc
License: MIT (see LICENSE)

Koka's bundled standard library ships no usable map containers
(`std/data/map` and `std/data/dict` are stubs), so the std-collections
benchmarks use the community standard library instead: `std/data/hashmap`
(a bucket hash map over a uniqueness-adaptive vector) for the hash-map
benchmarks and `std/data/rbtree-bu` (a persistent red-black tree with
bottom-up insert and remove) for the ordered-map benchmarks. Only the
modules those two need are vendored here; `compile.py` passes this
directory to the Koka compiler with `-i`.
