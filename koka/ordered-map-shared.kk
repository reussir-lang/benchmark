// Std-collection workload on the ordered map from koka-community/std
// (std/data/rbtree-bu, vendored under koka/community-std — a persistent
// red-black tree with bottom-up insert and remove).
//
// Build 1M MINSTD-keyed inserts over a 524287 keyspace, churn 1M
// insert/remove rounds (remove when draw % 4 == 3), sum 1M lookups
// (-1 for a miss), then fold the final map. During the two mutating
// phases a second draw per round decides retention: when it is
// divisible by 8192 (265 times over the run) the current version is
// parked in slot (draw / 8192) mod 8 of an eight-version ring, where
// it stays shared until that slot is next overwritten. The persistent
// tree pays path copies while a parked version is live. The checksum
// folds the final map and every ring slot, so retained versions stay
// live and verified:
// result = lookup-sum + sum over maps of (sum(key * 1000003 + value) +
// 7 * size). Final size 401,258; each ring slot ends holding a
// ~401k-entry version.
//
// The build and churn rounds share one loop: round i of the combined
// 1M inserts value i in either phase (churn round j writes 1000000+j),
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

// Park version `m` in ring slot `slot`, dropping the version that slot
// held before. The community `unsafe-set` writes through
// `kk_vector_unsafe_assign`, which stores the new element WITHOUT
// dropping the old one, so every superseded version would leak (hundreds
// of MB to tens of GB of peak RSS here) and the drop work every other
// port pays would be skipped. Rebuilding the eight-slot ring lets Perceus
// drop the old ring and, with it, the superseded version. `noinline` is
// required for the same reason as `step` in life.kk: the -O3 specializer
// diverges (>100 GB) on a recursive call whose argument builds a closure.
noinline fun park(ring : vector<rbtree<int,int>>, slot : int, m : rbtree<int,int>) : exn vector<rbtree<int,int>>
  vector-init(8) fn(j) if j == slot then m else ring[j]

fun fold-ring(ring : vector<rbtree<int,int>>, acc : int) : int
  ring.list.foldl(acc) fn(a, m) fold-one(m, a)

fun lookups(i : int, x : int, m : rbtree<int,int>, acc : int) : div int
  if i == 1000000 then acc
  else
    val x1 = lcg(x)
    lookups(i + 1, x1, m, acc + m.lookup(x1 % 524287).default(-1))

fun mutate(i : int, x : int, m : rbtree<int,int>, ring : vector<rbtree<int,int>>) : <div,exn> int
  if i == 2000000 then
    fold-ring(ring, fold-one(m, lookups(0, x, m, 0)))
  else
    val x1 = lcg(x)
    val k = x1 % 524287
    val m1 = if i >= 1000000 && x1 % 4 == 3 then m.bu/remove(k) else m.bu/set(k, i)
    val x2 = lcg(x1)
    if x2 % 8192 == 0 then
      mutate(i + 1, x2, m1, ring.park((x2 / 8192) % 8, m1))
    else
      mutate(i + 1, x2, m1, ring)

pub fun main()
  val c = mutate(0, 1, empty(), vector(8, empty()))
  if c != 948266134564763663 then
    println("FAIL: expected 948266134564763663, got " ++ c.show)
    throw("wrong result")
