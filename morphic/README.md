# Morphic benchmark sources

The Morphic cells compile with the Morphic compiler
(<https://github.com/morphic-lang/morphic>) pinned in `flake.nix`. Its
default configuration is used: borrow-inferred reference counting, copy-on-write
arrays updated in place when uniquely referenced, LLVM `-O3` for the host CPU.

`lib/` vendors the Morphic library the programs import with
`module Core = file "lib/core/core.mor"` (Morphic resolves `file` imports
relative to the importing source, so the library sits beside the programs):

- `lib/core/`: Morphic's core library (`samples/lib/core`).
- `lib/hashmap.mor`: Morphic's sample hash map (`samples/lib/hashmap.mor`), a
  bucket hash map over copy-on-write arrays, used by the hash-map benchmarks.
  Added for the suite: `size` and `foldl`. Otherwise it is kept as shipped,
  including its bucket index, which negates a negative hash and so overflows
  for the minimum `I64`; the hash-map programs clear the sign bit of their
  hash (XXH64 of the key, as in the Koka cells) to stay clear of it.

Source: https://github.com/morphic-lang/morphic
Commit: da679c4 (the revision `flake.nix` builds; the library must match the compiler)
License: MIT (see `lib/LICENSE`)

Morphic has no arbitrary-precision integers, so the big-integers set has no
Morphic cells. Its library ships no ordered map, so the ordered-map benchmarks
use `lib/ordmap.mor`, a persistent red-black tree written for this suite.
