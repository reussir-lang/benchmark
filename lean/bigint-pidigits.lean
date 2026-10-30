-- The first 10000 decimal digits of pi with Gibbons' unbounded spigot (the
-- Computer Language Benchmarks Game algorithm), folded into a rolling hash.
-- The accumulator goes negative between digits, so the state is Int.

def modulus : Int := 1000000007

partial def spigot (count i : Nat) (k k1 n a d h : Int) : Int :=
  let k := k + 1
  let t := n * 2
  let n := n * k
  let a := (a + t) * (k1 + 2)
  let k1 := k1 + 2
  let d := d * k1
  if a >= n then
    let x := n * 3 + a
    let q := x / d
    let u := x % d + n
    if d > u then
      let h := (h * 10 + q) % modulus
      let i := i + 1
      if i >= count then h
      else spigot count i k k1 (n * 10) ((a - d * q) * 10) d h
    else spigot count i k k1 n a d h
  else spigot count i k k1 n a d h

def main : IO UInt32 := do
  let r := spigot 10000 0 0 1 1 0 1 0
  if r != 334354775 then
    IO.eprintln s!"FAIL: expected 334354775, got {r}"
    return 1
  return 0
