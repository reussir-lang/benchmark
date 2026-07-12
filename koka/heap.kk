// Binary heap maintenance under a Gaussian workload — constructor form:
// a Braun min-heap (size-balanced tree; the idiomatic persistent binary
// heap), same Irwin-Hall stream and
// unconditional replace-top maintenance as the array variants. The checksum
// only depends on heap *contents* (evicted minima + final multiset, mod
// 1e9+7), which is arrangement-independent, so it matches the array
// implementations exactly.

import std/num/int64

type heap
  Node( value : int64, lchild : heap, rchild : heap )
  Leaf

val modulus = 1000000007.int64

fun lcg( x : int64 ) : int64
  (x * 48271.int64) % 2147483647.int64

fun gauss( x : int64 ) : (int64, int64)
  val x1 = lcg(x)
  val x2 = lcg(x1)
  val x3 = lcg(x2)
  val x4 = lcg(x3)
  val x5 = lcg(x4)
  val x6 = lcg(x5)
  val x7 = lcg(x6)
  val x8 = lcg(x7)
  val x9 = lcg(x8)
  val x10 = lcg(x9)
  val x11 = lcg(x10)
  val x12 = lcg(x11)
  (x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12, x12)

fun insert( h : heap, v : int64 ) : heap
  match h
    Leaf -> Node(v, Leaf, Leaf)
    Node(w, l, r) ->
      if v <= w then Node(v, insert(r, w), l)
      else Node(w, insert(r, v), l)

fun down( v : int64, l : heap, r : heap ) : div heap
  match l
    Node(lv, ll, lr) -> match r
      Node(rv, rl, rr) ->
        if lv <= rv then
          (if v <= lv then Node(v, l, r) else Node(lv, down(v, ll, lr), r))
        else
          (if v <= rv then Node(v, l, r) else Node(rv, l, down(v, rl, rr)))
      Leaf ->
        if v <= lv then Node(v, l, Leaf) else Node(lv, down(v, ll, lr), Leaf)
    Leaf -> match r
      Node(rv, rl, rr) ->
        if v <= rv then Node(v, Leaf, r) else Node(rv, Leaf, down(v, rl, rr))
      Leaf -> Node(v, Leaf, Leaf)

fun replace-top( h : heap, v : int64 ) : div heap
  match h
    Node(_, l, r) -> down(v, l, r)
    Leaf -> Node(v, Leaf, Leaf)

fun top( h : heap ) : int64
  match h
    Node(w, _, _) -> w
    Leaf -> 0.int64

fun heap-sum( h : heap, acc : int64 ) : int64
  match h
    Leaf -> acc
    Node(w, l, r) -> heap-sum(r, heap-sum(l, (acc + w) % modulus))

fun build( k : int, x : int64, h : heap ) : div (heap, int64)
  if k == 65535 then (h, x) else
    val (g, x1) = gauss(x)
    build(k + 1, x1, insert(h, g))

fun maintain( m : int, x : int64, h : heap, acc : int64 ) : div int64
  if m == 0 then (acc + heap-sum(h, 0.int64)) % modulus else
    val (g, x1) = gauss(x)
    val t = top(h)
    maintain(m - 1, x1, replace-top(h, t + g), (acc + t) % modulus)

pub fun main()
  val (h, x) = build(0, 20260711.int64, Leaf)
  val c = maintain(6500000, x, h, 0.int64)
  if c != 558972311.int64 then
    println("FAIL: expected 558972311, got " ++ c.show)
    throw("wrong result")
