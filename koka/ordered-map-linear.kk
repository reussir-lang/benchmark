// Std-collection workload on the ordered map from koka-community/std
// (std/data/rbtree-bu, vendored under koka/community-std — a persistent
// red-black tree with bottom-up insert and remove).
//
// Build 1M MINSTD-keyed inserts over a 524287 keyspace, churn 1M
// insert/remove rounds (remove when draw % 4 == 3), sum 1M lookups
// (-1 for a miss), then fold the final map:
// result = lookup-sum + sum(key * 1000003 + value) + 7 * size.
// Final size 400,944.
//
// Linear variant: exactly one live version — the map handle is
// threaded linearly through every round and nothing is retained, so
// Perceus uniqueness-driven reuse updates nodes in place throughout.
//
// The build and churn rounds share one loop: round i of the combined
// 2M inserts value i in either phase (churn round j writes 1000000+j),
// and only the remove arm is churn-gated. The lookup phase draws once
// per round.

import std/data/rbtree
import std/data/rbtree-bu

fun lcg(x : int) : int
  (x * 48271) % 2147483647

fun fold-one(m : rbtree<int,int>, acc : int) : int
  val sum = m.td/fold(acc) fn(a, k, v) a + k * 1000003 + v
  sum + 7 * m.td/fold(0) fn(n, _, _) n + 1

fun lookups(i : int, x : int, m : rbtree<int,int>, acc : int) : div int
  if i == 1000000 then acc
  else
    val x1 = lcg(x)
    lookups(i + 1, x1, m, acc + m.lookup(x1 % 524287).default(-1))

fun mutate(i : int, x : int, m : rbtree<int,int>) : <div,exn> int
  if i == 2000000 then
    fold-one(m, lookups(0, x, m, 0))
  else
    val x1 = lcg(x)
    val k = x1 % 524287
    val m1 = if i >= 1000000 && x1 % 4 == 3 then m.bu/remove(k) else m.bu/set(k, i)
    mutate(i + 1, x1, m1)

pub fun main()
  val c = mutate(0, 1, empty())
  if c != 105140861851414131 then
    println("FAIL: expected 105140861851414131, got " ++ c.show)
    throw("wrong result")
