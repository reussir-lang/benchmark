-- Iterative Fibonacci over Nat: 600000 steps of (a, b) -> (b, a + b), so
-- both operands soon grow far beyond a machine word.

def fibLoop : Nat → Nat → Nat → Nat
  | 0,     a, _ => a
  | n + 1, a, b => fibLoop n b (a + b)

def main : IO UInt32 := do
  let r := fibLoop 600000 0 1 % 1000000007
  if r != 555579099 then
    IO.eprintln s!"FAIL: expected 555579099, got {r}"
    return 1
  return 0
