(* Total Collatz trajectory length over the starting values 1 .. 999999 in
   Zarith arithmetic. Every intermediate value stays below 2^37, so this
   measures the small-integer path. *)

let two = Z.of_int 2
let three = Z.of_int 3

let rec steps n c =
  if Z.equal n Z.one then c
  else if Z.is_even n then steps (Z.div n two) (c + 1)
  else steps (Z.succ (Z.mul three n)) (c + 1)

let rec total s acc =
  if s >= 1_000_000 then acc else total (s + 1) (acc + steps (Z.of_int s) 0)

let () =
  let r = total 1 0 in
  if r <> 131_434_272 then (
    Printf.eprintf "FAIL: expected 131434272, got %d\n" r;
    exit 1)
