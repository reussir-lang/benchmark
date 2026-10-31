/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
/- rbtree-lookup: rbtree's tree code (above copyright) with lookups. Insert
   1M scattered keys and after every insert look up 8 keys in the current
   tree, which stays live for the next insert. The inserts own the tree and
   can update it in place; the lookups only read it. -/
prelude
import Init.Data.SInt.Basic
import Init.Data.Option.Basic
import Init.Data.List.BasicAux
import Init.System.IO

inductive color
| Red | Black

inductive Tree
| Leaf                                                                           : Tree
| Node  (color : color) (lchild : Tree) (key : Int64) (val : Bool) (rchild : Tree) : Tree

open color Nat Tree

@[inline]
def balance1 : Int64 → Bool → Tree → Tree → Tree
| kv, vv, t, Node _ (Node Red l kx vx r₁) ky vy r₂   => Node Red (Node Black l kx vx r₁) ky vy (Node Black r₂ kv vv t)
| kv, vv, t, Node _ l₁ ky vy (Node Red l₂ kx vx r)   => Node Red (Node Black l₁ ky vy l₂) kx vx (Node Black r kv vv t)
| kv, vv, t, Node _ l  ky vy r                       => Node Black (Node Red l ky vy r) kv vv t
| _,  _,  _,                                       _ => Leaf

@[inline]
def balance2 : Tree → Int64 → Bool → Tree → Tree
| t, kv, vv, Node _ (Node Red l kx₁ vx₁ r₁) ky vy r₂    => Node Red (Node Black t kv vv l) kx₁ vx₁ (Node Black r₁ ky vy r₂)
| t, kv, vv, Node _ l₁ ky vy (Node Red l₂ kx₂ vx₂ r₂)   => Node Red (Node Black t kv vv l₁) ky vy (Node Black l₂ kx₂ vx₂ r₂)
| t, kv, vv, Node _ l ky vy r                           => Node Black t kv vv (Node Red l ky vy r)
| _, _, _,                                         _    => Leaf

def isRed : Tree → Bool
| Node Red _ _ _ _   => true
| _                  => false

def ins : Tree → Int64 → Bool → Tree
| Leaf,                 kx, vx => Node Red Leaf kx vx Leaf
| Node Red a ky vy b,   kx, vx =>
   (if kx < ky then Node Red (ins a kx vx) ky vy b
    else if kx = ky then Node Red a kx vx b
    else Node Red a ky vy (ins b kx vx))
| Node Black a ky vy b,   kx, vx =>
    if kx < ky then
      (if isRed a then balance1 ky vy b (ins a kx vx)
       else Node Black (ins a kx vx) ky vy b)
    else if kx = ky then Node Black a kx vx b
    else if isRed b then balance2 a ky vy (ins b kx vx)
         else Node Black a ky vy (ins b kx vx)

def setBlack : Tree → Tree
| Node _ l k v r   => Node Black l k v r
| e                => e

def insert (t : Tree) (k : Int64) (v : Bool) : Tree :=
if isRed t then setBlack (ins t k v)
else ins t k v

def get : Tree → Int64 → Bool
| Leaf,           _ => false
| Node _ l kx _ r, k => if k < kx then get l k else if k > kx then get r k else true

def probe : Nat → Int64 → Tree → Nat → Nat
| 0,     _, _, hits => hits
| j + 1, i, t, hits =>
  let k := (i * 31 + Int64.ofNat (j + 1) * 7919) % 2000000
  probe j i t (if get t k then hits + 1 else hits)

def rounds : Nat → Int64 → Int64 → Tree → Nat → Nat
| 0,     _, _, _, hits => hits
| r + 1, i, n, t, hits =>
  let t2 := insert t ((i * 7919) % n) true
  let h := probe 8 i t2 hits
  rounds r (i + 1) n t2 h

def main : IO UInt32 := do
  let hits := rounds 1000000 0 1000000 Leaf 0
  if hits != 2059798 then
    IO.eprintln s!"FAIL: expected 2059798, got {hits}"
    return 1
  return 0
