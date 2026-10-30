(* 120000! by sequential multiplication 2 * 3 * ... * n: a growing big
   integer times a word-sized factor. *)

let rec fact_loop i n acc =
  if i > n then acc else fact_loop (i + 1) n (Z.mul acc (Z.of_int i))

let () =
  let r = Z.rem (fact_loop 2 120_000 Z.one) (Z.of_int 1_000_000_007) in
  if not (Z.equal r (Z.of_int 118_586_228)) then (
    Printf.eprintf "FAIL: expected 118586228, got %s\n" (Z.to_string r);
    exit 1)
