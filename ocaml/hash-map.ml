(* Std-collection workload on OCaml's standard hash map
   (Stdlib.Hashtbl, mutable in place, seeded polynomial hash). Large
   and broad: keys are raw MINSTD draws, uniform over [1, 2^31-2];
   MINSTD is a full-period permutation, so fresh draws never repeat,
   and removals plus the hit half of the lookups replay the build key
   stream through a second MINSTD state. Build 4M inserts, churn 2M
   rounds, 2M lookups alternating replayed hits and fresh misses.
   Final size 4,999,834; the checksum is iteration-order independent so
   all representations agree. Replace semantics keep at most one
   binding per key. *)

let build_n = 4_000_000
let churn_n = 2_000_000
let lookup_n = 2_000_000
let expected = 166_401_892_080_070_584L
let lcg x = Int64.rem (Int64.mul x 48_271L) 2_147_483_647L

let () =
  let m : (int64, int64) Hashtbl.t = Hashtbl.create 1024 in
  let x = ref 1L in
  for i = 0 to build_n - 1 do
    x := lcg !x;
    Hashtbl.replace m !x (Int64.of_int i)
  done;
  let r = ref 1L in
  for i = 0 to churn_n - 1 do
    x := lcg !x;
    if Int64.rem !x 4L = 3L then (
      r := lcg !r;
      Hashtbl.remove m !r)
    else Hashtbl.replace m !x (Int64.of_int (build_n + i))
  done;
  let acc = ref 0L in
  for _ = 0 to lookup_n - 1 do
    x := lcg !x;
    let k =
      if Int64.rem !x 2L = 0L then (
        r := lcg !r;
        !r)
      else !x
    in
    let v = match Hashtbl.find_opt m k with Some v -> v | None -> -1L in
    acc := Int64.add !acc v
  done;
  let folded =
    Hashtbl.fold
      (fun k v a -> Int64.add a (Int64.add (Int64.mul k 31L) v))
      m 0L
  in
  let result =
    Int64.add
      (Int64.add !acc folded)
      (Int64.mul 7L (Int64.of_int (Hashtbl.length m)))
  in
  if result <> expected then (
    Printf.eprintf "FAIL: expected %Ld, got %Ld\n" expected result;
    exit 1)
