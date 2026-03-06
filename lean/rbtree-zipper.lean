/- Port of the zipper-based rbtree benchmark from Koka/Reussir. -/
prelude
import Init.Data.Option.Basic
import Init.Data.List.BasicAux
import Init.System.IO

inductive color
| Red | Black

inductive Tree
| Leaf                                                                           : Tree
| Node  (color : color) (lchild : Tree) (key : Nat) (val : Bool) (rchild : Tree) : Tree

inductive Zipper
| NodeR (color : color) (lchild : Tree) (key : Nat) (val : Bool) (zip : Zipper)  : Zipper
| NodeL (color : color) (zip : Zipper) (key : Nat) (val : Bool) (rchild : Tree)  : Zipper
| Done                                                                            : Zipper

open color Nat Tree Zipper

def moveUp : Zipper → Tree → Tree
| NodeR c l k v z1, t => moveUp z1 (Node c l k v t)
| NodeL c z1 k v r, t => moveUp z1 (Node c t k v r)
| Done,            t => t

partial def balanceRed : Zipper → Tree → Nat → Bool → Tree → Tree
| NodeR Black l1 k1 v1 z1, l, k, v, r =>
    moveUp z1 (Node Black l1 k1 v1 (Node Red l k v r))
| NodeL Black z1 k1 v1 r1, l, k, v, r =>
    moveUp z1 (Node Black (Node Red l k v r) k1 v1 r1)
| NodeR Red l1 k1 v1 z1, l, k, v, r =>
    match z1 with
    | NodeR _ l2 k2 v2 z2 =>
        balanceRed z2 (Node Black l2 k2 v2 l1) k1 v1 (Node Black l k v r)
    | NodeL _ z2 k2 v2 r2 =>
        balanceRed z2 (Node Black l1 k1 v1 l) k v (Node Black r k2 v2 r2)
    | Done =>
        Node Black l1 k1 v1 (Node Red l k v r)
| NodeL Red z1 k1 v1 r1, l, k, v, r =>
    match z1 with
    | NodeR _ l2 k2 v2 z2 =>
        balanceRed z2 (Node Black l2 k2 v2 l) k v (Node Black r k1 v1 r1)
    | NodeL _ z2 k2 v2 r2 =>
        balanceRed z2 (Node Black l k v r) k1 v1 (Node Black r1 k2 v2 r2)
    | Done =>
        Node Black (Node Red l k v r) k1 v1 r1
| Done, l, k, v, r =>
    Node Black l k v r

def ins : Tree → Nat → Bool → Zipper → Tree
| Node c l kx vx r, k, v, z =>
    if k < kx then
      ins l k v (NodeL c z kx vx r)
    else if k > kx then
      ins r k v (NodeR c l kx vx z)
    else
      moveUp z (Node c l kx vx r)
| Leaf, k, v, z =>
    balanceRed z Leaf k v Leaf

def insert (t : Tree) (k : Nat) (v : Bool) : Tree :=
  ins t k v Done

def foldAction (_ : Nat) (v : Bool) (acc : Nat) : Nat :=
  if v then acc + 1 else acc

def fold : Tree → Nat → Nat
| Leaf, b             => b
| Node _ l k v r, b   => fold r (foldAction k v (fold l b))

def makeTreeAux : Nat → Tree → Tree
| 0, t   => t
| n+1, t =>
    let m := n
    makeTreeAux n (insert t m (m % 10 = 0))

def makeTree (n : Nat) : Tree :=
  makeTreeAux n Leaf

def main : IO UInt32 :=
  let t := makeTree 4200000
  let v := fold t 0
  IO.println (toString v) *>
  pure 0
