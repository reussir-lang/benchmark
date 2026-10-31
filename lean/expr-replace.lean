/- expr-replace: substitution that keeps every unchanged subterm, the shape of
   Expr.replace. The term is a balanced sum of 256 summands Var(i % 16) * P
   that all share one polynomial P of 4096 literals. Each of 100 rounds
   substitutes one variable of the same retained term. A subterm is rebuilt
   only where the variable occurs, which an occurs check decides first
   (Lean's Expr caches that answer; here it is recomputed). The check reads
   all of P at every summand it reaches, and P is shared. -/
import Init.Data.SInt.Basic

inductive Expr where
  | lit (v : Int64)
  | var (id : Int64)
  | add (l r : Expr)
  | mul (l r : Expr)

def poly : Nat → Int64 → Expr
  | 0, s => .lit (s % 7 + 1)
  | d + 1, s =>
    let l := poly d (2 * s)
    let r := poly d (2 * s + 1)
    if (d + 1) % 2 == 1 then .add l r else .mul l r

-- Summands lo .. hi-1 as a balanced sum.
partial def sum (lo hi : Int64) (p : Expr) : Expr :=
  if hi - lo == 1 then .mul (.var (lo % 16)) p
  else
    let mid := (lo + hi) / 2
    .add (sum lo mid p) (sum mid hi p)

def occurs (v : Int64) : Expr → Bool
  | .lit _ => false
  | .var x => x == v
  | .add a b => occurs v a || occurs v b
  | .mul a b => occurs v a || occurs v b

def replace (v c : Int64) (e : Expr) : Expr :=
  if occurs v e then
    match e with
    | .var _ => .lit c
    | .add a b => .add (replace v c a) (replace v c b)
    | .mul a b => .mul (replace v c a) (replace v c b)
    | .lit _ => e
  else e

def leaf : Expr → Int64
  | .lit c => c
  | .var y => y
  | _ => 0

-- Sum of the summands' factors (never enters the polynomial).
def factors : Expr → Int64
  | .add a b => factors a + factors b
  | .mul x _ => leaf x
  | _ => 0

def rounds : Nat → Int64 → Expr → Int64 → Int64
  | 0, _, _, acc => acc
  | r + 1, k, base, acc => rounds r (k + 1) base (acc + factors (replace (k % 16) k base))

def main : IO UInt32 := do
  let base := sum 0 256 (poly 12 1)
  let result := rounds 100 0 base 0
  if result != 259584 then
    IO.eprintln s!"FAIL: expected 259584, got {result}"
    return 1
  return 0
