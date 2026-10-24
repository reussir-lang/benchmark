-- The binomial row C(200000, i) by the multiplicative recurrence
-- C(n, i + 1) = C(n, i) * (n - i) / (i + 1): every division is exact, by a
-- word-sized divisor. The row must sum to 2^n and end at 1.

def row (n : Nat) : Nat → Nat → Nat → Nat → Nat × Nat
  | 0,        _, c, s => (c, s)
  | fuel + 1, i, c, s =>
    let c := c * (n - i) / (i + 1)
    row n fuel (i + 1) c (s + c)

def main : IO UInt32 := do
  let n := 200000
  let (last, sum) := row n n 0 1 1
  let r := sum % 1000000007
  if last != 1 || r != 175895282 then
    IO.eprintln s!"FAIL: expected last 1 and 175895282, got {last} and {r}"
    return 1
  return 0
