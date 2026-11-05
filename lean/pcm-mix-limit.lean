import Init.Data.SInt.Basic

/- Mix signed PCM with a Q15 gain and linear fade, then apply a soft knee and
   hard saturation. Int32 division truncates toward zero. -/

def limit (sample : Int32) : Int32 :=
  let knee := if sample > 16384 then 16384 + (sample - 16384) / 2
    else if sample < -16384 then -16384 + (sample + 16384) / 2 else sample
  if knee > 32767 then 32767 else if knee < -32768 then -32768 else knee

partial def mix (dst src : Array Int32) (gain : Int32) (i : Nat) : Array Int32 :=
  if i == 262144 then dst
  else
    let source := src[i]!
    let previous := dst[i]!
    let envelope := (i / 8).toUInt32.toInt32
    let scaled := (source * gain) / 32768
    let faded := (scaled * envelope) / 32768
    mix (dst.set! i (limit (previous + faded))) src gain (i + 1)

partial def tracks (dst src : Array Int32) (n : Nat) : Array Int32 :=
  if n == 0 then dst
  else
    let gain := ((n * 1103) % 98304).toUInt32.toInt32 - 49152
    tracks (mix dst src gain 0) src (n - 1)

def pcmMixLimitTest : Int64 :=
  let src : Array Int32 := Array.ofFn (n := 262144) fun k =>
    let i := k.val
    let fundamental := ((i * 97) % 65536).toUInt32.toInt32 - 32768
    let harmonic := ((i * 271) % 65536).toUInt32.toInt32 - 32768
    let noise := ((i * 8191 + 37) % 1024).toUInt32.toInt32 - 512
    fundamental / 2 + harmonic / 4 + noise
  let dst : Array Int32 := Array.replicate 262144 0
  (tracks dst src 8192).foldl (fun energy sample =>
    let value := sample.toInt64
    energy + value * value) 0

def main : IO UInt32 := do
  let result := pcmMixLimitTest
  if result != 124776496343097 then
    IO.eprintln s!"FAIL: expected 124776496343097, got {result}"
    return 1
  return 0
