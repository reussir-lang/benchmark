(* Std-collection workload on OCaml's standard ordered map
   (Stdlib.Map.Make — a persistent AVL tree). Build 1M MINSTD-keyed
   inserts over a 524287 keyspace, churn 1M insert/remove rounds, sum 1M
   lookups (-1 for a miss), then fold the final map:
   result = lookup-sum + sum(key * 1000003 + value) + 7 * size. *)

module M = Map.Make (Int64)

let keyspace = 524_287L
let build_n = 1_000_000
let churn_n = 1_000_000
let lookup_n = 1_000_000
let expected = 105_140_861_851_414_131L
let lcg x = Int64.rem (Int64.mul x 48_271L) 2_147_483_647L

let build () =
  let rec go i x m =
    if i = build_n then (x, m)
    else
      let x' = lcg x in
      go (i + 1) x' (M.add (Int64.rem x' keyspace) (Int64.of_int i) m)
  in
  go 0 1L M.empty

let churn x0 m0 =
  let rec go i x m =
    if i = churn_n then (x, m)
    else
      let x' = lcg x in
      let k = Int64.rem x' keyspace in
      let m' =
        if Int64.rem x' 4L = 3L then M.remove k m
        else M.add k (Int64.of_int (build_n + i)) m
      in
      go (i + 1) x' m'
  in
  go 0 x0 m0

let lookups x0 m =
  let rec go i x acc =
    if i = lookup_n then acc
    else
      let x' = lcg x in
      let v =
        match M.find_opt (Int64.rem x' keyspace) m with
        | Some v -> v
        | None -> -1L
      in
      go (i + 1) x' (Int64.add acc v)
  in
  go 0 x0 0L

let () =
  let x1, built = build () in
  let x2, m = churn x1 built in
  let acc = lookups x2 m in
  let folded =
    M.fold
      (fun k v a -> Int64.add a (Int64.add (Int64.mul k 1_000_003L) v))
      m 0L
  in
  let result =
    Int64.add (Int64.add acc folded) (Int64.mul 7L (Int64.of_int (M.cardinal m)))
  in
  if result <> expected then (
    Printf.eprintf "FAIL: expected %Ld, got %Ld\n" expected result;
    exit 1)
