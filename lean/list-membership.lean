/- list-membership: 40000 membership queries against one 10000-element list
   that the caller keeps between queries (reussir-lang/reussir#762). Every
   query only reads the list; half of them miss and walk all of it. -/
import Init.Data.SInt.Basic

def mem (x : Int64) : List Int64 → Bool
  | [] => false
  | y :: ys => if x == y then true else mem x ys

-- [1 .. n]
def build : Nat → List Int64 → List Int64
  | 0, acc => acc
  | n + 1, acc => build n (Int64.ofNat (n + 1) :: acc)

def search : Nat → Int64 → List Int64 → Nat → Nat
  | 0, _, _, hits => hits
  | q + 1, n, xs, hits =>
    let x := (Int64.ofNat (q + 1) * 7919) % (2 * n) + 1
    search q n xs (if mem x xs then hits + 1 else hits)

def main : IO UInt32 := do
  let hits := search 40000 10000 (build 10000 []) 0
  if hits != 20000 then
    IO.eprintln s!"FAIL: expected 20000, got {hits}"
    return 1
  return 0
