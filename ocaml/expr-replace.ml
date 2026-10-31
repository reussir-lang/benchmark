(* expr-replace: substitution that keeps every unchanged subterm, the shape of
   Lean's Expr.replace. The term is a balanced sum of 256 summands
   Var(i mod 16) * P that all share one polynomial P of 4096 literals. Each
   of 100 rounds substitutes one variable of the same retained term. A
   subterm is rebuilt only where the variable occurs, which an occurs check
   decides first (Lean caches that answer in each Expr; here it is
   recomputed). The check reads all of P at every summand it reaches, and P
   is shared. *)

type expr = Lit of int64 | Var of int64 | Add of expr * expr | Mul of expr * expr

let rec poly d s =
  if d = 0 then Lit (Int64.of_int ((s mod 7) + 1))
  else
    let l = poly (d - 1) (2 * s) in
    let r = poly (d - 1) ((2 * s) + 1) in
    if d mod 2 = 1 then Add (l, r) else Mul (l, r)

(* Summands lo .. hi-1 as a balanced sum. *)
let rec sum lo hi p =
  if hi - lo = 1 then Mul (Var (Int64.of_int (lo mod 16)), p)
  else
    let mid = (lo + hi) / 2 in
    Add (sum lo mid p, sum mid hi p)

let rec occurs v = function
  | Lit _ -> false
  | Var x -> Int64.equal x v
  | Add (a, b) | Mul (a, b) -> occurs v a || occurs v b

let rec replace v c e =
  if occurs v e then
    match e with
    | Var _ -> Lit c
    | Add (a, b) -> Add (replace v c a, replace v c b)
    | Mul (a, b) -> Mul (replace v c a, replace v c b)
    | Lit _ -> e
  else e

let leaf = function Lit c -> c | Var y -> y | _ -> 0L

(* Sum of the summands' factors (never enters the polynomial). *)
let rec factors = function
  | Add (a, b) -> Int64.add (factors a) (factors b)
  | Mul (x, _) -> leaf x
  | _ -> 0L

let rec rounds k n base acc =
  if k = n then acc
  else
    let r = replace (Int64.of_int (k mod 16)) (Int64.of_int k) base in
    rounds (k + 1) n base (Int64.add acc (factors r))

let () =
  let base = sum 0 256 (poly 12 1) in
  let r = rounds 0 100 base 0L in
  if not (Int64.equal r 259584L) then (
    Printf.eprintf "FAIL: expected 259584, got %Ld\n" r;
    exit 1)
