-- Adapted from: https://raw.githubusercontent.com/leanprover/lean4/IFL19/tests/bench/deriv.ml
prelude
import Init.System.IO

inductive Expr
| val (v : Int) : Expr
| var (id : Int) : Expr
| add (l r : Expr) : Expr
| mul (l r : Expr) : Expr
| pow (l r : Expr) : Expr
| ln (e : Expr) : Expr

partial def pown (a : Int) (b : Int) : Int :=
  if b <= 0 then
    if b == 0 then 1 else 0
  else
    a * pown a (b - 1)

partial def Expr.add' (n0 m0 : Expr) : Expr :=
  match n0, m0 with
  | Expr.val n, Expr.val m               => Expr.val (n + m)
  | Expr.val 0, f                        => f
  | f, Expr.val 0                        => f
  | f, Expr.val n                        => Expr.add' (Expr.val n) f
  | Expr.val n, Expr.add (Expr.val m) f  => Expr.add' (Expr.val (n + m)) f
  | f, Expr.add (Expr.val n) g           => Expr.add' (Expr.val n) (Expr.add' f g)
  | Expr.add f g, h                      => Expr.add' f (Expr.add' g h)
  | f, g                                 => Expr.add f g

partial def Expr.mul' (n0 m0 : Expr) : Expr :=
  match n0, m0 with
  | Expr.val n, Expr.val m               => Expr.val (n * m)
  | Expr.val 0, _                        => Expr.val 0
  | _, Expr.val 0                        => Expr.val 0
  | Expr.val 1, f                        => f
  | f, Expr.val 1                        => f
  | f, Expr.val n                        => Expr.mul' (Expr.val n) f
  | Expr.val n, Expr.mul (Expr.val m) f  => Expr.mul' (Expr.val (n * m)) f
  | f, Expr.mul (Expr.val n) g           => Expr.mul' (Expr.val n) (Expr.mul' f g)
  | Expr.mul f g, h                      => Expr.mul' f (Expr.mul' g h)
  | f, g                                 => Expr.mul f g

def Expr.pow' (m0 n0 : Expr) : Expr :=
  match m0, n0 with
  | Expr.val m, Expr.val n => Expr.val (pown m n)
  | _, Expr.val 0           => Expr.val 1
  | f, Expr.val 1           => f
  | Expr.val 0, _           => Expr.val 0
  | f, g                    => Expr.pow f g

def Expr.ln' (n : Expr) : Expr :=
  match n with
  | Expr.val 1 => Expr.val 0
  | f          => Expr.ln f

partial def d (x : Int) (e : Expr) : Expr :=
  match e with
  | Expr.val _    => Expr.val 0
  | Expr.var y    => if x == y then Expr.val 1 else Expr.val 0
  | Expr.add f g  => Expr.add' (d x f) (d x g)
  | Expr.mul f g  => Expr.add' (Expr.mul' f (d x g)) (Expr.mul' g (d x f))
  | Expr.pow f g  => Expr.mul' (Expr.pow' f g)
      (Expr.add' (Expr.mul' (Expr.mul' g (d x f)) (Expr.pow' f (Expr.val (-1))))
                  (Expr.mul' (Expr.ln' f) (d x g)))
  | Expr.ln f     => Expr.mul' (d x f) (Expr.pow' f (Expr.val (-1)))

def count : Expr → Nat
  | Expr.val _    => 1
  | Expr.var _    => 1
  | Expr.add f g  => count f + count g
  | Expr.mul f g  => count f + count g
  | Expr.pow f g  => count f + count g
  | Expr.ln f     => count f

def nestAux (s : Nat) (f : Nat → Expr → Expr) : Nat → Expr → Expr
  | 0, x       => x
  | n + 1, x   => nestAux s f n (f (s - (n + 1)) x)

def nest (f : Nat → Expr → Expr) (n : Nat) (e : Expr) : Expr :=
  nestAux n f n e

def deriv (_ : Nat) (f : Expr) : Expr :=
  d 0 f

unsafe def main : IO UInt32 :=
  let x := Expr.var 0
  let f := Expr.pow' x x
  let res := nest deriv 10 f
  IO.println (toString (count res)) *>
  pure 0
