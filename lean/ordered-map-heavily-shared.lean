import Std.Data.TreeMap

/- Std-collection workload on Lean's standard ordered map
   (Std.TreeMap — a size-bounded balanced tree, updated in place when
   uniquely referenced). Build 500k MINSTD-keyed inserts over a 524287
   keyspace, churn 500k insert/remove rounds, sum 500k lookups (-1 for a
   miss), then fold the final map:
   result = lookup-sum + sum(key * 1000003 + value) + 7 * size.

   During the two mutating phases a second draw per round decides
   retention: when it is divisible by 512 (1,951 times over the run) the
   current version is parked in slot (draw / 512) mod 8 of an
   eight-version ring, where it stays shared until that slot is next
   overwritten. The checksum folds the final map and every ring slot,
   so retained versions stay live and verified. Final size 365,836;
   each ring slot ends holding a ~366k-entry version.
   Std.TreeMap is updated in place only while uniquely referenced, so a
   parked version makes later updates copy their path — the honest cost
   of retention for this representation.

   Heavily shared tier: retention fires ~15x more often than
   ordered-map-shared, past the crossover where per-event full copies
   dominate a mutable representation. -/

open Std

def keyspace : Int64 := 524287
def buildN : Int64 := 500000
def churnN : Int64 := 500000
def lookupN : Int64 := 500000
def expected : Int64 := 861736461765462691

def lcg (x : Int64) : Int64 :=
  (x * 48271) % 2147483647

partial def buildLoop (i : Int64) (x : Int64) (m : TreeMap Int64 Int64)
    (ring : Array (TreeMap Int64 Int64)) :
    Int64 × TreeMap Int64 Int64 × Array (TreeMap Int64 Int64) :=
  if i == buildN then (x, m, ring)
  else
    let x' := lcg x
    let m' := m.insert (x' % keyspace) i
    let x'' := lcg x'
    let ring' :=
      if x'' % 512 == 0 then
        ring.set! ((x'' / 512) % 8).toNatClampNeg m'
      else ring
    buildLoop (i + 1) x'' m' ring'

partial def churnLoop (i : Int64) (x : Int64) (m : TreeMap Int64 Int64)
    (ring : Array (TreeMap Int64 Int64)) :
    Int64 × TreeMap Int64 Int64 × Array (TreeMap Int64 Int64) :=
  if i == churnN then (x, m, ring)
  else
    let x' := lcg x
    let k := x' % keyspace
    let m' := if x' % 4 == 3 then m.erase k else m.insert k (buildN + i)
    let x'' := lcg x'
    let ring' :=
      if x'' % 512 == 0 then
        ring.set! ((x'' / 512) % 8).toNatClampNeg m'
      else ring
    churnLoop (i + 1) x'' m' ring'

partial def lookupLoop (i : Int64) (x : Int64) (m : TreeMap Int64 Int64)
    (acc : Int64) : Int64 :=
  if i == lookupN then acc
  else
    let x' := lcg x
    lookupLoop (i + 1) x' m (acc + m.getD (x' % keyspace) (-1))

def foldOne (m : TreeMap Int64 Int64) (acc : Int64) : Int64 :=
  acc + m.foldl (fun a k v => a + k * 1000003 + v) 0 + 7 * Int64.ofNat m.size

def mapTest : Int64 :=
  let ring0 := Array.replicate 8 (TreeMap.empty : TreeMap Int64 Int64)
  let (x1, built, ring1) := buildLoop 0 1 TreeMap.empty ring0
  let (x2, m, ring) := churnLoop 0 x1 built ring1
  let acc := lookupLoop 0 x2 m 0
  ring.foldl (fun a t => foldOne t a) (foldOne m acc)

def main : IO UInt32 := do
  let r := mapTest
  if r != expected then
    IO.eprintln s!"FAIL: expected {expected}, got {r}"
    return 1
  return 0
