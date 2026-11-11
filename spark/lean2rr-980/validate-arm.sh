set -euo pipefail
out="/tmp/reussir-paper-refresh-20261111/lean2rr-fixed"
stack="$HOME/Documents/paper-evidence-20261110/lean434/stack"
export L2R_REUSSIR="$stack/reussir-l2r"
export L2R_LEAN2RR="$stack/lean-to-reussir/lean2rr/.lake/build/bin/lean2rr"
export L2R_RUSTC="$(cat "$stack/l2r-rustc-path.txt")"
export L2R_TEST_BUILD="$out/cells"
export L2R_BENCH_TIMEOUT=900
export REUSSIR_FFI_CACHE_DIR="$out/polyffi-cache"
export RUSTC_WRAPPER=sccache
export PATH="$HOME/.elan/bin:$PATH"
ulimit -s unlimited
mapfile -t names < "$out/membership.txt"
test "${#names[@]}" -eq 18
{
 date --iso-8601=seconds
 git -C "$L2R_REUSSIR" rev-parse HEAD HEAD^{tree}
 git -C "$L2R_REUSSIR" status --porcelain
 git -C "$stack/lean-to-reussir" rev-parse HEAD HEAD^{tree}
 git -C "$stack/lean-to-reussir" submodule status
 echo 1cf406dffa22b8bfc65eeb30241e8154f27a5505
 "$L2R_RUSTC" -Vv
 cat "$L2R_REUSSIR/build/target-rt/.rustc_info.json"
 "$HOME/.elan/toolchains/leanprover--lean4---v4.34.0/bin/lean" --version
 sha256sum "$L2R_REUSSIR/build/bin/rrc" "$L2R_LEAN2RR" "$L2R_REUSSIR/flake.lock"
} > "$out/provenance.txt"
bash "$stack/lean-to-reussir/tests/reussir-benchmark/run.sh" "/tmp/reussir-paper-refresh-20261111/benchmark" "${names[@]}"
python3 "$out/validate-results.py" "$out"
