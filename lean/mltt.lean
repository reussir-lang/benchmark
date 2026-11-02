import Init.System.IO

import Init.Data.SInt.Basic

set_option maxRecDepth 100000

set_option maxHeartbeats 0

namespace MLTT

mutual

unsafe inductive Term where

  | TVar (f0 : Int64) : Term

  | TU (f0 : Int64) : Term

  | TPi (f0 : Int64) (f1 : Term) (f2 : Term) : Term

  | TLam (f0 : Int64) (f1 : Term) : Term

  | TApp (f0 : Term) (f1 : Term) : Term

  | TLet (f0 : Int64) (f1 : Term) (f2 : Term) (f3 : Term) : Term

  | TAnn (f0 : Term) (f1 : Term) : Term

  | TNat : Term

  | TZero : Term

  | TSuc (f0 : Term) : Term

  | TNatElim (f0 : Term) (f1 : Term) (f2 : Term) (f3 : Term) : Term

  | TId (f0 : Term) (f1 : Term) (f2 : Term) : Term

  | TRefl (f0 : Term) : Term

  | TJ (f0 : Term) (f1 : Term) (f2 : Term) (f3 : Term) (f4 : Term) (f5 : Term) : Term

  | TSigma (f0 : Int64) (f1 : Term) (f2 : Term) : Term

  | TPair (f0 : Term) (f1 : Term) : Term

  | TFst (f0 : Term) : Term

  | TSnd (f0 : Term) : Term

unsafe inductive Closure where

  | MkClosure (f0 : Int64) (f1 : Term) (f2 : Env) : Closure

unsafe inductive Value where

  | VError : Value

  | VU (f0 : Int64) : Value

  | VPi (f0 : Value) (f1 : Closure) : Value

  | VLam (f0 : Closure) : Value

  | VNat : Value

  | VZero : Value

  | VSuc (f0 : Value) : Value

  | VId (f0 : Value) (f1 : Value) (f2 : Value) : Value

  | VRefl (f0 : Value) : Value

  | VSigma (f0 : Value) (f1 : Closure) : Value

  | VPair (f0 : Value) (f1 : Value) : Value

  | VVar (f0 : Int64) : Value

  | VApp (f0 : Value) (f1 : Value) : Value

  | VNatElim (f0 : Value) (f1 : Value) (f2 : Value) (f3 : Value) : Value

  | VJ (f0 : Value) (f1 : Value) (f2 : Value) (f3 : Value) (f4 : Value) (f5 : Value) : Value

  | VFst (f0 : Value) : Value

  | VSnd (f0 : Value) : Value

unsafe inductive Env where

  | ENil : Env

  | EBind (f0 : Int64) (f1 : Value) (f2 : Env) : Env

unsafe inductive Context where

  | MkContext (f0 : Env) (f1 : Env) (f2 : Int64) : Context

unsafe inductive Proof where

  | MkProof (f0 : Term) (f1 : Term) : Proof

end

open Term

open Closure

open Value

open Env

open Context

open Proof

unsafe def get_closure_name (v : Closure) : Int64 := match v with | (MkClosure x0 _ _) => x0

unsafe def get_closure_body (v : Closure) : Term := match v with | (MkClosure _ x1 _) => x1

unsafe def get_closure_env (v : Closure) : Env := match v with | (MkClosure _ _ x2) => x2

unsafe def get_context_env (v : Context) : Env := match v with | (MkContext x0 _ _) => x0

unsafe def get_context_types (v : Context) : Env := match v with | (MkContext _ x1 _) => x1

unsafe def get_context_level (v : Context) : Int64 := match v with | (MkContext _ _ x2) => x2

unsafe def get_proof_ty (v : Proof) : Term := match v with | (MkProof x0 _) => x0

unsafe def get_proof_body (v : Proof) : Term := match v with | (MkProof _ x1) => x1

mutual

unsafe def ml_empty (_unit : Unit) : Env :=
  ENil

unsafe def ml_bind (name : Int64) (value : Value) (env : Env) : Env :=
  (EBind name value env)

unsafe def ml_lookup (env : Env) (name : Int64) : Value :=
  (match env with | ENil => VError | (EBind key value rest) => (if (key == name) then value else (ml_lookup rest name)))

unsafe def ml_extend (context_arg : Context) (name : Int64) (ty : Value) (value : Value) (level : Int64) : Context :=
  (MkContext (ml_bind name value (get_context_env context_arg)) (ml_bind name ty (get_context_types context_arg)) level)

unsafe def ml_fresh (level : Int64) : Value :=
  (VVar level)

unsafe def ml_closure (name : Int64) (body : Term) (env : Env) : Closure :=
  (MkClosure name body env)

unsafe def ml_instantiate (c : Closure) (arg : Value) : Value :=
  (ml_eval (ml_bind (get_closure_name c) arg (get_closure_env c)) (get_closure_body c))

unsafe def ml_apply (arg_fun : Value) (arg : Value) : Value :=
  (match arg_fun with | (VLam c) => (ml_instantiate c arg) | _ => (VApp arg_fun arg))

unsafe def ml_nat_elim (m : Value) (z : Value) (s : Value) (n : Value) : Value :=
  (match n with | VZero => z | (VSuc k) => (ml_apply (ml_apply s k) (ml_nat_elim m z s k)) | _ => (VNatElim m z s n))

unsafe def ml_id_elim (a : Value) (x : Value) (m : Value) (d : Value) (y : Value) (p : Value) : Value :=
  (match p with | (VRefl _) => d | _ => (VJ a x m d y p))

unsafe def ml_first (p : Value) : Value :=
  (match p with | (VPair a _) => a | _ => (VFst p))

unsafe def ml_second (p : Value) : Value :=
  (match p with | (VPair _ b) => b | _ => (VSnd p))

unsafe def ml_eval (env : Env) (term : Term) : Value :=
  (match term with | (TVar i) => (ml_lookup env i) | (TU i) => (VU i) | (TPi i a b) => (VPi (ml_eval env a) (ml_closure i b env)) | (TLam i b) => (VLam (ml_closure i b env)) | (TApp f a) => (ml_apply (ml_eval env f) (ml_eval env a)) | (TLet i _ a b) => (ml_eval (ml_bind i (ml_eval env a) env) b) | (TAnn a _) => (ml_eval env a) | TNat => VNat | TZero => VZero | (TSuc n) => (VSuc (ml_eval env n)) | (TNatElim m z s n) => (ml_nat_elim (ml_eval env m) (ml_eval env z) (ml_eval env s) (ml_eval env n)) | (TId a x y) => (VId (ml_eval env a) (ml_eval env x) (ml_eval env y)) | (TRefl x) => (VRefl (ml_eval env x)) | (TJ a x m d y p) => (ml_id_elim (ml_eval env a) (ml_eval env x) (ml_eval env m) (ml_eval env d) (ml_eval env y) (ml_eval env p)) | (TSigma i a b) => (VSigma (ml_eval env a) (ml_closure i b env)) | (TPair a b) => (VPair (ml_eval env a) (ml_eval env b)) | (TFst p) => (ml_first (ml_eval env p)) | (TSnd p) => (ml_second (ml_eval env p)))

unsafe def ml_conv (level : Int64) (a : Value) (b : Value) : Bool :=
  (match a with | (VU i) => (match b with | (VU j) => (i == j) | _ => false) | (VVar i) => (match b with | (VVar j) => (i == j) | _ => false) | VNat => (match b with | VNat => true | _ => false) | VZero => (match b with | VZero => true | _ => false) | (VPi a c) => (match b with | (VPi b d) => ((ml_conv level a b) && (ml_conv (level + 1) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level)))) | _ => false) | (VSigma a c) => (match b with | (VSigma b d) => ((ml_conv level a b) && (ml_conv (level + 1) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level)))) | _ => false) | (VLam c) => (match b with | (VLam d) => (ml_conv (level + 1) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level))) | _ => false) | (VSuc a) => (match b with | (VSuc b) => (ml_conv level a b) | _ => false) | (VRefl a) => (match b with | (VRefl b) => (ml_conv level a b) | _ => false) | (VFst a) => (match b with | (VFst b) => (ml_conv level a b) | _ => false) | (VSnd a) => (match b with | (VSnd b) => (ml_conv level a b) | _ => false) | (VApp a x) => (match b with | (VApp b y) => ((ml_conv level a b) && (ml_conv level x y)) | _ => false) | (VPair a x) => (match b with | (VPair b y) => ((ml_conv level a b) && (ml_conv level x y)) | _ => false) | (VId a x y) => (match b with | (VId b u v) => (((ml_conv level a b) && (ml_conv level x u)) && (ml_conv level y v)) | _ => false) | (VNatElim m z s n) => (match b with | (VNatElim m2 z2 s2 n2) => ((((ml_conv level m m2) && (ml_conv level z z2)) && (ml_conv level s s2)) && (ml_conv level n n2)) | _ => false) | (VJ a x m d y p) => (match b with | (VJ a2 x2 m2 d2 y2 p2) => ((((((ml_conv level a a2) && (ml_conv level x x2)) && (ml_conv level m m2)) && (ml_conv level d d2)) && (ml_conv level y y2)) && (ml_conv level p p2)) | _ => false) | VError => false)

unsafe def ml_sort (context_arg : Context) (term : Term) : Int64 :=
  (match (ml_infer context_arg term) with | (VU i) => i | _ => (-1))

unsafe def ml_check (context_arg : Context) (term : Term) (ty : Value) : Bool :=
  (match term with | (TLam name body) => (match ty with | (VPi a c) => (let neutral := (ml_fresh (get_context_level context_arg)); (ml_check (ml_extend context_arg name a neutral ((get_context_level context_arg) + 1)) body (ml_instantiate c neutral))) | _ => false) | (TPair a b) => (match ty with | (VSigma domain c) => ((ml_check context_arg a domain) && (ml_check context_arg b (ml_instantiate c (ml_eval (get_context_env context_arg) a)))) | _ => false) | _ => (ml_conv (get_context_level context_arg) (ml_infer context_arg term) ty))

unsafe def ml_nat_step_type (motive : Value) : Value :=
  (let body := (ml_pi (-2) (ml_app (ml_v (-3)) (ml_v (-1))) (ml_app (ml_v (-3)) (ml_suc (ml_v (-1))))); (VPi VNat (ml_closure (-1) body (ml_bind (-3) motive (ml_empty ())))))

unsafe def ml_is_universe (ty : Value) : Bool :=
  (match ty with | (VU _) => true | _ => false)

unsafe def ml_nat_motive_ok (context_arg : Context) (ty : Value) : Bool :=
  (match ty with | (VPi a c) => (match a with | VNat => (ml_is_universe (ml_instantiate c (ml_fresh (get_context_level context_arg)))) | _ => false) | _ => false)

unsafe def ml_id_motive_ok (context_arg : Context) (a : Value) (x : Value) (ty : Value) : Bool :=
  (match ty with | (VPi b c) => (if (ml_conv (get_context_level context_arg) a b) then (let y := (ml_fresh (get_context_level context_arg)); (match (ml_instantiate c y) with | (VPi p d) => ((ml_conv ((get_context_level context_arg) + 1) p (VId a x y)) && (ml_is_universe (ml_instantiate d (ml_fresh ((get_context_level context_arg) + 1))))) | _ => false)) else false) | _ => false)

unsafe def ml_infer_binder (context_arg : Context) (name : Int64) (a : Term) (b : Term) : Value :=
  (let i := (ml_sort context_arg a); (if (i < 0) then VError else (let next := (ml_extend context_arg name (ml_eval (get_context_env context_arg) a) (ml_fresh (get_context_level context_arg)) ((get_context_level context_arg) + 1)); (let j := (ml_sort next b); (if (j < 0) then VError else (VU (if (i > j) then i else j)))))))

unsafe def ml_infer (context_arg : Context) (term : Term) : Value :=
  (match term with | (TVar i) => (ml_lookup (get_context_types context_arg) i) | (TU i) => (if ((i >= 0) && (i < 9223372036854775807)) then (VU (i + 1)) else VError) | (TPi name a b) => (ml_infer_binder context_arg name a b) | (TSigma name a b) => (ml_infer_binder context_arg name a b) | (TApp f x) => (match (ml_infer context_arg f) with | (VPi a c) => (if (ml_check context_arg x a) then (ml_instantiate c (ml_eval (get_context_env context_arg) x)) else VError) | _ => VError) | (TLet name ty rhs body) => (if ((ml_sort context_arg ty) < 0) then VError else (let ty := (ml_eval (get_context_env context_arg) ty); (if (ml_check context_arg rhs ty) then (ml_infer (ml_extend context_arg name ty (ml_eval (get_context_env context_arg) rhs) (get_context_level context_arg)) body) else VError))) | (TAnn body ty) => (if ((ml_sort context_arg ty) < 0) then VError else (let ty := (ml_eval (get_context_env context_arg) ty); (if (ml_check context_arg body ty) then ty else VError))) | TNat => (VU 0) | TZero => VNat | (TSuc n) => (if (ml_check context_arg n VNat) then VNat else VError) | (TNatElim m z s n) => (if ((!(ml_nat_motive_ok context_arg (ml_infer context_arg m))) || (!(ml_check context_arg n VNat))) then VError else (let m := (ml_eval (get_context_env context_arg) m); (if ((ml_check context_arg z (ml_apply m VZero)) && (ml_check context_arg s (ml_nat_step_type m))) then (ml_apply m (ml_eval (get_context_env context_arg) n)) else VError))) | (TId a x y) => (let level := (ml_sort context_arg a); (if (level < 0) then VError else (let a := (ml_eval (get_context_env context_arg) a); (if ((ml_check context_arg x a) && (ml_check context_arg y a)) then (VU level) else VError)))) | (TRefl x) => (let a := (ml_infer context_arg x); (if (ml_is_error a) then VError else (let x := (ml_eval (get_context_env context_arg) x); (VId a x x)))) | (TJ a x m d y p) => (if ((ml_sort context_arg a) < 0) then VError else (let a := (ml_eval (get_context_env context_arg) a); (if ((!(ml_check context_arg x a)) || (!(ml_check context_arg y a))) then VError else (let x := (ml_eval (get_context_env context_arg) x); (let y := (ml_eval (get_context_env context_arg) y); (if ((!(ml_check context_arg p (VId a x y))) || (!(ml_id_motive_ok context_arg a x (ml_infer context_arg m)))) then VError else (let m := (ml_eval (get_context_env context_arg) m); (if (ml_check context_arg d (ml_apply (ml_apply m x) (VRefl x))) then (ml_apply (ml_apply m y) (ml_eval (get_context_env context_arg) p)) else VError)))))))) | (TFst p) => (match (ml_infer context_arg p) with | (VSigma a _) => a | _ => VError) | (TSnd p) => (match (ml_infer context_arg p) with | (VSigma _ c) => (ml_instantiate c (ml_first (ml_eval (get_context_env context_arg) p))) | _ => VError) | _ => VError)

unsafe def ml_v (i : Int64) : Term :=
  (TVar i)

unsafe def ml_u (i : Int64) : Term :=
  (TU i)

unsafe def ml_pi (i : Int64) (a : Term) (b : Term) : Term :=
  (TPi i a b)

unsafe def ml_lam (i : Int64) (body : Term) : Term :=
  (TLam i body)

unsafe def ml_app (f : Term) (a : Term) : Term :=
  (TApp f a)

unsafe def ml_app2 (f : Term) (a : Term) (b : Term) : Term :=
  (ml_app (ml_app f a) b)

unsafe def ml_app3 (f : Term) (a : Term) (b : Term) (c : Term) : Term :=
  (ml_app (ml_app2 f a b) c)

unsafe def ml_let (i : Int64) (ty : Term) (rhs : Term) (body : Term) : Term :=
  (TLet i ty rhs body)

unsafe def ml_ann (body : Term) (ty : Term) : Term :=
  (TAnn body ty)

unsafe def ml_nat (_unit : Unit) : Term :=
  TNat

unsafe def ml_zero (_unit : Unit) : Term :=
  TZero

unsafe def ml_suc (n : Term) : Term :=
  (TSuc n)

unsafe def ml_natelim (m : Term) (z : Term) (s : Term) (n : Term) : Term :=
  (TNatElim m z s n)

unsafe def ml_eq (a : Term) (x : Term) (y : Term) : Term :=
  (TId a x y)

unsafe def ml_refl (x : Term) : Term :=
  (TRefl x)

unsafe def ml_j (a : Term) (x : Term) (m : Term) (d : Term) (y : Term) (p : Term) : Term :=
  (TJ a x m d y p)

unsafe def ml_sigma (i : Int64) (a : Term) (b : Term) : Term :=
  (TSigma i a b)

unsafe def ml_pair (a : Term) (b : Term) : Term :=
  (TPair a b)

unsafe def ml_fst (p : Term) : Term :=
  (TFst p)

unsafe def ml_snd (p : Term) : Term :=
  (TSnd p)

unsafe def ml_is_error (value : Value) : Bool :=
  (match value with | VError => true | _ => false)

unsafe def ml_infer_top (context_arg : Context) (term : Term) : Value :=
  (ml_infer context_arg term)

unsafe def ml_numeral (n : Int64) : Term :=
  (if (n == 0) then (ml_zero ()) else (ml_suc (ml_numeral (n - 1))))

unsafe def ml_add (x : Term) (y : Term) : Term :=
  (ml_app2 (ml_v 100) x y)

unsafe def ml_cong (x : Term) (y : Term) (p : Term) : Term :=
  (ml_app3 (ml_v 101) x y p)

unsafe def ml_trans (x : Term) (y : Term) (z : Term) (p : Term) (q : Term) : Term :=
  (ml_app2 (ml_app3 (ml_app (ml_v 105) (ml_nat ())) x y z) p q)

unsafe def ml_add_type (_unit : Unit) : Term :=
  (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_nat ()) (ml_nat ())))

unsafe def ml_add_body (_unit : Unit) : Term :=
  (ml_lam 0 (ml_lam 1 (ml_natelim (ml_ann (ml_lam 2 (ml_nat ())) (ml_pi 2 (ml_nat ()) (ml_u 0))) (ml_v 1) (ml_lam 3 (ml_lam 4 (ml_suc (ml_v 4)))) (ml_v 0))))

unsafe def ml_cong_type (_unit : Unit) : Term :=
  (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_nat ()) (ml_pi 2 (ml_eq (ml_nat ()) (ml_v 0) (ml_v 1)) (ml_eq (ml_nat ()) (ml_suc (ml_v 0)) (ml_suc (ml_v 1))))))

unsafe def ml_cong_body (_unit : Unit) : Term :=
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_j (ml_nat ()) (ml_v 0) (ml_ann (ml_lam 3 (ml_lam 4 (ml_eq (ml_nat ()) (ml_suc (ml_v 0)) (ml_suc (ml_v 3))))) (ml_pi 3 (ml_nat ()) (ml_pi 4 (ml_eq (ml_nat ()) (ml_v 0) (ml_v 3)) (ml_u 0)))) (ml_refl (ml_suc (ml_v 0))) (ml_v 1) (ml_v 2)))))

unsafe def ml_right_type (_unit : Unit) : Term :=
  (ml_pi 0 (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_v 0) (ml_zero ())) (ml_v 0)))

unsafe def ml_right_body (_unit : Unit) : Term :=
  (ml_lam 0 (ml_natelim (ml_ann (ml_lam 1 (ml_eq (ml_nat ()) (ml_add (ml_v 1) (ml_zero ())) (ml_v 1))) (ml_pi 1 (ml_nat ()) (ml_u 0))) (ml_refl (ml_zero ())) (ml_lam 2 (ml_lam 3 (ml_cong (ml_add (ml_v 2) (ml_zero ())) (ml_v 2) (ml_v 3)))) (ml_v 0)))

unsafe def ml_assoc_type (_unit : Unit) : Term :=
  (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_nat ()) (ml_pi 2 (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_add (ml_v 0) (ml_v 1)) (ml_v 2)) (ml_add (ml_v 0) (ml_add (ml_v 1) (ml_v 2)))))))

unsafe def ml_assoc_body (_unit : Unit) : Term :=
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_natelim (ml_ann (ml_lam 3 (ml_eq (ml_nat ()) (ml_add (ml_add (ml_v 3) (ml_v 1)) (ml_v 2)) (ml_add (ml_v 3) (ml_add (ml_v 1) (ml_v 2))))) (ml_pi 3 (ml_nat ()) (ml_u 0))) (ml_refl (ml_add (ml_v 1) (ml_v 2))) (ml_lam 4 (ml_lam 5 (ml_cong (ml_add (ml_add (ml_v 4) (ml_v 1)) (ml_v 2)) (ml_add (ml_v 4) (ml_add (ml_v 1) (ml_v 2))) (ml_v 5)))) (ml_v 0)))))

unsafe def ml_sym_type (_unit : Unit) : Term :=
  (ml_pi 0 (ml_u 0) (ml_pi 1 (ml_v 0) (ml_pi 2 (ml_v 0) (ml_pi 3 (ml_eq (ml_v 0) (ml_v 1) (ml_v 2)) (ml_eq (ml_v 0) (ml_v 2) (ml_v 1))))))

unsafe def ml_sym_body (_unit : Unit) : Term :=
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_lam 3 (ml_j (ml_v 0) (ml_v 1) (ml_ann (ml_lam 4 (ml_lam 5 (ml_eq (ml_v 0) (ml_v 4) (ml_v 1)))) (ml_pi 4 (ml_v 0) (ml_pi 5 (ml_eq (ml_v 0) (ml_v 1) (ml_v 4)) (ml_u 0)))) (ml_refl (ml_v 1)) (ml_v 2) (ml_v 3))))))

unsafe def ml_trans_type (_unit : Unit) : Term :=
  (ml_pi 0 (ml_u 0) (ml_pi 1 (ml_v 0) (ml_pi 2 (ml_v 0) (ml_pi 3 (ml_v 0) (ml_pi 4 (ml_eq (ml_v 0) (ml_v 1) (ml_v 2)) (ml_pi 5 (ml_eq (ml_v 0) (ml_v 2) (ml_v 3)) (ml_eq (ml_v 0) (ml_v 1) (ml_v 3))))))))

unsafe def ml_trans_body (_unit : Unit) : Term :=
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_lam 3 (ml_lam 4 (ml_lam 5 (ml_j (ml_v 0) (ml_v 2) (ml_ann (ml_lam 6 (ml_lam 7 (ml_eq (ml_v 0) (ml_v 1) (ml_v 6)))) (ml_pi 6 (ml_v 0) (ml_pi 7 (ml_eq (ml_v 0) (ml_v 2) (ml_v 6)) (ml_u 0)))) (ml_v 4) (ml_v 3) (ml_v 5))))))))

unsafe def ml_bundle (body : Term) : Term :=
  (ml_let 100 (ml_add_type ()) (ml_add_body ()) (ml_let 101 (ml_cong_type ()) (ml_cong_body ()) (ml_let 102 (ml_right_type ()) (ml_right_body ()) (ml_let 103 (ml_assoc_type ()) (ml_assoc_body ()) (ml_let 104 (ml_sym_type ()) (ml_sym_body ()) (ml_let 105 (ml_trans_type ()) (ml_trans_body ()) body))))))

unsafe def ml_chain_end (i : Int64) : Term :=
  (if ((i % 2) == 0) then (ml_v 1000) else (ml_add (ml_v 1000) (ml_zero ())))

unsafe def ml_chain_lets (i : Int64) (rest : Term) (bad : Bool) : Term :=
  (if (i == 0) then (ml_let 2000 (ml_eq (ml_nat ()) (ml_add (ml_v 1000) (ml_zero ())) (ml_v 1000)) (ml_app (ml_v 102) (ml_v 1000)) rest) else (let evidence := (if (bad && (i == 1)) then (ml_refl (ml_zero ())) else (if ((i % 2) == 1) then (ml_app (ml_v 104) (ml_nat ())) else (ml_v 102))); (let q := (if (bad && (i == 1)) then evidence else (if ((i % 2) == 1) then (ml_app3 evidence (ml_add (ml_v 1000) (ml_zero ())) (ml_v 1000) (ml_v 2000)) else (ml_app evidence (ml_v 1000)))); (ml_chain_lets (i - 1) (ml_let (2000 + i) (ml_eq (ml_nat ()) (ml_add (ml_v 1000) (ml_zero ())) (ml_chain_end i)) (ml_trans (ml_add (ml_v 1000) (ml_zero ())) (ml_chain_end (i - 1)) (ml_chain_end i) (ml_v (1999 + i)) q) rest) bad))))

unsafe def ml_workload (case_id : Int64) (size : Int64) (bad : Bool) : Proof :=
  (if (case_id == 0) then (let result := (ml_eq (ml_nat ()) (ml_add (ml_add (ml_numeral size) (ml_v 1000)) (ml_v 1001)) (ml_add (ml_numeral size) (ml_add (ml_v 1000) (ml_v 1001)))); (MkProof (ml_pi 1000 (ml_nat ()) (ml_pi 1001 (ml_nat ()) result)) (ml_lam 1000 (ml_lam 1001 (ml_app3 (ml_v 103) (ml_numeral size) (ml_v 1000) (if bad then (ml_suc (ml_v 1001)) else (ml_v 1001))))))) else (if (case_id == 1) then (MkProof (ml_pi 1000 (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_v 1000) (ml_zero ())) (ml_chain_end size))) (ml_lam 1000 (ml_chain_lets size (ml_v (2000 + size)) bad))) else (let witness := (ml_add (ml_numeral size) (ml_numeral size)); (MkProof (ml_sigma 1000 (ml_nat ()) (ml_eq (ml_nat ()) (ml_v 1000) (ml_numeral (size * 2)))) (ml_pair witness (ml_refl (ml_numeral ((size * 2) + (if bad then 1 else 0)))))))))

unsafe def ml_checked (term : Term) : Bool :=
  (let context_arg := (MkContext (ml_empty ()) (ml_empty ()) 0); (!(ml_is_error (ml_infer_top context_arg term))))

unsafe def ml_check_case (case_id : Int64) (size : Int64) (bad : Bool) : Int64 :=
  (let proof := (ml_workload case_id size bad); (if (ml_checked (ml_bundle (ml_ann (get_proof_body proof) (get_proof_ty proof)))) then 1 else 0))

unsafe def ml_regressions (_unit : Unit) : Int64 :=
  (let good_pair := (ml_ann (ml_pair (ml_zero ()) (ml_refl (ml_zero ()))) (ml_sigma 0 (ml_nat ()) (ml_eq (ml_nat ()) (ml_v 0) (ml_v 0)))); (let a := (ml_checked (ml_ann (ml_u 0) (ml_u 1))); (let b := (!(ml_checked (ml_ann (ml_u 0) (ml_u 0)))); (let c := (!(ml_checked (ml_ann (ml_v 7) (ml_nat ())))); (let d := (!(ml_checked (ml_let 0 (ml_nat ()) (ml_u 0) (ml_zero ())))); (let e := (!(ml_checked (ml_ann (ml_app (ml_ann (ml_lam 0 (ml_zero ())) (ml_pi 0 (ml_nat ()) (ml_nat ()))) (ml_u 0)) (ml_nat ())))); (let f := (ml_checked (ml_ann (ml_fst good_pair) (ml_nat ()))); (let g := (ml_checked (ml_ann (ml_snd good_pair) (ml_eq (ml_nat ()) (ml_zero ()) (ml_zero ())))); (let h := (!(ml_checked (ml_ann (ml_refl (ml_zero ())) (ml_eq (ml_nat ()) (ml_zero ()) (ml_suc (ml_zero ())))))); (let i := (!(ml_checked (ml_natelim (ml_ann (ml_lam 0 (ml_nat ())) (ml_pi 0 (ml_nat ()) (ml_u 0))) (ml_zero ()) (ml_lam 0 (ml_lam 1 (ml_u 0))) (ml_zero ())))); (let k := (!(ml_checked (ml_j (ml_nat ()) (ml_zero ()) (ml_ann (ml_lam 0 (ml_lam 1 (ml_nat ()))) (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_eq (ml_nat ()) (ml_zero ()) (ml_v 0)) (ml_u 0)))) (ml_zero ()) (ml_suc (ml_zero ())) (ml_refl (ml_zero ()))))); (if (((((((((a && b) && c) && d) && e) && f) && g) && h) && i) && k) then 10 else 0))))))))))))

end

end MLTT

open MLTT

unsafe def main : IO UInt32 := do
  let result : Int64 := (((((((ml_regressions ()) + (ml_check_case 0 4096 false)) + (ml_check_case 1 4096 false)) + (ml_check_case 2 4096 false)) + (1 - (ml_check_case 0 4096 true))) + (1 - (ml_check_case 1 4096 true))) + (1 - (ml_check_case 2 4096 true)))
  if result != 16 then throw (IO.userError "MLTT check failed")
  IO.println result
  return 0
