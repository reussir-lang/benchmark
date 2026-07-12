/- Purely functional Braun min-heap. All heap-functional ports use this
   exact insert and replace-top algorithm. -/

import Init.Data.SInt.Basic

inductive Heap where
  | node (value : Int64) (left right : Heap)
  | leaf

open Heap

def p : Int64 := 1000000007

def lcg (x : Int64) : Int64 :=
  (x * 48271) % 2147483647

def gauss (x : Int64) : Int64 × Int64 :=
  let x1 := lcg x
  let x2 := lcg x1
  let x3 := lcg x2
  let x4 := lcg x3
  let x5 := lcg x4
  let x6 := lcg x5
  let x7 := lcg x6
  let x8 := lcg x7
  let x9 := lcg x8
  let x10 := lcg x9
  let x11 := lcg x10
  let x12 := lcg x11
  (x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12, x12)

def insert (h : Heap) (v : Int64) : Heap :=
  match h with
  | leaf => node v leaf leaf
  | node w l r =>
    if v ≤ w then node v (insert r w) l
    else node w (insert r v) l

partial def down (v : Int64) (l r : Heap) : Heap :=
  match l, r with
  | node lv ll lr, node rv rl rr =>
    if lv ≤ rv then
      if v ≤ lv then node v l r else node lv (down v ll lr) r
    else
      if v ≤ rv then node v l r else node rv l (down v rl rr)
  | node lv ll lr, leaf =>
    if v ≤ lv then node v l leaf else node lv (down v ll lr) leaf
  | leaf, node rv rl rr =>
    if v ≤ rv then node v leaf r else node rv leaf (down v rl rr)
  | leaf, leaf => node v leaf leaf

def replaceTop (h : Heap) (v : Int64) : Heap :=
  match h with
  | node _ l r => down v l r
  | leaf => node v leaf leaf

def top : Heap → Int64
  | node w _ _ => w
  | leaf => 0

partial def heapSum (h : Heap) (acc : Int64) : Int64 :=
  match h with
  | leaf => acc
  | node w l r => heapSum r (heapSum l ((acc + w) % p))

partial def build (k : Nat) (x : Int64) (h : Heap) : Heap × Int64 :=
  if k == 65535 then (h, x)
  else
    let (g, x') := gauss x
    build (k + 1) x' (insert h g)

partial def maintain (m : Nat) (x : Int64) (h : Heap) (acc : Int64) : Int64 :=
  match m with
  | 0 => (acc + heapSum h 0) % p
  | m'+1 =>
    let (g, x') := gauss x
    let t := top h
    maintain m' x' (replaceTop h (t + g)) ((acc + t) % p)

def heapTest (m : Nat) : Int64 :=
  let (h, x) := build 0 20260711 leaf
  maintain m x h 0

def main : IO UInt32 := do
  let result := heapTest 6500000
  if result != 558972311 then
    IO.eprintln s!"FAIL: expected 558972311, got {result}"
    return 1
  return 0
