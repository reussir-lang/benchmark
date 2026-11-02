#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
output_dir=${1:-"$source_dir/build-native"}
mkdir -p "$output_dir"
output_dir=$(cd "$output_dir" && pwd)
compiler=${REUSSIR_COMPILER:-rrc}
cc=${CC:-clang}
runtime_dir=${REUSSIR_LIBS:?Set REUSSIR_LIBS to the directory containing libreussir_rt.a}
cd "$output_dir"
sccache --show-stats > sccache-before.txt
"$compiler" "$source_dir/native.rr" -Oaggressive --reuse-across-call -t llvm-ir \
  --token-reuse-remarks reuse.json -o native.ll
sccache "$cc" -c -O3 -march=native -flto=thin -fsave-optimization-record \
  -foptimization-record-file=llvm-remarks.yaml native.ll -o native.o
sccache "$cc" -c -O3 -march=native -flto=thin "$source_dir/native.c" -o driver.o
"$cc" native.o driver.o -flto=thin -fuse-ld=lld -O3 -march=native \
  "$runtime_dir/libreussir_rt.a" -lm -o native
sccache --show-stats > sccache-after.txt
