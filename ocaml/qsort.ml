let modulus = 1_000_000_007
let lcg x = x * 48_271 mod 2_147_483_647

let fill seed =
  let values = Array.make 65_536 0 in
  let state = ref seed in
  for i = 0 to 65_535 do
    state := lcg !state;
    values.(i) <- !state
  done;
  values

let swap values i j =
  let value = values.(i) in
  values.(i) <- values.(j);
  values.(j) <- value

let rec qsort values lo hi =
  if lo < hi then (
    let pivot = values.(hi) in
    let target = ref lo in
    for j = lo to hi - 1 do
      if values.(j) < pivot then (
        swap values !target j;
        incr target)
    done;
    swap values !target hi;
    qsort values lo (!target - 1);
    qsort values (!target + 1) hi)

let checksum values =
  let previous = ref (-1) and result = ref 0 and valid = ref true in
  Array.iter
    (fun value ->
      if !previous > value then valid := false;
      previous := value;
      result := (!result + value) mod modulus)
    values;
  if !valid then !result else -1

let () =
  let result = ref 0 in
  for round = 100 downto 1 do
    let values = fill (42 + round) in
    qsort values 0 65_535;
    result := (!result + checksum values) mod modulus
  done;
  if !result <> 276_066_679 then (
    Printf.eprintf "FAIL: expected 276066679, got %d\n" !result;
    exit 1)
