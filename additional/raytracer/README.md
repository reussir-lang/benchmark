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
