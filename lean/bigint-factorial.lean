-- 120000! by sequential multiplication 2 * 3 * ... * n: a growing big
-- integer times a word-sized factor.

def factLoop : Nat → Nat → Nat → Nat
  | 0,        _, acc => acc
  | fuel + 1, i, acc => factLoop fuel (i + 1) (acc * i)

def main : IO UInt32 := do
  let n := 120000
  let r := factLoop (n - 1) 2 1 % 1000000007
  if r != 118586228 then
    IO.eprintln s!"FAIL: expected 118586228, got {r}"
    return 1
  return 0
