(* The first 10000 decimal digits of pi with Gibbons' unbounded spigot (the
   Computer Language Benchmarks Game algorithm), folded into a rolling
   hash. *)

let modulus = Z.of_int 1_000_000_007

let rec spigot count i k k1 n a d h =
  let k = Z.succ k in
  let t = Z.mul n (Z.of_int 2) in
  let n = Z.mul n k in
  let k1 = Z.add k1 (Z.of_int 2) in
  let a = Z.mul (Z.add a t) k1 in
  let d = Z.mul d k1 in
  if Z.geq a n then
    let q, r = Z.div_rem (Z.add (Z.mul n (Z.of_int 3)) a) d in
    let u = Z.add r n in
    if Z.gt d u then
      let h = Z.rem (Z.add (Z.mul h (Z.of_int 10)) q) modulus in
      if i + 1 >= count then h
      else
        spigot count (i + 1) k k1 (Z.mul n (Z.of_int 10))
          (Z.mul (Z.sub a (Z.mul d q)) (Z.of_int 10))
          d h
    else spigot count i k k1 n a d h
  else spigot count i k k1 n a d h

let () =
  let r = spigot 10_000 0 Z.zero Z.one Z.one Z.zero Z.one Z.zero in
  if not (Z.equal r (Z.of_int 334_354_775)) then (
    Printf.eprintf "FAIL: expected 334354775, got %s\n" (Z.to_string r);
    exit 1)
