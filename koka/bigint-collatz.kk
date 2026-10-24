// Total Collatz trajectory length over the starting values 1 .. 999999 in int
// arithmetic. Every intermediate value stays below 2^37, so this measures the
// small-integer path.

fun steps(n : int, c : int) : div int
  if n == 1 then c
  elif n.is-even then steps(n / 2, c + 1)
  else steps(3 * n + 1, c + 1)

fun total(s : int, acc : int) : div int
  if s >= 1000000 then acc else total(s + 1, acc + steps(s, 0))

pub fun main()
  val r = total(1, 0)
  if r != 131434272 then
    println("FAIL: expected 131434272, got " ++ r.show)
    throw("wrong result")
