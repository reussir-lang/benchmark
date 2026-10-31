(* list-membership: 40000 membership queries against one 10000-element list
   that the caller keeps between queries (reussir-lang/reussir#762). Every
   query only reads the list; half of them miss and walk all of it. *)

let rec mem x = function
  | [] -> false
  | y :: ys -> if Int64.equal x y then true else mem x ys

(* [1 .. n] *)
let rec build n acc = if n = 0 then acc else build (n - 1) (Int64.of_int n :: acc)

let rec search q n xs hits =
  if q = 0 then hits
  else
    let x = Int64.of_int ((q * 7919) mod (2 * n) + 1) in
    search (q - 1) n xs (if mem x xs then hits + 1 else hits)

let () =
  let hits = search 40000 10000 (build 10000 []) 0 in
  if hits <> 20000 then (
    Printf.eprintf "FAIL: expected 20000, got %d\n" hits;
    exit 1)
