#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
output_dir=${1:-"$source_dir/build-lean"}
lean_toolchain=${LEAN4_ROOT:?Set LEAN4_ROOT to a Lean 4.34 toolchain directory}
mkdir -p "$output_dir/Render"
cp "$source_dir/lean/Raytracer.lean" "$output_dir/"
cp "$source_dir/lean/Render/Vec3.lean" "$output_dir/Render/"
cd "$output_dir"
export LEAN_PATH=.
export LEAN_CC=$PWD/cached-cc.sh
printf '#!/usr/bin/env bash\nexec sccache %q "$@"\n' "$lean_toolchain/bin/clang" > "$LEAN_CC"
chmod +x "$LEAN_CC"
sccache --show-stats > sccache-before.txt
"$lean_toolchain/bin/lean" -o Render/Vec3.olean -c Render/Vec3.c Render/Vec3.lean
"$lean_toolchain/bin/lean" -o Raytracer.olean -c Raytracer.c Raytracer.lean
"$lean_toolchain/bin/leanc" --sysroot "$lean_toolchain" -nostdinc \
  -isystem "$lean_toolchain/include/clang" -O3 -flto -c Render/Vec3.c -o Vec3.o
"$lean_toolchain/bin/leanc" --sysroot "$lean_toolchain" -nostdinc \
  -isystem "$lean_toolchain/include/clang" -O3 -flto -c Raytracer.c -o Raytracer.o
env -u LEAN_CC "$lean_toolchain/bin/leanc" -O3 -flto Raytracer.o Vec3.o -o lean-original
sccache --show-stats > sccache-after.txt
