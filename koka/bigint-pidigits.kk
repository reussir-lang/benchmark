// The first 10000 decimal digits of pi with Gibbons' unbounded spigot (the
// Computer Language Benchmarks Game algorithm), folded into a rolling hash.

val modulus = 1000000007

fun spigot(count : int, i : int, k0 : int, k10 : int, n0 : int, a0 : int, d0 : int, h : int) : div int
  val k = k0 + 1
  val k1 = k10 + 2
  val n = n0 * k
  val a = (a0 + n0 * 2) * k1
  val d = d0 * k1
  if a < n then spigot(count, i, k, k1, n, a, d, h) else
    val (q, r) = divmod(n * 3 + a, d)
    val u = r + n
    if d <= u then spigot(count, i, k, k1, n, a, d, h) else
      val h1 = (h * 10 + q) % modulus
      if i + 1 >= count then h1
      else spigot(count, i + 1, k, k1, n * 10, (a - d * q) * 10, d, h1)

pub fun main()
  val r = spigot(10000, 0, 0, 1, 1, 0, 1, 0)
  if r != 334354775 then
    println("FAIL: expected 334354775, got " ++ r.show)
    throw("wrong result")
