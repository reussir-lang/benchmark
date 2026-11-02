(* MLTT: the same explicit checker and proof bundles as reussir/mltt.rr. *)

type term =

  | TVar of int64

  | TU of int64

  | TPi of int64 * term * term

  | TLam of int64 * term

  | TApp of term * term

  | TLet of int64 * term * term * term

  | TAnn of term * term

  | TNat

  | TZero

  | TSuc of term

  | TNatElim of term * term * term * term

  | TId of term * term * term

  | TRefl of term

  | TJ of term * term * term * term * term * term

  | TSigma of int64 * term * term

  | TPair of term * term

  | TFst of term

  | TSnd of term

and closure =

  | MkClosure of int64 * term * env

and value =

  | VError

  | VU of int64

  | VPi of value * closure

  | VLam of closure

  | VNat

  | VZero

  | VSuc of value

  | VId of value * value * value

  | VRefl of value

  | VSigma of value * closure

  | VPair of value * value

  | VVar of int64

  | VApp of value * value

  | VNatElim of value * value * value * value

  | VJ of value * value * value * value * value * value

  | VFst of value

  | VSnd of value

and env =

  | ENil

  | EBind of int64 * value * env

and context =

  | MkContext of env * env * int64

and proof =

  | MkProof of term * term

let get_closure_name (MkClosure (x0, _, _)) = x0

let get_closure_body (MkClosure (_, x1, _)) = x1

let get_closure_env (MkClosure (_, _, x2)) = x2

let get_context_env (MkContext (x0, _, _)) = x0

let get_context_types (MkContext (_, x1, _)) = x1

let get_context_level (MkContext (_, _, x2)) = x2

let get_proof_ty (MkProof (x0, _)) = x0

let get_proof_body (MkProof (_, x1)) = x1

let rec ml_empty () : env =
  ENil

and ml_bind (name: int64) (value: value) (env: env) : env =
  (EBind (name, value, env))

and ml_lookup (env: env) (name: int64) : value =
  (match env with | ENil -> VError | (EBind (key, value, rest)) -> (if (key = name) then value else (ml_lookup rest name)))

and ml_extend (context_arg: context) (name: int64) (ty: value) (value: value) (level: int64) : context =
  (MkContext ((ml_bind name value (get_context_env context_arg)), (ml_bind name ty (get_context_types context_arg)), level))

and ml_fresh (level: int64) : value =
  (VVar level)

and ml_closure (name: int64) (body: term) (env: env) : closure =
  (MkClosure (name, body, env))

and ml_instantiate (c: closure) (arg: value) : value =
  (ml_eval (ml_bind (get_closure_name c) arg (get_closure_env c)) (get_closure_body c))

and ml_apply (arg_fun: value) (arg: value) : value =
  (match arg_fun with | (VLam c) -> (ml_instantiate c arg) | _ -> (VApp (arg_fun, arg)))

and ml_nat_elim (m: value) (z: value) (s: value) (n: value) : value =
  (match n with | VZero -> z | (VSuc k) -> (ml_apply (ml_apply s k) (ml_nat_elim m z s k)) | _ -> (VNatElim (m, z, s, n)))

and ml_id_elim (a: value) (x: value) (m: value) (d: value) (y: value) (p: value) : value =
  (match p with | (VRefl _) -> d | _ -> (VJ (a, x, m, d, y, p)))

and ml_first (p: value) : value =
  (match p with | (VPair (a, _)) -> a | _ -> (VFst p))

and ml_second (p: value) : value =
  (match p with | (VPair (_, b)) -> b | _ -> (VSnd p))

and ml_eval (env: env) (term: term) : value =
  (match term with | (TVar i) -> (ml_lookup env i) | (TU i) -> (VU i) | (TPi (i, a, b)) -> (VPi ((ml_eval env a), (ml_closure i b env))) | (TLam (i, b)) -> (VLam (ml_closure i b env)) | (TApp (f, a)) -> (ml_apply (ml_eval env f) (ml_eval env a)) | (TLet (i, _, a, b)) -> (ml_eval (ml_bind i (ml_eval env a) env) b) | (TAnn (a, _)) -> (ml_eval env a) | TNat -> VNat | TZero -> VZero | (TSuc n) -> (VSuc (ml_eval env n)) | (TNatElim (m, z, s, n)) -> (ml_nat_elim (ml_eval env m) (ml_eval env z) (ml_eval env s) (ml_eval env n)) | (TId (a, x, y)) -> (VId ((ml_eval env a), (ml_eval env x), (ml_eval env y))) | (TRefl x) -> (VRefl (ml_eval env x)) | (TJ (a, x, m, d, y, p)) -> (ml_id_elim (ml_eval env a) (ml_eval env x) (ml_eval env m) (ml_eval env d) (ml_eval env y) (ml_eval env p)) | (TSigma (i, a, b)) -> (VSigma ((ml_eval env a), (ml_closure i b env))) | (TPair (a, b)) -> (VPair ((ml_eval env a), (ml_eval env b))) | (TFst p) -> (ml_first (ml_eval env p)) | (TSnd p) -> (ml_second (ml_eval env p)))

and ml_conv (level: int64) (a: value) (b: value) : bool =
  (match a with | (VU i) -> (match b with | (VU j) -> (i = j) | _ -> false) | (VVar i) -> (match b with | (VVar j) -> (i = j) | _ -> false) | VNat -> (match b with | VNat -> true | _ -> false) | VZero -> (match b with | VZero -> true | _ -> false) | (VPi (a, c)) -> (match b with | (VPi (b, d)) -> ((ml_conv level a b) && (ml_conv (Int64.add level 1L) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level)))) | _ -> false) | (VSigma (a, c)) -> (match b with | (VSigma (b, d)) -> ((ml_conv level a b) && (ml_conv (Int64.add level 1L) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level)))) | _ -> false) | (VLam c) -> (match b with | (VLam d) -> (ml_conv (Int64.add level 1L) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level))) | _ -> false) | (VSuc a) -> (match b with | (VSuc b) -> (ml_conv level a b) | _ -> false) | (VRefl a) -> (match b with | (VRefl b) -> (ml_conv level a b) | _ -> false) | (VFst a) -> (match b with | (VFst b) -> (ml_conv level a b) | _ -> false) | (VSnd a) -> (match b with | (VSnd b) -> (ml_conv level a b) | _ -> false) | (VApp (a, x)) -> (match b with | (VApp (b, y)) -> ((ml_conv level a b) && (ml_conv level x y)) | _ -> false) | (VPair (a, x)) -> (match b with | (VPair (b, y)) -> ((ml_conv level a b) && (ml_conv level x y)) | _ -> false) | (VId (a, x, y)) -> (match b with | (VId (b, u, v)) -> (((ml_conv level a b) && (ml_conv level x u)) && (ml_conv level y v)) | _ -> false) | (VNatElim (m, z, s, n)) -> (match b with | (VNatElim (m2, z2, s2, n2)) -> ((((ml_conv level m m2) && (ml_conv level z z2)) && (ml_conv level s s2)) && (ml_conv level n n2)) | _ -> false) | (VJ (a, x, m, d, y, p)) -> (match b with | (VJ (a2, x2, m2, d2, y2, p2)) -> ((((((ml_conv level a a2) && (ml_conv level x x2)) && (ml_conv level m m2)) && (ml_conv level d d2)) && (ml_conv level y y2)) && (ml_conv level p p2)) | _ -> false) | VError -> false)

and ml_sort (context_arg: context) (term: term) : int64 =
  (match (ml_infer context_arg term) with | (VU i) -> i | _ -> (Int64.neg 1L))

and ml_check (context_arg: context) (term: term) (ty: value) : bool =
  (match term with | (TLam (name, body)) -> (match ty with | (VPi (a, c)) -> (let neutral = (ml_fresh (get_context_level context_arg)) in (ml_check (ml_extend context_arg name a neutral (Int64.add (get_context_level context_arg) 1L)) body (ml_instantiate c neutral))) | _ -> false) | (TPair (a, b)) -> (match ty with | (VSigma (domain, c)) -> ((ml_check context_arg a domain) && (ml_check context_arg b (ml_instantiate c (ml_eval (get_context_env context_arg) a)))) | _ -> false) | _ -> (ml_conv (get_context_level context_arg) (ml_infer context_arg term) ty))

and ml_nat_step_type (motive: value) : value =
  (let body = (ml_pi (Int64.neg 2L) (ml_app (ml_v (Int64.neg 3L)) (ml_v (Int64.neg 1L))) (ml_app (ml_v (Int64.neg 3L)) (ml_suc (ml_v (Int64.neg 1L))))) in (VPi (VNat, (ml_closure (Int64.neg 1L) body (ml_bind (Int64.neg 3L) motive (ml_empty ()))))))

and ml_is_universe (ty: value) : bool =
  (match ty with | (VU _) -> true | _ -> false)

and ml_nat_motive_ok (context_arg: context) (ty: value) : bool =
  (match ty with | (VPi (a, c)) -> (match a with | VNat -> (ml_is_universe (ml_instantiate c (ml_fresh (get_context_level context_arg)))) | _ -> false) | _ -> false)

and ml_id_motive_ok (context_arg: context) (a: value) (x: value) (ty: value) : bool =
  (match ty with | (VPi (b, c)) -> (if (ml_conv (get_context_level context_arg) a b) then (let y = (ml_fresh (get_context_level context_arg)) in (match (ml_instantiate c y) with | (VPi (p, d)) -> ((ml_conv (Int64.add (get_context_level context_arg) 1L) p (VId (a, x, y))) && (ml_is_universe (ml_instantiate d (ml_fresh (Int64.add (get_context_level context_arg) 1L))))) | _ -> false)) else false) | _ -> false)

and ml_infer_binder (context_arg: context) (name: int64) (a: term) (b: term) : value =
  (let i = (ml_sort context_arg a) in (if (i < 0L) then VError else (let next = (ml_extend context_arg name (ml_eval (get_context_env context_arg) a) (ml_fresh (get_context_level context_arg)) (Int64.add (get_context_level context_arg) 1L)) in (let j = (ml_sort next b) in (if (j < 0L) then VError else (VU (if (i > j) then i else j)))))))

and ml_infer (context_arg: context) (term: term) : value =
  (match term with | (TVar i) -> (ml_lookup (get_context_types context_arg) i) | (TU i) -> (if ((i >= 0L) && (i < 9223372036854775807L)) then (VU (Int64.add i 1L)) else VError) | (TPi (name, a, b)) -> (ml_infer_binder context_arg name a b) | (TSigma (name, a, b)) -> (ml_infer_binder context_arg name a b) | (TApp (f, x)) -> (match (ml_infer context_arg f) with | (VPi (a, c)) -> (if (ml_check context_arg x a) then (ml_instantiate c (ml_eval (get_context_env context_arg) x)) else VError) | _ -> VError) | (TLet (name, ty, rhs, body)) -> (if ((ml_sort context_arg ty) < 0L) then VError else (let ty = (ml_eval (get_context_env context_arg) ty) in (if (ml_check context_arg rhs ty) then (ml_infer (ml_extend context_arg name ty (ml_eval (get_context_env context_arg) rhs) (get_context_level context_arg)) body) else VError))) | (TAnn (body, ty)) -> (if ((ml_sort context_arg ty) < 0L) then VError else (let ty = (ml_eval (get_context_env context_arg) ty) in (if (ml_check context_arg body ty) then ty else VError))) | TNat -> (VU 0L) | TZero -> VNat | (TSuc n) -> (if (ml_check context_arg n VNat) then VNat else VError) | (TNatElim (m, z, s, n)) -> (if ((not (ml_nat_motive_ok context_arg (ml_infer context_arg m))) || (not (ml_check context_arg n VNat))) then VError else (let m = (ml_eval (get_context_env context_arg) m) in (if ((ml_check context_arg z (ml_apply m VZero)) && (ml_check context_arg s (ml_nat_step_type m))) then (ml_apply m (ml_eval (get_context_env context_arg) n)) else VError))) | (TId (a, x, y)) -> (let level = (ml_sort context_arg a) in (if (level < 0L) then VError else (let a = (ml_eval (get_context_env context_arg) a) in (if ((ml_check context_arg x a) && (ml_check context_arg y a)) then (VU level) else VError)))) | (TRefl x) -> (let a = (ml_infer context_arg x) in (if (ml_is_error a) then VError else (let x = (ml_eval (get_context_env context_arg) x) in (VId (a, x, x))))) | (TJ (a, x, m, d, y, p)) -> (if ((ml_sort context_arg a) < 0L) then VError else (let a = (ml_eval (get_context_env context_arg) a) in (if ((not (ml_check context_arg x a)) || (not (ml_check context_arg y a))) then VError else (let x = (ml_eval (get_context_env context_arg) x) in (let y = (ml_eval (get_context_env context_arg) y) in (if ((not (ml_check context_arg p (VId (a, x, y)))) || (not (ml_id_motive_ok context_arg a x (ml_infer context_arg m)))) then VError else (let m = (ml_eval (get_context_env context_arg) m) in (if (ml_check context_arg d (ml_apply (ml_apply m x) (VRefl x))) then (ml_apply (ml_apply m y) (ml_eval (get_context_env context_arg) p)) else VError)))))))) | (TFst p) -> (match (ml_infer context_arg p) with | (VSigma (a, _)) -> a | _ -> VError) | (TSnd p) -> (match (ml_infer context_arg p) with | (VSigma (_, c)) -> (ml_instantiate c (ml_first (ml_eval (get_context_env context_arg) p))) | _ -> VError) | _ -> VError)

and ml_v (i: int64) : term =
  (TVar i)

and ml_u (i: int64) : term =
  (TU i)

and ml_pi (i: int64) (a: term) (b: term) : term =
  (TPi (i, a, b))

and ml_lam (i: int64) (body: term) : term =
  (TLam (i, body))

and ml_app (f: term) (a: term) : term =
  (TApp (f, a))

and ml_app2 (f: term) (a: term) (b: term) : term =
  (ml_app (ml_app f a) b)

and ml_app3 (f: term) (a: term) (b: term) (c: term) : term =
  (ml_app (ml_app2 f a b) c)

and ml_let (i: int64) (ty: term) (rhs: term) (body: term) : term =
  (TLet (i, ty, rhs, body))

and ml_ann (body: term) (ty: term) : term =
  (TAnn (body, ty))

and ml_nat () : term =
  TNat

and ml_zero () : term =
  TZero

and ml_suc (n: term) : term =
  (TSuc n)

and ml_natelim (m: term) (z: term) (s: term) (n: term) : term =
  (TNatElim (m, z, s, n))

and ml_eq (a: term) (x: term) (y: term) : term =
  (TId (a, x, y))

and ml_refl (x: term) : term =
  (TRefl x)

and ml_j (a: term) (x: term) (m: term) (d: term) (y: term) (p: term) : term =
  (TJ (a, x, m, d, y, p))

and ml_sigma (i: int64) (a: term) (b: term) : term =
  (TSigma (i, a, b))

and ml_pair (a: term) (b: term) : term =
  (TPair (a, b))

and ml_fst (p: term) : term =
  (TFst p)

and ml_snd (p: term) : term =
  (TSnd p)

and ml_is_error (value: value) : bool =
  (match value with | VError -> true | _ -> false)

and ml_infer_top (context_arg: context) (term: term) : value =
  (ml_infer context_arg term)

and ml_numeral (n: int64) : term =
  (if (n = 0L) then (ml_zero ()) else (ml_suc (ml_numeral (Int64.sub n 1L))))

and ml_add (x: term) (y: term) : term =
  (ml_app2 (ml_v 100L) x y)

and ml_cong (x: term) (y: term) (p: term) : term =
  (ml_app3 (ml_v 101L) x y p)

and ml_trans (x: term) (y: term) (z: term) (p: term) (q: term) : term =
  (ml_app2 (ml_app3 (ml_app (ml_v 105L) (ml_nat ())) x y z) p q)

and ml_add_type () : term =
  (ml_pi 0L (ml_nat ()) (ml_pi 1L (ml_nat ()) (ml_nat ())))

and ml_add_body () : term =
  (ml_lam 0L (ml_lam 1L (ml_natelim (ml_ann (ml_lam 2L (ml_nat ())) (ml_pi 2L (ml_nat ()) (ml_u 0L))) (ml_v 1L) (ml_lam 3L (ml_lam 4L (ml_suc (ml_v 4L)))) (ml_v 0L))))

and ml_cong_type () : term =
  (ml_pi 0L (ml_nat ()) (ml_pi 1L (ml_nat ()) (ml_pi 2L (ml_eq (ml_nat ()) (ml_v 0L) (ml_v 1L)) (ml_eq (ml_nat ()) (ml_suc (ml_v 0L)) (ml_suc (ml_v 1L))))))

and ml_cong_body () : term =
  (ml_lam 0L (ml_lam 1L (ml_lam 2L (ml_j (ml_nat ()) (ml_v 0L) (ml_ann (ml_lam 3L (ml_lam 4L (ml_eq (ml_nat ()) (ml_suc (ml_v 0L)) (ml_suc (ml_v 3L))))) (ml_pi 3L (ml_nat ()) (ml_pi 4L (ml_eq (ml_nat ()) (ml_v 0L) (ml_v 3L)) (ml_u 0L)))) (ml_refl (ml_suc (ml_v 0L))) (ml_v 1L) (ml_v 2L)))))

and ml_right_type () : term =
  (ml_pi 0L (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_v 0L) (ml_zero ())) (ml_v 0L)))

and ml_right_body () : term =
  (ml_lam 0L (ml_natelim (ml_ann (ml_lam 1L (ml_eq (ml_nat ()) (ml_add (ml_v 1L) (ml_zero ())) (ml_v 1L))) (ml_pi 1L (ml_nat ()) (ml_u 0L))) (ml_refl (ml_zero ())) (ml_lam 2L (ml_lam 3L (ml_cong (ml_add (ml_v 2L) (ml_zero ())) (ml_v 2L) (ml_v 3L)))) (ml_v 0L)))

and ml_assoc_type () : term =
  (ml_pi 0L (ml_nat ()) (ml_pi 1L (ml_nat ()) (ml_pi 2L (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_add (ml_v 0L) (ml_v 1L)) (ml_v 2L)) (ml_add (ml_v 0L) (ml_add (ml_v 1L) (ml_v 2L)))))))

and ml_assoc_body () : term =
  (ml_lam 0L (ml_lam 1L (ml_lam 2L (ml_natelim (ml_ann (ml_lam 3L (ml_eq (ml_nat ()) (ml_add (ml_add (ml_v 3L) (ml_v 1L)) (ml_v 2L)) (ml_add (ml_v 3L) (ml_add (ml_v 1L) (ml_v 2L))))) (ml_pi 3L (ml_nat ()) (ml_u 0L))) (ml_refl (ml_add (ml_v 1L) (ml_v 2L))) (ml_lam 4L (ml_lam 5L (ml_cong (ml_add (ml_add (ml_v 4L) (ml_v 1L)) (ml_v 2L)) (ml_add (ml_v 4L) (ml_add (ml_v 1L) (ml_v 2L))) (ml_v 5L)))) (ml_v 0L)))))

and ml_sym_type () : term =
  (ml_pi 0L (ml_u 0L) (ml_pi 1L (ml_v 0L) (ml_pi 2L (ml_v 0L) (ml_pi 3L (ml_eq (ml_v 0L) (ml_v 1L) (ml_v 2L)) (ml_eq (ml_v 0L) (ml_v 2L) (ml_v 1L))))))

and ml_sym_body () : term =
  (ml_lam 0L (ml_lam 1L (ml_lam 2L (ml_lam 3L (ml_j (ml_v 0L) (ml_v 1L) (ml_ann (ml_lam 4L (ml_lam 5L (ml_eq (ml_v 0L) (ml_v 4L) (ml_v 1L)))) (ml_pi 4L (ml_v 0L) (ml_pi 5L (ml_eq (ml_v 0L) (ml_v 1L) (ml_v 4L)) (ml_u 0L)))) (ml_refl (ml_v 1L)) (ml_v 2L) (ml_v 3L))))))

and ml_trans_type () : term =
  (ml_pi 0L (ml_u 0L) (ml_pi 1L (ml_v 0L) (ml_pi 2L (ml_v 0L) (ml_pi 3L (ml_v 0L) (ml_pi 4L (ml_eq (ml_v 0L) (ml_v 1L) (ml_v 2L)) (ml_pi 5L (ml_eq (ml_v 0L) (ml_v 2L) (ml_v 3L)) (ml_eq (ml_v 0L) (ml_v 1L) (ml_v 3L))))))))

and ml_trans_body () : term =
  (ml_lam 0L (ml_lam 1L (ml_lam 2L (ml_lam 3L (ml_lam 4L (ml_lam 5L (ml_j (ml_v 0L) (ml_v 2L) (ml_ann (ml_lam 6L (ml_lam 7L (ml_eq (ml_v 0L) (ml_v 1L) (ml_v 6L)))) (ml_pi 6L (ml_v 0L) (ml_pi 7L (ml_eq (ml_v 0L) (ml_v 2L) (ml_v 6L)) (ml_u 0L)))) (ml_v 4L) (ml_v 3L) (ml_v 5L))))))))

and ml_bundle (body: term) : term =
  (ml_let 100L (ml_add_type ()) (ml_add_body ()) (ml_let 101L (ml_cong_type ()) (ml_cong_body ()) (ml_let 102L (ml_right_type ()) (ml_right_body ()) (ml_let 103L (ml_assoc_type ()) (ml_assoc_body ()) (ml_let 104L (ml_sym_type ()) (ml_sym_body ()) (ml_let 105L (ml_trans_type ()) (ml_trans_body ()) body))))))

and ml_chain_end (i: int64) : term =
  (if ((Int64.rem i 2L) = 0L) then (ml_v 1000L) else (ml_add (ml_v 1000L) (ml_zero ())))

and ml_chain_lets (i: int64) (rest: term) (bad: bool) : term =
  (if (i = 0L) then (ml_let 2000L (ml_eq (ml_nat ()) (ml_add (ml_v 1000L) (ml_zero ())) (ml_v 1000L)) (ml_app (ml_v 102L) (ml_v 1000L)) rest) else (let evidence = (if (bad && (i = 1L)) then (ml_refl (ml_zero ())) else (if ((Int64.rem i 2L) = 1L) then (ml_app (ml_v 104L) (ml_nat ())) else (ml_v 102L))) in (let q = (if (bad && (i = 1L)) then evidence else (if ((Int64.rem i 2L) = 1L) then (ml_app3 evidence (ml_add (ml_v 1000L) (ml_zero ())) (ml_v 1000L) (ml_v 2000L)) else (ml_app evidence (ml_v 1000L)))) in (ml_chain_lets (Int64.sub i 1L) (ml_let (Int64.add 2000L i) (ml_eq (ml_nat ()) (ml_add (ml_v 1000L) (ml_zero ())) (ml_chain_end i)) (ml_trans (ml_add (ml_v 1000L) (ml_zero ())) (ml_chain_end (Int64.sub i 1L)) (ml_chain_end i) (ml_v (Int64.add 1999L i)) q) rest) bad))))

and ml_workload (case_id: int64) (size: int64) (bad: bool) : proof =
  (if (case_id = 0L) then (let result = (ml_eq (ml_nat ()) (ml_add (ml_add (ml_numeral size) (ml_v 1000L)) (ml_v 1001L)) (ml_add (ml_numeral size) (ml_add (ml_v 1000L) (ml_v 1001L)))) in (MkProof ((ml_pi 1000L (ml_nat ()) (ml_pi 1001L (ml_nat ()) result)), (ml_lam 1000L (ml_lam 1001L (ml_app3 (ml_v 103L) (ml_numeral size) (ml_v 1000L) (if bad then (ml_suc (ml_v 1001L)) else (ml_v 1001L)))))))) else (if (case_id = 1L) then (MkProof ((ml_pi 1000L (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_v 1000L) (ml_zero ())) (ml_chain_end size))), (ml_lam 1000L (ml_chain_lets size (ml_v (Int64.add 2000L size)) bad)))) else (let witness = (ml_add (ml_numeral size) (ml_numeral size)) in (MkProof ((ml_sigma 1000L (ml_nat ()) (ml_eq (ml_nat ()) (ml_v 1000L) (ml_numeral (Int64.mul size 2L)))), (ml_pair witness (ml_refl (ml_numeral (Int64.add (Int64.mul size 2L) (if bad then 1L else 0L))))))))))

and ml_checked (term: term) : bool =
  (let context_arg = (MkContext ((ml_empty ()), (ml_empty ()), 0L)) in (not (ml_is_error (ml_infer_top context_arg term))))

and ml_check_case (case_id: int64) (size: int64) (bad: bool) : int64 =
  (let proof = (ml_workload case_id size bad) in (if (ml_checked (ml_bundle (ml_ann (get_proof_body proof) (get_proof_ty proof)))) then 1L else 0L))

and ml_regressions () : int64 =
  (let good_pair = (ml_ann (ml_pair (ml_zero ()) (ml_refl (ml_zero ()))) (ml_sigma 0L (ml_nat ()) (ml_eq (ml_nat ()) (ml_v 0L) (ml_v 0L)))) in (let a = (ml_checked (ml_ann (ml_u 0L) (ml_u 1L))) in (let b = (not (ml_checked (ml_ann (ml_u 0L) (ml_u 0L)))) in (let c = (not (ml_checked (ml_ann (ml_v 7L) (ml_nat ())))) in (let d = (not (ml_checked (ml_let 0L (ml_nat ()) (ml_u 0L) (ml_zero ())))) in (let e = (not (ml_checked (ml_ann (ml_app (ml_ann (ml_lam 0L (ml_zero ())) (ml_pi 0L (ml_nat ()) (ml_nat ()))) (ml_u 0L)) (ml_nat ())))) in (let f = (ml_checked (ml_ann (ml_fst good_pair) (ml_nat ()))) in (let g = (ml_checked (ml_ann (ml_snd good_pair) (ml_eq (ml_nat ()) (ml_zero ()) (ml_zero ())))) in (let h = (not (ml_checked (ml_ann (ml_refl (ml_zero ())) (ml_eq (ml_nat ()) (ml_zero ()) (ml_suc (ml_zero ())))))) in (let i = (not (ml_checked (ml_natelim (ml_ann (ml_lam 0L (ml_nat ())) (ml_pi 0L (ml_nat ()) (ml_u 0L))) (ml_zero ()) (ml_lam 0L (ml_lam 1L (ml_u 0L))) (ml_zero ())))) in (let k = (not (ml_checked (ml_j (ml_nat ()) (ml_zero ()) (ml_ann (ml_lam 0L (ml_lam 1L (ml_nat ()))) (ml_pi 0L (ml_nat ()) (ml_pi 1L (ml_eq (ml_nat ()) (ml_zero ()) (ml_v 0L)) (ml_u 0L)))) (ml_zero ()) (ml_suc (ml_zero ())) (ml_refl (ml_zero ()))))) in (if (((((((((a && b) && c) && d) && e) && f) && g) && h) && i) && k) then 10L else 0L))))))))))))

let () =
  let result = (Int64.add (Int64.add (Int64.add (Int64.add (Int64.add (Int64.add (ml_regressions ()) (ml_check_case 0L 4096L false)) (ml_check_case 1L 4096L false)) (ml_check_case 2L 4096L false)) (Int64.sub 1L (ml_check_case 0L 4096L true))) (Int64.sub 1L (ml_check_case 1L 4096L true))) (Int64.sub 1L (ml_check_case 2L 4096L true))) in
  if result <> 16L then failwith "MLTT check failed";
  print_endline "16"
