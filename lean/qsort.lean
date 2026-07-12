/- Quicksort workload — Array UInt64 threaded linearly through the
   recursion, so Lean's uniqueness makes every set! an in-place store; the
   same Lomuto partition as the other variants. Same MINSTD fill and
   checksum. -/

def lcg (x : UInt64) : UInt64 :=
  (x * 48271) % 2147483647

partial def fill (a : Array UInt64) (i : Nat) (x : UInt64) : Array UInt64 :=
  if i == 65536 then a
  else
    let x1 := lcg x
    fill (a.set! i x1) (i + 1) x1

def swapA (a : Array UInt64) (i j : Nat) : Array UInt64 :=
  let x := a[i]!
  let y := a[j]!
  (a.set! i y).set! j x

mutual
  partial def qsortGo (a : Array UInt64) (lo hi : Int) : Array UInt64 :=
    if lo >= hi then a
    else
      let p := a[hi.toNat]!
      partitionGo a lo hi p lo lo

  partial def partitionGo (a : Array UInt64) (lo hi : Int) (p : UInt64) (i j : Int) : Array UInt64 :=
    if j == hi then
      let a1 := swapA a i.toNat hi.toNat
      qsortGo (qsortGo a1 lo (i - 1)) (i + 1) hi
    else if a[j.toNat]! < p then
      partitionGo (swapA a i.toNat j.toNat) lo hi p (i + 1) (j + 1)
    else
      partitionGo a lo hi p i (j + 1)
end

partial def check (a : Array UInt64) (i : Nat) (prev : UInt64) (acc : UInt64) : Int :=
  if i == 65536 then Int.ofNat acc.toNat
  else
    let v := a[i]!
    if prev > v then -1
    else check a (i + 1) v ((acc + v) % 1000000007)

def round (seed : UInt64) : Int :=
  let a := fill (Array.replicate 65536 0) 0 seed
  let s := qsortGo a 0 65535
  check s 0 0 0

partial def rounds : Nat → Int → Int
  | 0, acc => acc
  | r+1, acc => rounds r ((acc + round (UInt64.ofNat (42 + r + 1))) % 1000000007)

def main : IO UInt32 := do
  let acc := rounds 100 0
  if acc != 276066679 then
    IO.eprintln s!"FAIL: expected 276066679, got {acc}"
    return 1
  return 0
