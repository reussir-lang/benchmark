// list-membership: 40000 membership queries against one 10000-element list
// that the caller keeps between queries (reussir-lang/reussir#762). Every
// query only reads the list; half of them miss and walk all of it.
import std/num/int64

fun mem(x : int64, xs : list<int64>) : bool
  match xs
    Cons(y, ys) -> if x == y then True else mem(x, ys)
    Nil -> False

// [1 .. n]
fun build(n : int64, acc : list<int64>) : div list<int64>
  if n == zero then acc else build(n.dec, Cons(n, acc))

fun search(q : int64, n : int64, xs : list<int64>, hits : int64) : div int64
  if q == zero then hits
  else
    val x = (q * 7919.int64) % (2.int64 * n) + 1.int64
    search(q.dec, n, xs, if mem(x, xs) then hits.inc else hits)

pub fun main()
  val hits = search(40000.int64, 10000.int64, build(10000.int64, Nil), zero)
  if hits != 20000.int64 then
    println("FAIL: expected 20000, got " ++ hits.show)
    throw("wrong result")
