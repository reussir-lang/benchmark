# Raytracer comparison

`native.rr` is a direct Reussir port of Kyle Miller's
[Lean raytracer](https://github.com/kmill/lean4-raytracer/tree/205143b32c006199c914cf6f340004137aaaa72a),
also used by lean-to-reussir's `tests/apps/raytracer`.

The single-thread entry renders 128 × 85 pixels, four samples per pixel,
and ten bounces, preserving the original scene and continuous StdGen stream.
It computes a checksum of gamma-corrected RGB bytes weighted by their
one-based position. Vector, material, ray, and RNG records use value storage. Sphere records
use shared storage, as required by the current array element support.

The checksum is `64158141444`, matching the original Lean implementation.
All rendering and checksumming remain in Reussir; the C driver only checks
and prints the result. Compiler reuse remarks show allocations confined to
scene construction; the rendered image loop uses value records and borrowed
scene access. LLVM optimization remarks are captured alongside measurements.

The matching Lean source is in `lean/`, with its adaptations listed in
`lean/NOTICE`. Run `build-lean.sh` with `LEAN4_ROOT` pointing to Lean 4.34,
and `build-native.sh` with `REUSSIR_COMPILER` and `REUSSIR_LIBS` from the
benchmark environment. Both scripts retain sccache statistics and accept an
optional output directory. Native compilation also saves reuse and LLVM
optimization remarks. The resulting executables print checksum `64158141444`.
The Lean executable optionally accepts a PPM filename for image inspection.

A separate pixel-output validation produced a byte-identical PPM image to
Lean, SHA-256 `a9b7a4ff8fe0c9a6afcbac9001502ef10f8f2e041aad60853eef000ca336edf8`.
Image writing is excluded from the measured executables.

From the benchmark repository's root and its toolchain environment, use the
existing bounded sampler for each executable:

```sh
taskset -c 1 env LEAN_NUM_THREADS=1 python -c \
  'import json, sys; from runner import measure_executable; print(json.dumps(measure_executable(sys.argv[1])))' \
  /absolute/path/to/executable
```

The configured sampler uses ten timing samples, five warmups, and a shared
five-minute measurement budget. Peak RSS comes from one completed run.

Both builds target the workstation CPU with `-march=native`. Lean uses its
bundled Clang 22 at `-O3 -flto`; Reussir #913 emits optimized LLVM IR and
links with Clang 23 at `-O3 -flto=thin`. These compiler/LTO differences are
part of the language toolchains used for this comparison.
