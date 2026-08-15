// Std-collection workload on the ordered map from koka-community/std
// (std/data/rbtree-bu, vendored under koka/community-std — a persistent
// red-black tree with bottom-up insert and remove).
//
// Build 500k MINSTD-keyed inserts over a 524287 keyspace, churn 500k
// insert/remove rounds (remove when draw % 4 == 3), sum 500k lookups
// (-1 for a miss), then fold the final map. During the two mutating
// phases a second draw per round decides retention: when it is
// divisible by 512 (1,951 times over the run) the current version is
// parked in slot (draw / 512) mod 8 of an eight-version ring, where
// it stays shared until that slot is next overwritten. The persistent
// tree pays path copies while a parked version is live. The checksum
// folds the final map and every ring slot, so retained versions stay
// live and verified:
// result = lookup-sum + sum over maps of (sum(key * 1000003 + value) +
// 7 * size). Final size 365,836; each ring slot ends holding a
// ~366k-entry version. Heavily shared tier: retention fires ~15x
// more often than ordered-map-shared.
//
// The build and churn rounds share one loop: round i of the combined
// 1M inserts value i in either phase (churn round j writes 500000+j),
// and only the remove arm is churn-gated. The lookup phase draws once
// per round and retains nothing.

import std/core-extras
import std/data/rbtree
import std/data/rbtree-bu

fun lcg(x : int) : int
  (x * 48271) % 2147483647

fun fold-one(m : rbtree<int,int>, acc : int) : int
  val sum = m.td/fold(acc) fn(a, k, v) a + k * 1000003 + v
  sum + 7 * m.td/fold(0) fn(n, _, _) n + 1

fun fold-ring(ring : vector<rbtree<int,int>>, acc : int) : int
  ring.list.foldl(acc) fn(a, m) fold-one(m, a)

fun lookups(i : int, x : int, m : rbtree<int,int>, acc : int) : div int
  if i == 500000 then acc
  else
    val x1 = lcg(x)
    lookups(i + 1, x1, m, acc + m.lookup(x1 % 524287).default(-1))

fun mutate(i : int, x : int, m : rbtree<int,int>, ring : vector<rbtree<int,int>>) : <div,exn> int
  if i == 1000000 then
    fold-ring(ring, fold-one(m, lookups(0, x, m, 0)))
  else
    val x1 = lcg(x)
    val k = x1 % 524287
    val m1 = if i >= 500000 && x1 % 4 == 3 then m.bu/remove(k) else m.bu/set(k, i)
    val x2 = lcg(x1)
    if x2 % 512 == 0 then
      mutate(i + 1, x2, m1, ring.unsafe-set((x2 / 512) % 8, m1))
    else
      mutate(i + 1, x2, m1, ring)

pub fun main()
  val c = mutate(0, 1, empty(), vector(8, empty()))
  if c != 861736461765462691 then
    println("FAIL: expected 861736461765462691, got " ++ c.show)
    throw("wrong result")
