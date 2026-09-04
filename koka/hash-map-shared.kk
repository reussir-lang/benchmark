// Std-collection workload on the hash map from koka-community/std
// (std/data/hashmap, vendored under koka/community-std — a bucket hash
// map over a uniqueness-adaptive vector, keyed by the kklib integer
// hash with a zero seed).
//
// Zipfian mixed-op workload: keys follow an integer-only octave Zipf
// (theta ~ 1) — a stratum s drawn uniform in [0, 24), then a key
// uniform in [2^s, 2^(s+1)), so every octave carries equal mass and
// per-key probability decays as 1/key. No floating point, so the
// distribution is bit-identical in every language. 8M rounds, each
// drawing op, stratum, key from one MINSTD stream: 9/16 insert,
// 5/16 delete, 2/16 lookup (sum, -1 on miss).
//
// After each round one more draw decides retention: when it is
// divisible by 8192 (977 times over the run) the current version is
// parked in slot (draw / 8192) mod 8 of an eight-version ring, where
// it stays shared until that slot is next overwritten. Parking shares
// the backing vector, so the next update on the working map pays one
// full table copy before mutating in place again. The checksum folds
// the working map and every ring slot, so retained versions stay live
// and verified:
// result = lookup-sum + sum over maps of (sum(key * 31 + value) +
// 7 * size). Final size 1,120,619; each ring slot ends holding a
// ~1.1M-entry version from late in the run.

import std/num/int64
import std/core-extras
import std/data/hashmap

fun lcg(x : int) : int
  (x * 48271) % 2147483647

fun fold-one(m : hash-map<int,int>, acc : int) : int
  var s := acc
  m.foreach fn(k, v)
    s := s + k * 31 + v
  s + 7 * m.length

// Park version `m` in ring slot `slot`, dropping the version that slot
// held before. The community `unsafe-set` writes through
// `kk_vector_unsafe_assign`, which stores the new element WITHOUT
// dropping the old one, so every superseded version would leak (hundreds
// of MB to tens of GB of peak RSS here) and the drop work every other
// port pays would be skipped. Rebuilding the eight-slot ring lets Perceus
// drop the old ring and, with it, the superseded version. `noinline` is
// required for the same reason as `step` in life.kk: the -O3 specializer
// diverges (>100 GB) on a recursive call whose argument builds a closure.
noinline fun park(ring : vector<hash-map<int,int>>, slot : int, m : hash-map<int,int>) : exn vector<hash-map<int,int>>
  vector-init(8) fn(j) if j == slot then m else ring[j]

fun fold-ring(ring : vector<hash-map<int,int>>, acc : int) : int
  ring.list.foldl(acc) fn(a, m) fold-one(m, a)

fun ops(i : int, x : int, m : hash-map<int,int>, ring : vector<hash-map<int,int>>, acc : int) : <div,exn> int
  if i == 8000000 then fold-ring(ring, fold-one(m, acc))
  else
    val x1 = lcg(x)
    val op = x1 % 16
    val x2 = lcg(x1)
    val s = x2 % 24
    val x3 = lcg(x2)
    val p = 1.int64.shl(s).int
    val k = p + x3 % p
    val m2 = if op < 9 then m.insert(k, i)
             elif op < 14 then m.remove(k)
             else m
    val acc2 = if op < 14 then acc else acc + m2.get(k).default(-1)
    val x4 = lcg(x3)
    if x4 % 8192 == 0 then
      ops(i + 1, x4, m2, ring.park((x4 / 8192) % 8, m2), acc2)
    else
      ops(i + 1, x4, m2, ring, acc2)

pub fun main()
  val c = ops(0, 1, hash-map-seeded(zero), vector(8, hash-map-seeded(zero)), 0)
  if c != 1271164153412359 then
    println("FAIL: expected 1271164153412359, got " ++ c.show)
    throw("wrong result")
