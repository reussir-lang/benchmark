// Quicksort workload — list-based functional quicksort: Koka 3.2.2 has no
// array with update (std/data/array is a stub, vectors are immutable), so
// the idiomatic pure structure is a list. Same MINSTD fill and checksum as
// the other variants; element order before sorting does not affect the
// result.

fun lcg( x : int ) : int
  (x * 48271) % 2147483647

fun fill( k : int, x : int, acc : list<int> ) : div list<int>
  if k == 0 then acc else
    val x1 = lcg(x)
    fill(k - 1, x1, Cons(x1, acc))

fun qsort( xs : list<int> ) : div list<int>
  match xs
    Nil -> Nil
    Cons(p, rest) ->
      qsort(rest.filter(fn(x) x < p)) ++ Cons(p, qsort(rest.filter(fn(x) x >= p)))

fun checksum( xs : list<int>, prev : int, acc : int ) : div int
  match xs
    Nil -> acc
    Cons(v, vs) ->
      if prev > v then 0 - 1
      else checksum(vs, v, (acc + v) % 1000000007)

fun rounds( r : int, acc : int ) : div int
  if r == 0 then acc else
    val sorted = qsort(fill(65536, 42 + r, Nil))
    val c = checksum(sorted, 0 - 1, 0)
    rounds(r - 1, (acc + c) % 1000000007)

pub fun main()
  val acc = rounds(400, 0)
  if acc != 853505117 then
    println("FAIL: expected 853505117, got " ++ acc.show)
    throw("wrong result")
