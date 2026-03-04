prelude
import Init.System.IO

inductive Term
| var : Nat -> Term
| app : Term -> Term -> Term
| lam : Term -> Term
deriving Inhabited

unsafe inductive Value
| vVar : Nat -> Value
| vApp : Value -> Value -> Value
| vLam : (Value -> Value) -> Value

unsafe instance : Inhabited Value := ⟨Value.vVar 0⟩

unsafe def ap (t u : Value) : Value :=
  match t with
  | Value.vLam f => f u
  | _ => Value.vApp t u

unsafe def ap2 (t u v : Value) : Value :=
  ap (ap t u) v

unsafe def n2 : Value :=
  Value.vLam (fun s => Value.vLam (fun z => ap s (ap s z)))

unsafe def n5 : Value :=
  Value.vLam (fun s => Value.vLam (fun z => ap s (ap s (ap s (ap s (ap s z))))))

unsafe def mul : Value :=
  Value.vLam
    (fun a =>
      Value.vLam
        (fun b =>
          Value.vLam
            (fun s =>
              Value.vLam (fun z => ap (ap a (ap b s)) z))))

unsafe def suc (n : Value) : Value :=
  Value.vLam (fun s => Value.vLam (fun z => ap s (ap2 n s z)))

unsafe def n10 : Value := ap2 mul n2 n5
unsafe def n20 : Value := ap2 mul n2 n10
unsafe def n21 : Value := suc n20
unsafe def n22 : Value := suc n21

unsafe def leaf : Value :=
  Value.vLam (fun l => Value.vLam (fun _ => l))

unsafe def node : Value :=
  Value.vLam
    (fun t1 =>
      Value.vLam
        (fun t2 =>
          Value.vLam
            (fun _ =>
              Value.vLam (fun n => ap2 n t1 t2))))

unsafe def fullTree : Value :=
  Value.vLam (fun n => ap2 n (Value.vLam (fun t => ap2 node t t)) leaf)

unsafe def quote (l : Nat) (v : Value) : Term :=
  match v with
  | Value.vVar x => Term.var (l - x - 1)
  | Value.vLam t => Term.lam (quote (l + 1) (t (Value.vVar l)))
  | Value.vApp t u => Term.app (quote l t) (quote l u)

unsafe def quote0 (v : Value) : Term := quote 0 v

def force (t : Term) : Nat :=
  match t with
  | Term.var _ => 0
  | Term.app t1 t2 => force t1 + force t2
  | Term.lam body => force body + 1

unsafe def main : IO UInt32 := do
  let tree8m := ap fullTree n22
  let lamCount := force (quote0 tree8m)
  if lamCount != 16777214 then
    IO.eprintln s!"FAIL: expected 16777214, got {lamCount}"
    pure 1
  else
    pure 0
