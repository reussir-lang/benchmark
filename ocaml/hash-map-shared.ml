(* Std-collection workload on OCaml's standard hash map
   (Stdlib.Hashtbl, mutable in place, seeded polynomial hash). Zipfian
   mixed-op workload: keys follow an integer-only octave Zipf
   (theta ~ 1) — a stratum s drawn uniform in [0, 24), then a key
   uniform in [2^s, 2^(s+1)), so every octave carries equal mass and
   per-key probability decays as 1/key. 2M rounds, each drawing op,
   stratum, key from one MINSTD stream: 9/16 insert, 5/16 delete, 2/16
   lookup (sum, -1 on miss). Deletes land on present keys ~48% of the
   time.

   After each round one more draw decides retention: when it is
   divisible by 8192 (266 times over the run) the current version is
   parked in slot (draw / 8192) mod 8 of an eight-version ring, where
   it stays shared until that slot is next overwritten. A mutable table
   has no structural sharing, so retention is an explicit Hashtbl.copy
   at the event — the honest cost of versioning for this
   representation. The checksum folds the working map and every ring
   slot, so retained versions stay live and verified. Final size
   373,649; each ring slot ends holding a ~360k-entry version. The
   checksum is iteration-order independent so all representations
   agree. Replace semantics keep at most one binding per key. *)

let ops_n = 2_000_000
let expected = 317_327_888_655_435L
let lcg x = Int64.rem (Int64.mul x 48_271L) 2_147_483_647L

let fold_one (m : (int64, int64) Hashtbl.t) (acc : int64) =
  let folded =
    Hashtbl.fold
      (fun k v a -> Int64.add a (Int64.add (Int64.mul k 31L) v))
      m acc
  in
  Int64.add folded (Int64.mul 7L (Int64.of_int (Hashtbl.length m)))

let () =
  let m : (int64, int64) Hashtbl.t = Hashtbl.create 1024 in
  let ring = Array.init 8 (fun _ -> Hashtbl.create 1) in
  let x = ref 1L in
  let acc = ref 0L in
  for i = 0 to ops_n - 1 do
    x := lcg !x;
    let op = Int64.rem !x 16L in
    x := lcg !x;
    let s = Int64.to_int (Int64.rem !x 24L) in
    x := lcg !x;
    let stratum = Int64.shift_left 1L s in
    let k = Int64.add stratum (Int64.rem !x stratum) in
    if op < 9L then Hashtbl.replace m k (Int64.of_int i)
    else if op < 14L then Hashtbl.remove m k
    else begin
      let v = match Hashtbl.find_opt m k with Some v -> v | None -> -1L in
      acc := Int64.add !acc v
    end;
    x := lcg !x;
    if Int64.rem !x 8192L = 0L then
      let slot = Int64.to_int (Int64.rem (Int64.div !x 8192L) 8L) in
      ring.(slot) <- Hashtbl.copy m
  done;
  let result =
    Array.fold_left (fun a t -> fold_one t a) (fold_one m !acc) ring
  in
  if result <> expected then (
    Printf.eprintf "FAIL: expected %Ld, got %Ld\n" expected result;
    exit 1)
