let size = 65_535
let modulus = 1_000_000_007L
let lcg x = Int64.rem (Int64.mul x 48_271L) 2_147_483_647L

let gauss state =
  let rec go count sum state =
    if count = 0 then (sum, state)
    else
      let next = lcg state in
      go (count - 1) (Int64.add sum next) next
  in
  go 12 0L state

let swap values i j =
  let value = values.(i) in
  values.(i) <- values.(j);
  values.(j) <- value

let sift_up values index =
  let index = ref index in
  while !index > 0 do
    let parent = (!index - 1) / 2 in
    if Int64.compare values.(!index) values.(parent) < 0 then (
      swap values !index parent;
      index := parent)
    else index := 0
  done

let sift_down values index =
  let index = ref index and running = ref true in
  while !running do
    let left = (2 * !index) + 1 in
    if left >= size then running := false
    else
      let right = left + 1 in
      let child =
        if right < size && Int64.compare values.(right) values.(left) < 0 then right else left
      in
      if Int64.compare values.(child) values.(!index) < 0 then (
        swap values child !index;
        index := child)
      else running := false
  done

let () =
  let heap = Array.make size 0L and state = ref 20_260_711L in
  for index = 0 to size - 1 do
    let value, next = gauss !state in
    state := next;
    heap.(index) <- value;
    sift_up heap index
  done;
  let checksum = ref 0L in
  for _ = 1 to 6_500_000 do
    let delta, next = gauss !state in
    state := next;
    let root = heap.(0) in
    checksum := Int64.rem (Int64.add !checksum root) modulus;
    heap.(0) <- Int64.add root delta;
    sift_down heap 0
  done;
  let final =
    Array.fold_left
      (fun sum value -> Int64.rem (Int64.add sum value) modulus)
      0L heap
  in
  let result = Int64.rem (Int64.add !checksum final) modulus in
  if result <> 558_972_311L then (
    Printf.eprintf "FAIL: expected 558972311, got %Ld\n" result;
    exit 1)
