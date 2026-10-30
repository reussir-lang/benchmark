(* The binomial row C(200000, i) by the multiplicative recurrence
   C(n, i + 1) = C(n, i) * (n - i) / (i + 1): every division is exact, by a
   word-sized divisor. The row must sum to 2^n and end at 1. *)

let rec row n i c s =
  if i >= n then (c, s)
  else
    let c = Z.div (Z.mul c (Z.of_int (n - i))) (Z.of_int (i + 1)) in
    row n (i + 1) c (Z.add s c)

let () =
  let last, sum = row 200_000 0 Z.one Z.one in
  let r = Z.rem sum (Z.of_int 1_000_000_007) in
  if not (Z.equal last Z.one && Z.equal r (Z.of_int 175_895_282)) then (
    Printf.eprintf "FAIL: expected last 1 and 175895282, got %s and %s\n"
      (Z.to_string last) (Z.to_string r);
    exit 1)
