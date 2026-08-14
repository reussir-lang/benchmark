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

   Linear variant: exactly one live version — the map is threaded
   linearly through every round and nothing is retained, so Std.HashMap
   stays uniquely referenced and updates in place throughout. The
   checksum folds the final map (iteration-order independent so all
   representations agree). Final size 1,120,773. -/

open Std

def opsN : Int64 := 8000000
def expected : Int64 := 144585704074329

def lcg (x : Int64) : Int64 :=
  (x * 48271) % 2147483647

def foldOne (m : HashMap Int64 Int64) (acc : Int64) : Int64 :=
  acc + m.fold (fun a k v => a + k * 31 + v) 0 + 7 * Int64.ofNat m.size

partial def opsLoop (i : Int64) (x : Int64) (m : HashMap Int64 Int64)
    (acc : Int64) : Int64 :=
  if i == opsN then
    foldOne m acc
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
    opsLoop (i + 1) x3 m2 acc2

def main : IO UInt32 := do
  let r := opsLoop 0 1 (∅ : HashMap Int64 Int64) 0
  if r != expected then
    IO.eprintln s!"FAIL: expected {expected}, got {r}"
    return 1
  return 0
