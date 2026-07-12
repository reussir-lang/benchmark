// Array/vector form of the heap workload. `var` gives the vector unique local
// ownership, so indexed assignment is in-place without exposing mutable state.

import std/num/int64

val heap-size = 65535
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

fun swap( values : vector<int64>, i : int, j : int ) : exn vector<int64>
  val vi = values[i]
  val vj = values[j]
  var result := values
  result[i] := vj
  result[j] := vi
  result

fun sift-up( values : vector<int64>, index : int ) : <exn,div> vector<int64>
  if index == 0 then values else
    val parent = (index - 1) / 2
    if values[index] < values[parent] then
      sift-up(swap(values, index, parent), parent)
    else values

fun sift-down( values : vector<int64>, index : int ) : <exn,div> vector<int64>
  val left = 2 * index + 1
  if left >= heap-size then values else
    val right = left + 1
    val child = if right < heap-size && values[right] < values[left] then right else left
    if values[child] < values[index] then
      sift-down(swap(values, index, child), child)
    else values

fun set-at( values : vector<int64>, index : int, value : int64 ) : exn vector<int64>
  var result := values
  result[index] := value
  result

fun build( index : int, state : int64, values : vector<int64> ) : <exn,div> (vector<int64>, int64)
  if index == heap-size then (values, state) else
    val (value, next) = gauss(state)
    build(index + 1, next, sift-up(set-at(values, index, value), index))

fun maintain( rounds : int, state : int64, values : vector<int64>, checksum : int64 ) : <exn,div> int64
  if rounds == 0 then
    var total := checksum
    values.foreach fn(value) total := (total + value) % modulus
    total
  else
    val (delta, next) = gauss(state)
    val root = values[0]
    val updated = sift-down(set-at(values, 0, root + delta), 0)
    maintain(rounds - 1, next, updated, (checksum + root) % modulus)

pub fun main()
  val (values, state) = build(0, 20260711.int64, vector(heap-size, 0.int64))
  val result = maintain(6500000, state, values, 0.int64)
  if result != 558972311.int64 then
    println("FAIL: expected 558972311, got " ++ result.show)
    throw("wrong result")
