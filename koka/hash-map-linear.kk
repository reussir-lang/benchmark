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
// Linear variant: exactly one live version — the map handle is
// threaded linearly through every round and nothing is retained, so
// the backing vector stays unique and updates mutate it in place. The
// checksum folds the final map:
// result = lookup-sum + sum(key * 31 + value) + 7 * size.
// Final size 1,120,773.

import std/num/int64
import std/data/hashmap

fun lcg(x : int) : int
  (x * 48271) % 2147483647

fun fold-one(m : hash-map<int,int>, acc : int) : int
  var s := acc
  m.foreach fn(k, v)
    s := s + k * 31 + v
  s + 7 * m.length

fun ops(i : int, x : int, m : hash-map<int,int>, acc : int) : <div,exn> int
  if i == 8000000 then fold-one(m, acc)
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
    ops(i + 1, x3, m2, acc2)

pub fun main()
  val c = ops(0, 1, hash-map-seeded(zero), 0)
  if c != 144585704074329 then
    println("FAIL: expected 144585704074329, got " ++ c.show)
    throw("wrong result")
