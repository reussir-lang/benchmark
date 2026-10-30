// The binomial row C(200000, i) by the multiplicative recurrence
// C(n, i + 1) = C(n, i) * (n - i) / (i + 1): every division is exact, by a
// word-sized divisor. The row must sum to 2^n and end at 1.

fun row(n : int, i : int, c : int, s : int) : div (int, int)
  if i >= n then (c, s) else
    val c1 = c * (n - i) / (i + 1)
    row(n, i + 1, c1, s + c1)

pub fun main()
  val (last, sum) = row(200000, 0, 1, 1)
  val r = sum % 1000000007
  if last != 1 || r != 175895282 then
    println("FAIL: expected last 1 and 175895282, got " ++ last.show ++ " and " ++ r.show)
    throw("wrong result")
