prelude
import Init.System.IO

inductive Term
| var (id : Nat) : Term
| lam (id : Nat) (body : Term) : Term
| app (t1 : Term) (t2 : Term) : Term
| letE (id : Nat) (value : Term) (body : Term) : Term
deriving Inhabited

mutual
unsafe inductive Value where
| vVar (id : Nat) : Value
| vApp (v1 : Value) (v2 : Value) : Value
| vLam (id : Nat) (body : Term) (env : Env) : Value

unsafe inductive Env where
| envCons (id : Nat) (value : Value) (env : Env) : Env
| envNil : Env
end

unsafe instance : Inhabited Value := ⟨Value.vVar 0⟩

unsafe instance : Inhabited Env := ⟨Env.envNil⟩

inductive Names
| nameCons (id : Nat) (names : Names) : Names
| nameNil : Names
deriving Inhabited

def maxOfNames (n : Names) (acc : Nat) : Nat :=
  match n with
  | Names.nameCons id n1 => maxOfNames n1 (Nat.max acc id)
  | Names.nameNil => acc

unsafe def namesOfEnv (env : Env) (acc : Names) : Names :=
  match env with
  | Env.envCons id _ env1 => namesOfEnv env1 (Names.nameCons id acc)
  | Env.envNil => acc

def fresh (n : Names) : Nat :=
  maxOfNames n 0 + 1

unsafe def lookup (env : Env) (id : Nat) : Value :=
  match env with
  | Env.envCons id1 v env1 => if id == id1 then v else lookup env1 id
  | Env.envNil => Value.vVar id

mutual
unsafe def eval (env : Env) (x : Term) : Value :=
  match x with
  | Term.var id => lookup env id
  | Term.app t u => vapp (eval env t) (eval env u)
  | Term.lam x t => Value.vLam x t env
  | Term.letE x t u => eval (Env.envCons x (eval env t) env) u

unsafe def vapp (v1 : Value) (v2 : Value) : Value :=
  match v1 with
  | Value.vLam x body env => eval (Env.envCons x v2 env) body
  | _ => Value.vApp v1 v2
end

unsafe def quote (n : Names) (v : Value) : Term :=
  match v with
  | Value.vVar i => Term.var i
  | Value.vApp v1 v2 => Term.app (quote n v1) (quote n v2)
  | Value.vLam x body env =>
      let y := fresh n
      Term.lam y (quote (Names.nameCons y n) (eval (Env.envCons x (Value.vVar y) env) body))

unsafe def normForm (env : Env) (t : Term) : Term :=
  quote (namesOfEnv env Names.nameNil) (eval env t)

def five : Term :=
  Term.lam 0 (Term.lam 1 (Term.app (Term.var 0) (Term.app (Term.var 0) (Term.app (Term.var 0) (Term.app (Term.var 0) (Term.app (Term.var 0) (Term.var 1)))))))

def add : Term :=
  Term.lam 0 (Term.lam 1 (Term.lam 2 (Term.lam 3 (Term.app (Term.app (Term.var 0) (Term.var 2)) (Term.app (Term.app (Term.var 1) (Term.var 2)) (Term.var 3))))))

def mul : Term :=
  Term.lam 0 (Term.lam 1 (Term.lam 2 (Term.lam 3 (Term.app (Term.app (Term.var 0) (Term.app (Term.var 1) (Term.var 2))) (Term.var 3)))))

def ten : Term :=
  let x := five
  let y := add
  Term.app (Term.app y x) x

def twenty : Term :=
  let x := ten
  let y := add
  Term.app (Term.app y x) x

def hundred : Term :=
  let x := ten
  let y := mul
  Term.app (Term.app y x) x

def twoHundred : Term :=
  let x := hundred
  let y := add
  Term.app (Term.app y x) x

def thousand : Term :=
  let x := hundred
  let z := ten
  let y := mul
  Term.app (Term.app y x) z

def term200000 : Term :=
  let x := twoHundred
  let y := mul
  let z := thousand
  Term.app (Term.app y x) z

def term4000000 : Term :=
  let x := twenty
  let y := mul
  let z := term200000
  Term.app (Term.app y x) z

def nfToInt (t : Term) (acc : Nat) : Nat :=
  match t with
  | Term.lam _ x => nfToInt x acc
  | Term.app _ x => nfToInt x (acc + 1)
  | _ => acc

unsafe def main : IO UInt32 :=
  let t := term4000000
  let n := normForm Env.envNil t
  IO.println (toString (nfToInt n 0)) *>
  pure 0
