import Std.Data.TreeMap

/- Std-collection workload on Lean's standard ordered map
   (Std.TreeMap — a size-bounded balanced tree, updated in place when
   uniquely referenced). Build 1M MINSTD-keyed inserts over a 524287
   keyspace, churn 1M insert/remove rounds, sum 1M lookups (-1 for a
   miss), then fold the final map:
   result = lookup-sum + sum(key * 1000003 + value) + 7 * size.

   Linear variant: exactly one live version — the map is threaded
   linearly through every round and nothing is retained, so Std.TreeMap
   stays uniquely referenced and updates in place throughout. Final
   size 400,944. -/

open Std

def keyspace : Int64 := 524287
def buildN : Int64 := 1000000
def churnN : Int64 := 1000000
def lookupN : Int64 := 1000000
def expected : Int64 := 105140861851414131

def lcg (x : Int64) : Int64 :=
  (x * 48271) % 2147483647

partial def buildLoop (i : Int64) (x : Int64) (m : TreeMap Int64 Int64) :
    Int64 × TreeMap Int64 Int64 :=
  if i == buildN then (x, m)
  else
    let x' := lcg x
    buildLoop (i + 1) x' (m.insert (x' % keyspace) i)

partial def churnLoop (i : Int64) (x : Int64) (m : TreeMap Int64 Int64) :
    Int64 × TreeMap Int64 Int64 :=
  if i == churnN then (x, m)
  else
    let x' := lcg x
    let k := x' % keyspace
    let m' := if x' % 4 == 3 then m.erase k else m.insert k (buildN + i)
    churnLoop (i + 1) x' m'

partial def lookupLoop (i : Int64) (x : Int64) (m : TreeMap Int64 Int64)
    (acc : Int64) : Int64 :=
  if i == lookupN then acc
  else
    let x' := lcg x
    lookupLoop (i + 1) x' m (acc + m.getD (x' % keyspace) (-1))

def mapTest : Int64 :=
  let (x1, built) := buildLoop 0 1 TreeMap.empty
  let (x2, m) := churnLoop 0 x1 built
  let acc := lookupLoop 0 x2 m 0
  acc + m.foldl (fun a k v => a + k * 1000003 + v) 0 + 7 * Int64.ofNat m.size

def main : IO UInt32 := do
  let r := mapTest
  if r != expected then
    IO.eprintln s!"FAIL: expected {expected}, got {r}"
    return 1
  return 0
