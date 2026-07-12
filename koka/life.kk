// Game of Life, toroidal 64x64, flat vector<int> of 4096 cells.
// Koka 3.2.2 vectors are immutable with no functional update (std/data/array
// is a stub), so each generation is a vector-init over the previous grid —
// the tabulate-equivalent form. Same seed hash, rule, and wrap as the other
// variants.
//
// `noinline` on step is required: without it the -O3 specializer diverges
// (specInnerCalls endlessly re-specializes the recursive `run` call whose
// argument is the vector-init closure).

fun wrap( x : int ) : int
  (x + 64) % 64

fun cell( g : vector<int>, k : int ) : exn int
  val i = k / 64
  val j = k % 64
  val im = wrap(i - 1)
  val ip = wrap(i + 1)
  val jm = wrap(j - 1)
  val jp = wrap(j + 1)
  val n = g[im*64 + jm] + g[im*64 + j] + g[im*64 + jp]
        + g[i*64 + jm]  + g[i*64 + jp]
        + g[ip*64 + jm] + g[ip*64 + j] + g[ip*64 + jp]
  val alive = g[i*64 + j]
  if alive == 1 then (if n == 2 || n == 3 then 1 else 0)
  else (if n == 3 then 1 else 0)

noinline fun step( g : vector<int> ) : exn vector<int>
  vector-init(4096) fn(k) cell(g, k)

fun run( g : vector<int>, n : int ) : <exn,div> vector<int>
  if n == 0 then g else run(step(g), n - 1)

fun seed() : vector<int>
  vector-init-total(4096) fn(k)
    val i = k / 64
    val j = k % 64
    if (i * 2654435761 + j * 40503 + i * j * 2246822519) % 97 < 33 then 1 else 0

fun population( g : vector<int> ) : int
  var acc := 0
  g.foreach fn(c)
    acc := acc + c
  acc

pub fun main()
  val g = run(seed(), 50000)
  val p = population(g)
  if p != 115 then
    println("FAIL: expected 115, got " ++ p.show)
    throw("wrong result")
