-- Total Collatz trajectory length over the starting values 1 .. 999999 in
-- Nat arithmetic. Every intermediate value stays below 2^37, so this
-- measures the small-integer path.

partial def steps (n c : Nat) : Nat :=
  match n with
  | 1 => c
  | _ => if n % 2 == 0 then steps (n / 2) (c + 1) else steps (3 * n + 1) (c + 1)

def total : Nat → Nat → Nat → Nat
  | 0,        _, acc => acc
  | fuel + 1, s, acc => total fuel (s + 1) (acc + steps s 0)

def main : IO UInt32 := do
  let r := total 999999 1 0
  if r != 131434272 then
    IO.eprintln s!"FAIL: expected 131434272, got {r}"
    return 1
  return 0
