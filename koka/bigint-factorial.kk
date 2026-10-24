// 120000! by sequential multiplication 2 * 3 * ... * n: a growing big integer
// times a word-sized factor.

fun fact-loop(i : int, n : int, acc : int) : div int
  if i > n then acc else fact-loop(i + 1, n, acc * i)

pub fun main()
  val r = fact-loop(2, 120000, 1) % 1000000007
  if r != 118586228 then
    println("FAIL: expected 118586228, got " ++ r.show)
    throw("wrong result")
