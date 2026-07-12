/- Game of Life, toroidal 64x64 — Array UInt32 of 4096 cells; each
   generation is an Array.ofFn over the previous grid (the tabulate
   form). Same seed hash, rule, and wrap as the other variants
   (indices stay in Nat: wrap(i-1) is written (i+63)%64). -/

def step (g : Array UInt32) : Array UInt32 :=
  Array.ofFn (n := 4096) fun k =>
    let i := k.val / 64
    let j := k.val % 64
    let im := (i + 63) % 64
    let ip := (i + 1) % 64
    let jm := (j + 63) % 64
    let jp := (j + 1) % 64
    let nb := g[im*64 + jm]! + g[im*64 + j]! + g[im*64 + jp]!
            + g[i*64 + jm]!  + g[i*64 + jp]!
            + g[ip*64 + jm]! + g[ip*64 + j]! + g[ip*64 + jp]!
    let alive := g[i*64 + j]!
    if alive == 1 then (if nb == 2 || nb == 3 then 1 else 0)
    else (if nb == 3 then 1 else 0)

def run : Nat → Array UInt32 → Array UInt32
  | 0, g => g
  | n+1, g => run n (step g)

def seedGrid : Array UInt32 :=
  Array.ofFn (n := 4096) fun k =>
    let i := k.val / 64
    let j := k.val % 64
    if (i * 2654435761 + j * 40503 + i * j * 2246822519) % 97 < 33 then 1 else 0

def population (g : Array UInt32) : Nat :=
  g.foldl (fun a c => a + c.toNat) 0

def main : IO UInt32 := do
  let p := population (run 200000 seedGrid)
  if p != 115 then
    IO.eprintln s!"FAIL: expected 115, got {p}"
    return 1
  return 0
