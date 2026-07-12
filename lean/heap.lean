/- Binary heap maintenance under a Gaussian workload — Array UInt64 min-heap
   of 65535 values threaded linearly (uniqueness keeps set! in place),
   Irwin-Hall draws (sum of 12 consecutive MINSTD outputs), 26M rounds of
   unconditional replace-top. Checksum = (evicted minima + final contents)
   mod 1e9+7. All values are nonnegative and < 2^35, so unsigned arithmetic
   matches the i64 variants exactly. -/

def P : UInt64 := 1000000007

def lcg (x : UInt64) : UInt64 :=
  (x * 48271) % 2147483647

def gauss (x : UInt64) : UInt64 × UInt64 :=
  let x1 := lcg x
  let x2 := lcg x1
  let x3 := lcg x2
  let x4 := lcg x3
  let x5 := lcg x4
  let x6 := lcg x5
  let x7 := lcg x6
  let x8 := lcg x7
  let x9 := lcg x8
  let x10 := lcg x9
  let x11 := lcg x10
  let x12 := lcg x11
  (x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12, x12)

partial def siftUp (a : Array UInt64) (i : Nat) : Array UInt64 :=
  if i == 0 then a
  else
    let p := (i - 1) / 2
    let vi := a[i]!
    let vp := a[p]!
    if vi < vp then siftUp ((a.set! i vp).set! p vi) p else a

partial def siftDown (a : Array UInt64) (i : Nat) : Array UInt64 :=
  let l := 2 * i + 1
  if l >= 65535 then a
  else
    let r := l + 1
    let vl := a[l]!
    let c := if r < 65535 && a[r]! < vl then r else l
    let vc := a[c]!
    let vi := a[i]!
    if vc < vi then siftDown ((a.set! i vc).set! c vi) c else a

partial def build (a : Array UInt64) (k : Nat) (x : UInt64) : Array UInt64 × UInt64 :=
  if k == 65535 then (a, x)
  else
    let (g, x') := gauss x
    build (siftUp (a.set! k g) k) (k + 1) x'

partial def maintain (a : Array UInt64) (x : UInt64) (m : Nat) (acc : UInt64) : UInt64 :=
  match m with
  | 0 => (acc + a.foldl (fun s v => (s + v) % P) 0) % P
  | m'+1 =>
    let (g, x') := gauss x
    let top := a[0]!
    maintain (siftDown (a.set! 0 (top + g)) 0) x' m' ((acc + top) % P)

def heapTest (m : Nat) : UInt64 :=
  let (a, x) := build (Array.replicate 65535 0) 0 20260711
  maintain a x m 0

def main : IO UInt32 := do
  let c := heapTest 26000000
  if c != 715063753 then
    IO.eprintln s!"FAIL: expected 715063753, got {c}"
    return 1
  return 0
