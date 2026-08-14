import Std.Data.HashMap

/- Std-collection workload on Lean's standard hash map
   (Std.HashMap — an array-backed table, updated in place when uniquely
   referenced). Large and broad: keys are raw MINSTD draws, uniform
   over [1, 2^31-2]; MINSTD is a full-period permutation, so fresh
   draws never repeat, and removals plus the hit half of the lookups
   replay the build key stream through a second MINSTD state. Build 4M
   inserts, churn 2M rounds, 2M lookups alternating replayed hits and
   fresh misses. Final size 4,999,834; the checksum is iteration-order
   independent so all representations agree. -/

open Std

def buildN : Int64 := 4000000
def churnN : Int64 := 2000000
def lookupN : Int64 := 2000000
def expected : Int64 := 166401892080070584

def lcg (x : Int64) : Int64 :=
  (x * 48271) % 2147483647

partial def buildLoop (i : Int64) (x : Int64) (m : HashMap Int64 Int64) :
    HashMap Int64 Int64 :=
  if i == buildN then m
  else
    let x' := lcg x
    buildLoop (i + 1) x' (m.insert x' i)

partial def churnLoop (i : Int64) (x : Int64) (r : Int64)
    (m : HashMap Int64 Int64) : Int64 × Int64 × HashMap Int64 Int64 :=
  if i == churnN then (x, r, m)
  else
    let x' := lcg x
    if x' % 4 == 3 then
      let r' := lcg r
      churnLoop (i + 1) x' r' (m.erase r')
    else
      churnLoop (i + 1) x' r (m.insert x' (buildN + i))

partial def lookupLoop (i : Int64) (x : Int64) (r : Int64)
    (m : HashMap Int64 Int64) (acc : Int64) : Int64 :=
  if i == lookupN then acc
  else
    let x' := lcg x
    if x' % 2 == 0 then
      let r' := lcg r
      lookupLoop (i + 1) x' r' m (acc + m.getD r' (-1))
    else
      lookupLoop (i + 1) x' r m (acc + m.getD x' (-1))

def mapTest : Int64 :=
  let built := buildLoop 0 1 (∅ : HashMap Int64 Int64)
  let (x2, r1, m) := churnLoop 0 111912599 1 built
  let acc := lookupLoop 0 x2 r1 m 0
  let folded := m.fold (fun a k v => a + k * 31 + v) 0
  acc + folded + 7 * Int64.ofNat m.size

def main : IO UInt32 := do
  let r := mapTest
  if r != expected then
    IO.eprintln s!"FAIL: expected {expected}, got {r}"
    return 1
  return 0
