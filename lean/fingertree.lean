import Init.Data.SInt.Basic

inductive Elem where
  | value (value : Int64)
  | node2 (a b : Elem)
  | node3 (a b c : Elem)

inductive Digit where
  | one (a : Elem)
  | two (a b : Elem)
  | three (a b c : Elem)
  | four (a b c d : Elem)

inductive FingerTree where
  | empty
  | single (value : Elem)
  | deep (frontDigit : Digit) (middle : FingerTree) (backDigit : Digit)

open Elem Digit FingerTree

def nodeToDigit : Elem → Digit
  | node2 a b => two a b
  | node3 a b c => three a b c
  | value _ => one (value 0)

def digitToTree : Digit → FingerTree
  | one a => single a
  | two a b => deep (one a) empty (one b)
  | three a b c => deep (two a b) empty (one c)
  | four a b c d => deep (two a b) empty (two c d)

partial def snoc (tree : FingerTree) (x : Elem) : FingerTree :=
  match tree with
  | empty => single x
  | single a => deep (one a) empty (one x)
  | deep pr middle (four a b c d) =>
    deep pr (snoc middle (node3 a b c)) (two d x)
  | deep pr middle (one a) => deep pr middle (two a x)
  | deep pr middle (two a b) => deep pr middle (three a b x)
  | deep pr middle (three a b c) => deep pr middle (four a b c x)

partial def viewLeft (tree : FingerTree) : Option (Elem × FingerTree) :=
  match tree with
  | empty => none
  | single x => some (x, empty)
  | deep (one x) middle suffix =>
    match viewLeft middle with
    | none => some (x, digitToTree suffix)
    | some (node, middle') => some (x, deep (nodeToDigit node) middle' suffix)
  | deep (two a b) middle suffix => some (a, deep (one b) middle suffix)
  | deep (three a b c) middle suffix => some (a, deep (two b c) middle suffix)
  | deep (four a b c d) middle suffix => some (a, deep (three b c d) middle suffix)

def modulus : Int64 := 1000000007

partial def build (index : Nat) (tree : FingerTree) : FingerTree :=
  if index == 65536 then tree
  else build (index + 1) (snoc tree (value (Int64.ofNat index)))

partial def churn (round remaining : Nat) (tree : FingerTree) (checksum : Int64) : FingerTree × Int64 :=
  if remaining == 0 then (tree, checksum)
  else
    match viewLeft tree with
    | some (value x, rest) =>
      let next := (x + Int64.ofNat round + 1) % modulus
      churn (round + 1) (remaining - 1) (snoc rest (value next)) ((checksum + x) % modulus)
    | _ => (tree, checksum)

partial def drain (tree : FingerTree) (checksum : Int64) : Int64 :=
  match viewLeft tree with
  | none => checksum
  | some (value x, rest) => drain rest ((checksum + x) % modulus)
  | _ => checksum

def main : IO UInt32 := do
  let (tree, checksum) := churn 0 1000000 (build 0 empty) 0
  let result := drain tree checksum
  if result != 66797929 then
    IO.eprintln s!"FAIL: expected 66797929, got {result}"
    return 1
  return 0
