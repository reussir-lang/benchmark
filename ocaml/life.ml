let side = 64
let cells = side * side
let wrap x = (x + side) mod side

let step grid =
  Array.init cells (fun k ->
      let i = k / side and j = k mod side in
      let im = wrap (i - 1) and ip = wrap (i + 1) in
      let jm = wrap (j - 1) and jp = wrap (j + 1) in
      let neighbours =
        grid.((im * side) + jm) + grid.((im * side) + j)
        + grid.((im * side) + jp) + grid.((i * side) + jm)
        + grid.((i * side) + jp) + grid.((ip * side) + jm)
        + grid.((ip * side) + j) + grid.((ip * side) + jp)
      in
      let alive = grid.((i * side) + j) in
      if alive = 1 then if neighbours = 2 || neighbours = 3 then 1 else 0
      else if neighbours = 3 then 1
      else 0)

let rec run grid generations =
  if generations = 0 then grid else run (step grid) (generations - 1)

let seed =
  Array.init cells (fun k ->
      let i = k / side and j = k mod side in
      if ((i * 2_654_435_761) + (j * 40_503) + (i * j * 2_246_822_519)) mod 97 < 33
      then 1
      else 0)

let () =
  let population = Array.fold_left ( + ) 0 (run seed 50_000) in
  if population <> 115 then (
    Printf.eprintf "FAIL: expected 115, got %d\n" population;
    exit 1)
