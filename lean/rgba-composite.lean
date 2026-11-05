/- Packed RGBA8 source-over compositing onto an opaque canvas. The destination
   is threaded linearly through contiguous pixel updates; the source is read-only. -/

def channel (s d alpha : UInt32) : UInt32 :=
  (s * alpha + d * (255 - alpha) + 127) / 255

def blend (dst src opacity : UInt32) : UInt32 :=
  let alpha := ((src >>> 24) * opacity + 127) / 255
  let r := channel (src &&& 255) (dst &&& 255) alpha
  let g := channel ((src >>> 8) &&& 255) ((dst >>> 8) &&& 255) alpha
  let b := channel ((src >>> 16) &&& 255) ((dst >>> 16) &&& 255) alpha
  r ||| (g <<< 8) ||| (b <<< 16) ||| 4278190080

partial def composite (dst src : Array UInt32) (opacity : UInt32) (i : Nat) : Array UInt32 :=
  if i == 262144 then dst
  else
    let d := dst[i]!
    let s := src[i]!
    composite (dst.set! i (blend d s opacity)) src opacity (i + 1)

partial def layers (dst src : Array UInt32) (n : Nat) : Array UInt32 :=
  if n == 0 then dst
  else layers (composite dst src (96 + n % 160).toUInt32 0) src (n - 1)

def rgbaCompositeTest : UInt64 :=
  let src : Array UInt32 := Array.ofFn (n := 262144) fun k =>
    let i := k.val
    ((i * 17 + 23) % 256).toUInt32 |||
      (((i * 43 + 7) % 256).toUInt32 <<< 8) |||
      (((i * 97 + 61) % 256).toUInt32 <<< 16) |||
      (((i * 31 + 13) % 256).toUInt32 <<< 24)
  let dst : Array UInt32 := Array.ofFn (n := 262144) fun k =>
    let i := k.val
    ((i * 29 + 5) % 256).toUInt32 |||
      (((i * 11 + 101) % 256).toUInt32 <<< 8) |||
      (((i * 67 + 19) % 256).toUInt32 <<< 16) ||| 4278190080
  (layers dst src 4096).foldl (fun acc pixel => acc + pixel.toUInt64) 0

def main : IO UInt32 := do
  let result := rgbaCompositeTest
  if result != 1123699998887936 then
    IO.eprintln s!"FAIL: expected 1123699998887936, got {result}"
    return 1
  return 0
