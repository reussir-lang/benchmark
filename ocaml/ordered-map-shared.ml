(* Std-collection workload on OCaml's standard ordered map
   (Stdlib.Map.Make — a persistent AVL tree). Build 500k MINSTD-keyed
   inserts over a 524287 keyspace, churn 1M insert/remove rounds, sum
   500k lookups (-1 for a miss), then fold the final map:
   result = lookup-sum + sum(key * 1000003 + value) + 7 * size.

   During the two mutating phases a second draw per round decides
   retention: when it is divisible by 8192 (265 times over the run) the
   current version is parked in slot (draw / 8192) mod 8 of an
   eight-version ring, where it stays shared until that slot is next
   overwritten; a persistent tree parks a version by keeping the
   handle. The checksum folds the final map and every ring slot, so
   retained versions stay live and verified. Final size 401,258; each
   ring slot ends holding a ~401k-entry version. *)

module M = Map.Make (Int64)

let keyspace = 524_287L
let build_n = 1_000_000
let churn_n = 1_000_000
let lookup_n = 1_000_000
let expected = 948_266_134_564_763_663L
let lcg x = Int64.rem (Int64.mul x 48_271L) 2_147_483_647L

let retain x m ring =
  if Int64.rem x 8192L = 0L then begin
    let slot = Int64.to_int (Int64.rem (Int64.div x 8192L) 8L) in
    ring.(slot) <- m
  end

let build ring =
  let rec go i x m =
    if i = build_n then (x, m)
    else
      let x' = lcg x in
      let m' = M.add (Int64.rem x' keyspace) (Int64.of_int i) m in
      let x'' = lcg x' in
      retain x'' m' ring;
      go (i + 1) x'' m'
  in
  go 0 1L M.empty

let churn x0 m0 ring =
  let rec go i x m =
    if i = churn_n then (x, m)
    else
      let x' = lcg x in
      let k = Int64.rem x' keyspace in
      let m' =
        if Int64.rem x' 4L = 3L then M.remove k m
        else M.add k (Int64.of_int (build_n + i)) m
      in
      let x'' = lcg x' in
      retain x'' m' ring;
      go (i + 1) x'' m'
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

let fold_one m acc =
  let folded =
    M.fold
      (fun k v a -> Int64.add a (Int64.add (Int64.mul k 1_000_003L) v))
      m acc
  in
  Int64.add folded (Int64.mul 7L (Int64.of_int (M.cardinal m)))

let () =
  let ring = Array.make 8 M.empty in
  let x1, built = build ring in
  let x2, m = churn x1 built ring in
  let acc = lookups x2 m in
  let result = Array.fold_left (fun a t -> fold_one t a) (fold_one m acc) ring in
  if result <> expected then (
    Printf.eprintf "FAIL: expected %Ld, got %Ld\n" expected result;
    exit 1)
