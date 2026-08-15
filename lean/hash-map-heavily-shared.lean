import Std.Data.HashMap

/- Std-collection workload on Lean's standard hash map
   (Std.HashMap — an array-backed table, updated in place when uniquely
   referenced). Zipfian mixed-op workload: keys follow an integer-only
   octave Zipf (theta ~ 1) — a stratum s drawn uniform in [0, 24), then
   a key uniform in [2^s, 2^(s+1)), so every octave carries equal mass
   and per-key probability decays as 1/key. 8M rounds, each drawing op,
   stratum, key from one MINSTD stream: 9/16 insert, 5/16 delete, 2/16
   lookup (sum, -1 on miss). Deletes land on present keys ~48% of the
   time.

   After each round one more draw decides retention: when it is
   divisible by 512 (15,630 times over the run) the current version is
   parked in slot (draw / 512) mod 8 of an eight-version ring, where
   it stays shared until that slot is next overwritten. Persistent maps
   pay path copies while a parked version is live; mutable maps pay a
   full copy per parked version. The checksum folds the working map and
   every ring slot, so retained versions stay live and verified. Final
   size 1,120,619; each ring slot ends holding a ~1.1M-entry version.
   Std.HashMap is updated in place only while uniquely referenced, so a
   parked version makes the next update copy the table — the honest cost
   of retention for this representation. The checksum is iteration-order
   independent so all representations agree.

   Heavily shared tier: retention fires ~15x more often than
   hash-map-shared,
   past the crossover where per-event full copies dominate a mutable
   representation. -/

open Std

def opsN : Int64 := 8000000
def expected : Int64 := 1285288094593426

def lcg (x : Int64) : Int64 :=
  (x * 48271) % 2147483647

def foldOne (m : HashMap Int64 Int64) (acc : Int64) : Int64 :=
  acc + m.fold (fun a k v => a + k * 31 + v) 0 + 7 * Int64.ofNat m.size

partial def opsLoop (i : Int64) (x : Int64) (m : HashMap Int64 Int64)
    (ring : Array (HashMap Int64 Int64)) (acc : Int64) : Int64 :=
  if i == opsN then
    ring.foldl (fun a hm => foldOne hm a) (foldOne m acc)
  else
    let x1 := lcg x
    let op := x1 % 16
    let x2 := lcg x1
    let s := (x2 % 24).toNatClampNeg
    let x3 := lcg x2
    let stratum : Int64 := 1 <<< Int64.ofNat s
    let k := stratum + (x3 % stratum)
    let m2 :=
      if op < 9 then m.insert k i
      else if op < 14 then m.erase k
      else m
    let acc2 := if op < 14 then acc else acc + m2.getD k (-1)
    let x4 := lcg x3
    if x4 % 512 == 0 then
      let slot := ((x4 / 512) % 8).toNatClampNeg
      opsLoop (i + 1) x4 m2 (ring.set! slot m2) acc2
    else
      opsLoop (i + 1) x4 m2 ring acc2

def main : IO UInt32 := do
  let ring := Array.replicate 8 (∅ : HashMap Int64 Int64)
  let r := opsLoop 0 1 (∅ : HashMap Int64 Int64) ring 0
  if r != expected then
    IO.eprintln s!"FAIL: expected {expected}, got {r}"
    return 1
  return 0
