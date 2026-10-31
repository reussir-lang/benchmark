// expr-replace: substitution that keeps every unchanged subterm, the shape of
// Lean's Expr.replace. The term is a balanced sum of 256 summands
// Var(i % 16) * P that all share one polynomial P of 4096 literals. Each of
// 100 rounds substitutes one variable of the same retained term. A subterm
// is rebuilt only where the variable occurs, which an occurs check decides
// first (Lean caches that answer in each Expr; here it is recomputed). The
// check reads all of P at every summand it reaches, and P is shared.
import std/num/int64

type expr
  Lit(v : int64)
  Var(id : int64)
  Add(l : expr, r : expr)
  Mul(l : expr, r : expr)

fun poly(d : int64, s : int64) : div expr
  if d == zero then Lit(s % 7.int64 + 1.int64)
  else
    val l = poly(d.dec, 2.int64 * s)
    val r = poly(d.dec, 2.int64 * s + 1.int64)
    if d % 2.int64 == 1.int64 then Add(l, r) else Mul(l, r)

// Summands lo .. hi-1 as a balanced sum.
fun sum(lo : int64, hi : int64, p : expr) : div expr
  if hi - lo == 1.int64 then Mul(Var(lo % 16.int64), p)
  else
    val mid = (lo + hi) / 2.int64
    Add(sum(lo, mid, p), sum(mid, hi, p))

fun occurs(v : int64, e : expr) : bool
  match e
    Lit(_) -> False
    Var(x) -> x == v
    Add(a, b) -> occurs(v, a) || occurs(v, b)
    Mul(a, b) -> occurs(v, a) || occurs(v, b)

fun replace(v : int64, c : int64, e : expr) : expr
  if occurs(v, e) then
    match e
      Var(_) -> Lit(c)
      Add(a, b) -> Add(replace(v, c, a), replace(v, c, b))
      Mul(a, b) -> Mul(replace(v, c, a), replace(v, c, b))
      Lit(_) -> e
  else e

fun leaf(x : expr) : int64
  match x
    Lit(c) -> c
    Var(y) -> y
    _ -> zero

// Sum of the summands' factors (never enters the polynomial).
fun factors(e : expr) : int64
  match e
    Add(a, b) -> factors(a) + factors(b)
    Mul(x, _) -> leaf(x)
    _ -> zero

fun rounds(k : int64, n : int64, base : expr, acc : int64) : div int64
  if k == n then acc
  else rounds(k.inc, n, base, acc + factors(replace(k % 16.int64, k, base)))

pub fun main()
  val base = sum(zero, 256.int64, poly(12.int64, 1.int64))
  val r = rounds(zero, 100.int64, base, zero)
  if r != 259584.int64 then
    println("FAIL: expected 259584, got " ++ r.show)
    throw("wrong result")
