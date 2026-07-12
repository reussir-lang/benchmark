import Init.Data.SInt.Basic

inductive QList where
  | nil
  | cons (value : Int64) (rest : QList)

inductive Rotation where
  | idle
  | reversing (ok : Int) (front frontRev rear rearRev : QList)
  | appending (ok : Int) (frontRev rearRev : QList)
  | done (front : QList)

structure Queue where
  lenFront : Nat
  front : QList
  state : Rotation
  lenRear : Nat
  rear : QList

open QList Rotation

def exec : Rotation → Rotation
  | reversing ok (cons x f) f' (cons y r) r' =>
    reversing (ok + 1) f (cons x f') r (cons y r')
  | reversing ok nil f' (cons y nil) r' => appending ok f' (cons y r')
  | appending 0 _ r' => done r'
  | appending ok (cons x f') r' => appending (ok - 1) f' (cons x r')
  | state => state

def invalidate : Rotation → Rotation
  | reversing ok f f' r r' => reversing (ok - 1) f f' r r'
  | appending 0 _ (cons _ r') => done r'
  | appending ok f' r' => appending (ok - 1) f' r'
  | state => state

def exec2 (queue : Queue) : Queue :=
  match exec (exec queue.state) with
  | done front => { queue with front := front, state := idle }
  | state => { queue with state := state }

def check (queue : Queue) : Queue :=
  if queue.lenRear ≤ queue.lenFront then exec2 queue
  else
    exec2 {
      lenFront := queue.lenFront + queue.lenRear
      front := queue.front
      state := reversing 0 queue.front nil queue.rear nil
      lenRear := 0
      rear := nil
    }

def snoc (queue : Queue) (value : Int64) : Queue :=
  check { queue with lenRear := queue.lenRear + 1, rear := cons value queue.rear }

def uncons (queue : Queue) : Int64 × Queue :=
  match queue.front with
  | cons value front =>
    (value, check { queue with lenFront := queue.lenFront - 1, front := front, state := invalidate queue.state })
  | nil => (0, queue)

def modulus : Int64 := 1000000007

partial def build (index : Nat) (queue : Queue) : Queue :=
  if index == 65536 then queue
  else build (index + 1) (snoc queue (Int64.ofNat index))

partial def churn (round remaining : Nat) (queue : Queue) (checksum : Int64) : Queue × Int64 :=
  if remaining == 0 then (queue, checksum)
  else
    let (value, rest) := uncons queue
    let next := (value + Int64.ofNat round + 1) % modulus
    churn (round + 1) (remaining - 1) (snoc rest next) ((checksum + value) % modulus)

partial def drain (remaining : Nat) (queue : Queue) (checksum : Int64) : Int64 :=
  if remaining == 0 then checksum
  else
    let (value, rest) := uncons queue
    drain (remaining - 1) rest ((checksum + value) % modulus)

def main : IO UInt32 := do
  let emptyQueue : Queue := { lenFront := 0, front := nil, state := idle, lenRear := 0, rear := nil }
  let (queue, checksum) := churn 0 1000000 (build 0 emptyQueue) 0
  let result := drain 65536 queue checksum
  if result != 66797929 then
    IO.eprintln s!"FAIL: expected 66797929, got {result}"
    return 1
  return 0
