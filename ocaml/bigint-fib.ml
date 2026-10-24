(* Iterative Fibonacci over Zarith integers: 600000 steps of
   (a, b) -> (b, a + b), so both operands soon grow far beyond a machine
   word. *)

let rec fib_loop n a b = if n = 0 then a else fib_loop (n - 1) b (Z.add a b)

let () =
  let r = Z.rem (fib_loop 600_000 Z.zero Z.one) (Z.of_int 1_000_000_007) in
  if not (Z.equal r (Z.of_int 555_579_099)) then (
    Printf.eprintf "FAIL: expected 555579099, got %s\n" (Z.to_string r);
    exit 1)
