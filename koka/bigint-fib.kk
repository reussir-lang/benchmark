// Iterative Fibonacci over int: 600000 steps of (a, b) -> (b, a + b), so both
// operands soon grow far beyond a machine word.

fun fib-loop(n : int, a : int, b : int) : div int
  if n == 0 then a else fib-loop(n - 1, b, a + b)

pub fun main()
  val r = fib-loop(600000, 0, 1) % 1000000007
  if r != 555579099 then
    println("FAIL: expected 555579099, got " ++ r.show)
    throw("wrong result")
