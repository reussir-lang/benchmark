# Raytracer comparison

`native.rr` is a direct Reussir port of Kyle Miller's
[Lean raytracer](https://github.com/kmill/lean4-raytracer/tree/205143b32c006199c914cf6f340004137aaaa72a),
also used by lean-to-reussir's `tests/apps/raytracer`.

The single-thread entry renders 128 × 85 pixels, four samples per pixel,
and ten bounces, preserving the original scene and continuous StdGen stream.
It computes a checksum of gamma-corrected RGB bytes weighted by their
one-based position. Vector, material, ray, and RNG records use value storage.

The separate chunk entry renders eight fixed row ranges. Each chunk builds
the same scene; each row starts with seed `row + 1`. This mode makes the
work and output independent of the worker count and is compared separately
from the original continuous-stream workload. All rendering and checksumming
remain in Reussir; the C driver only prints the result.
