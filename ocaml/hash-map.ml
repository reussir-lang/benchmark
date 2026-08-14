(* Std-collection workload on OCaml's standard hash map
   (Stdlib.Hashtbl, mutable in place, seeded polynomial hash). Same
   workload and checksum as ordered-map.ml; the checksum is
   iteration-order independent so the representations agree. Replace
   semantics keep at most one binding per key. *)

let keyspace = 524_287L
let build_n = 1_000_000
let churn_n = 1_000_000
let lookup_n = 1_000_000
let expected = 105_140_861_851_414_131L
let lcg x = Int64.rem (Int64.mul x 48_271L) 2_147_483_647L

let () =
  let m : (int64, int64) Hashtbl.t = Hashtbl.create 1024 in
  let x = ref 1L in
  for i = 0 to build_n - 1 do
    x := lcg !x;
    Hashtbl.replace m (Int64.rem !x keyspace) (Int64.of_int i)
  done;
  for i = 0 to churn_n - 1 do
    x := lcg !x;
    let k = Int64.rem !x keyspace in
    if Int64.rem !x 4L = 3L then Hashtbl.remove m k
    else Hashtbl.replace m k (Int64.of_int (build_n + i))
  done;
  let acc = ref 0L in
  for _ = 0 to lookup_n - 1 do
    x := lcg !x;
    let v =
      match Hashtbl.find_opt m (Int64.rem !x keyspace) with
      | Some v -> v
      | None -> -1L
    in
    acc := Int64.add !acc v
  done;
  let folded =
    Hashtbl.fold
      (fun k v a -> Int64.add a (Int64.add (Int64.mul k 1_000_003L) v))
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
