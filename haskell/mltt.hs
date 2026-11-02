{-# LANGUAGE BangPatterns #-}

module Main where

import Data.Int (Int64)

import Prelude hiding (lookup)



data Term = TVar !Int64
  | TU !Int64
  | TPi !Int64 !Term !Term
  | TLam !Int64 !Term
  | TApp !Term !Term
  | TLet !Int64 !Term !Term !Term
  | TAnn !Term !Term
  | TNat
  | TZero
  | TSuc !Term
  | TNatElim !Term !Term !Term !Term
  | TId !Term !Term !Term
  | TRefl !Term
  | TJ !Term !Term !Term !Term !Term !Term
  | TSigma !Int64 !Term !Term
  | TPair !Term !Term
  | TFst !Term
  | TSnd !Term

data Closure = MkClosure !Int64 !Term !Env

data Value = VError
  | VU !Int64
  | VPi !Value !Closure
  | VLam !Closure
  | VNat
  | VZero
  | VSuc !Value
  | VId !Value !Value !Value
  | VRefl !Value
  | VSigma !Value !Closure
  | VPair !Value !Value
  | VVar !Int64
  | VApp !Value !Value
  | VNatElim !Value !Value !Value !Value
  | VJ !Value !Value !Value !Value !Value !Value
  | VFst !Value
  | VSnd !Value

data Env = ENil
  | EBind !Int64 !Value !Env

data Context = MkContext !Env !Env !Int64

data Proof = MkProof !Term !Term

get_closure_name :: Closure -> Int64

get_closure_name (MkClosure x0 _ _) = x0

get_closure_body :: Closure -> Term

get_closure_body (MkClosure _ x1 _) = x1

get_closure_env :: Closure -> Env

get_closure_env (MkClosure _ _ x2) = x2

get_context_env :: Context -> Env

get_context_env (MkContext x0 _ _) = x0

get_context_types :: Context -> Env

get_context_types (MkContext _ x1 _) = x1

get_context_level :: Context -> Int64

get_context_level (MkContext _ _ x2) = x2

get_proof_ty :: Proof -> Term

get_proof_ty (MkProof x0 _) = x0

get_proof_body :: Proof -> Term

get_proof_body (MkProof _ x1) = x1

ml_empty :: () -> Env

ml_empty () =
  ENil

ml_bind :: Int64 -> Value -> Env -> Env

ml_bind !name !value !env =
  (EBind name value env)

ml_lookup :: Env -> Int64 -> Value

ml_lookup !env !name =
  (case env of { ENil -> VError; (EBind key value rest) -> (if (key == name) then value else (ml_lookup rest name)) })

ml_extend :: Context -> Int64 -> Value -> Value -> Int64 -> Context

ml_extend !context_arg !name !ty !value !level =
  (MkContext (ml_bind name value (get_context_env context_arg)) (ml_bind name ty (get_context_types context_arg)) level)

ml_fresh :: Int64 -> Value

ml_fresh !level =
  (VVar level)

ml_closure :: Int64 -> Term -> Env -> Closure

ml_closure !name !body !env =
  (MkClosure name body env)

ml_instantiate :: Closure -> Value -> Value

ml_instantiate !c !arg =
  (ml_eval (ml_bind (get_closure_name c) arg (get_closure_env c)) (get_closure_body c))

ml_apply :: Value -> Value -> Value

ml_apply !arg_fun !arg =
  (case arg_fun of { (VLam c) -> (ml_instantiate c arg); _ -> (VApp arg_fun arg) })

ml_nat_elim :: Value -> Value -> Value -> Value -> Value

ml_nat_elim !m !z !s !n =
  (case n of { VZero -> z; (VSuc k) -> (ml_apply (ml_apply s k) (ml_nat_elim m z s k)); _ -> (VNatElim m z s n) })

ml_id_elim :: Value -> Value -> Value -> Value -> Value -> Value -> Value

ml_id_elim !a !x !m !d !y !p =
  (case p of { (VRefl _) -> d; _ -> (VJ a x m d y p) })

ml_first :: Value -> Value

ml_first !p =
  (case p of { (VPair a _) -> a; _ -> (VFst p) })

ml_second :: Value -> Value

ml_second !p =
  (case p of { (VPair _ b) -> b; _ -> (VSnd p) })

ml_eval :: Env -> Term -> Value

ml_eval !env !term =
  (case term of { (TVar i) -> (ml_lookup env i); (TU i) -> (VU i); (TPi i a b) -> (VPi (ml_eval env a) (ml_closure i b env)); (TLam i b) -> (VLam (ml_closure i b env)); (TApp f a) -> (ml_apply (ml_eval env f) (ml_eval env a)); (TLet i _ a b) -> (ml_eval (ml_bind i (ml_eval env a) env) b); (TAnn a _) -> (ml_eval env a); TNat -> VNat; TZero -> VZero; (TSuc n) -> (VSuc (ml_eval env n)); (TNatElim m z s n) -> (ml_nat_elim (ml_eval env m) (ml_eval env z) (ml_eval env s) (ml_eval env n)); (TId a x y) -> (VId (ml_eval env a) (ml_eval env x) (ml_eval env y)); (TRefl x) -> (VRefl (ml_eval env x)); (TJ a x m d y p) -> (ml_id_elim (ml_eval env a) (ml_eval env x) (ml_eval env m) (ml_eval env d) (ml_eval env y) (ml_eval env p)); (TSigma i a b) -> (VSigma (ml_eval env a) (ml_closure i b env)); (TPair a b) -> (VPair (ml_eval env a) (ml_eval env b)); (TFst p) -> (ml_first (ml_eval env p)); (TSnd p) -> (ml_second (ml_eval env p)) })

ml_conv :: Int64 -> Value -> Value -> Bool

ml_conv !level !a !b =
  (case a of { (VU i) -> (case b of { (VU j) -> (i == j); _ -> False }); (VVar i) -> (case b of { (VVar j) -> (i == j); _ -> False }); VNat -> (case b of { VNat -> True; _ -> False }); VZero -> (case b of { VZero -> True; _ -> False }); (VPi a c) -> (case b of { (VPi b d) -> ((ml_conv level a b) && (ml_conv (level + 1) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level)))); _ -> False }); (VSigma a c) -> (case b of { (VSigma b d) -> ((ml_conv level a b) && (ml_conv (level + 1) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level)))); _ -> False }); (VLam c) -> (case b of { (VLam d) -> (ml_conv (level + 1) (ml_instantiate c (ml_fresh level)) (ml_instantiate d (ml_fresh level))); _ -> False }); (VSuc a) -> (case b of { (VSuc b) -> (ml_conv level a b); _ -> False }); (VRefl a) -> (case b of { (VRefl b) -> (ml_conv level a b); _ -> False }); (VFst a) -> (case b of { (VFst b) -> (ml_conv level a b); _ -> False }); (VSnd a) -> (case b of { (VSnd b) -> (ml_conv level a b); _ -> False }); (VApp a x) -> (case b of { (VApp b y) -> ((ml_conv level a b) && (ml_conv level x y)); _ -> False }); (VPair a x) -> (case b of { (VPair b y) -> ((ml_conv level a b) && (ml_conv level x y)); _ -> False }); (VId a x y) -> (case b of { (VId b u v) -> (((ml_conv level a b) && (ml_conv level x u)) && (ml_conv level y v)); _ -> False }); (VNatElim m z s n) -> (case b of { (VNatElim m2 z2 s2 n2) -> ((((ml_conv level m m2) && (ml_conv level z z2)) && (ml_conv level s s2)) && (ml_conv level n n2)); _ -> False }); (VJ a x m d y p) -> (case b of { (VJ a2 x2 m2 d2 y2 p2) -> ((((((ml_conv level a a2) && (ml_conv level x x2)) && (ml_conv level m m2)) && (ml_conv level d d2)) && (ml_conv level y y2)) && (ml_conv level p p2)); _ -> False }); VError -> False })

ml_sort :: Context -> Term -> Int64

ml_sort !context_arg !term =
  (case (ml_infer context_arg term) of { (VU i) -> i; _ -> (-1) })

ml_check :: Context -> Term -> Value -> Bool

ml_check !context_arg !term !ty =
  (case term of { (TLam name body) -> (case ty of { (VPi a c) -> (case (ml_fresh (get_context_level context_arg)) of { !neutral -> (ml_check (ml_extend context_arg name a neutral ((get_context_level context_arg) + 1)) body (ml_instantiate c neutral)) }); _ -> False }); (TPair a b) -> (case ty of { (VSigma domain c) -> ((ml_check context_arg a domain) && (ml_check context_arg b (ml_instantiate c (ml_eval (get_context_env context_arg) a)))); _ -> False }); _ -> (ml_conv (get_context_level context_arg) (ml_infer context_arg term) ty) })

ml_nat_step_type :: Value -> Value

ml_nat_step_type !motive =
  (case (ml_pi (-2) (ml_app (ml_v (-3)) (ml_v (-1))) (ml_app (ml_v (-3)) (ml_suc (ml_v (-1))))) of { !body -> (VPi VNat (ml_closure (-1) body (ml_bind (-3) motive (ml_empty ())))) })

ml_is_universe :: Value -> Bool

ml_is_universe !ty =
  (case ty of { (VU _) -> True; _ -> False })

ml_nat_motive_ok :: Context -> Value -> Bool

ml_nat_motive_ok !context_arg !ty =
  (case ty of { (VPi a c) -> (case a of { VNat -> (ml_is_universe (ml_instantiate c (ml_fresh (get_context_level context_arg)))); _ -> False }); _ -> False })

ml_id_motive_ok :: Context -> Value -> Value -> Value -> Bool

ml_id_motive_ok !context_arg !a !x !ty =
  (case ty of { (VPi b c) -> (if (ml_conv (get_context_level context_arg) a b) then (case (ml_fresh (get_context_level context_arg)) of { !y -> (case (ml_instantiate c y) of { (VPi p d) -> ((ml_conv ((get_context_level context_arg) + 1) p (VId a x y)) && (ml_is_universe (ml_instantiate d (ml_fresh ((get_context_level context_arg) + 1))))); _ -> False }) }) else False); _ -> False })

ml_infer_binder :: Context -> Int64 -> Term -> Term -> Value

ml_infer_binder !context_arg !name !a !b =
  (case (ml_sort context_arg a) of { !i -> (if (i < 0) then VError else (case (ml_extend context_arg name (ml_eval (get_context_env context_arg) a) (ml_fresh (get_context_level context_arg)) ((get_context_level context_arg) + 1)) of { !next -> (case (ml_sort next b) of { !j -> (if (j < 0) then VError else (VU (if (i > j) then i else j))) }) })) })

ml_infer :: Context -> Term -> Value

ml_infer !context_arg !term =
  (case term of { (TVar i) -> (ml_lookup (get_context_types context_arg) i); (TU i) -> (if ((i >= 0) && (i < 9223372036854775807)) then (VU (i + 1)) else VError); (TPi name a b) -> (ml_infer_binder context_arg name a b); (TSigma name a b) -> (ml_infer_binder context_arg name a b); (TApp f x) -> (case (ml_infer context_arg f) of { (VPi a c) -> (if (ml_check context_arg x a) then (ml_instantiate c (ml_eval (get_context_env context_arg) x)) else VError); _ -> VError }); (TLet name ty rhs body) -> (if ((ml_sort context_arg ty) < 0) then VError else (case (ml_eval (get_context_env context_arg) ty) of { !ty -> (if (ml_check context_arg rhs ty) then (ml_infer (ml_extend context_arg name ty (ml_eval (get_context_env context_arg) rhs) (get_context_level context_arg)) body) else VError) })); (TAnn body ty) -> (if ((ml_sort context_arg ty) < 0) then VError else (case (ml_eval (get_context_env context_arg) ty) of { !ty -> (if (ml_check context_arg body ty) then ty else VError) })); TNat -> (VU 0); TZero -> VNat; (TSuc n) -> (if (ml_check context_arg n VNat) then VNat else VError); (TNatElim m z s n) -> (if ((not (ml_nat_motive_ok context_arg (ml_infer context_arg m))) || (not (ml_check context_arg n VNat))) then VError else (case (ml_eval (get_context_env context_arg) m) of { !m -> (if ((ml_check context_arg z (ml_apply m VZero)) && (ml_check context_arg s (ml_nat_step_type m))) then (ml_apply m (ml_eval (get_context_env context_arg) n)) else VError) })); (TId a x y) -> (case (ml_sort context_arg a) of { !level -> (if (level < 0) then VError else (case (ml_eval (get_context_env context_arg) a) of { !a -> (if ((ml_check context_arg x a) && (ml_check context_arg y a)) then (VU level) else VError) })) }); (TRefl x) -> (case (ml_infer context_arg x) of { !a -> (if (ml_is_error a) then VError else (case (ml_eval (get_context_env context_arg) x) of { !x -> (VId a x x) })) }); (TJ a x m d y p) -> (if ((ml_sort context_arg a) < 0) then VError else (case (ml_eval (get_context_env context_arg) a) of { !a -> (if ((not (ml_check context_arg x a)) || (not (ml_check context_arg y a))) then VError else (case (ml_eval (get_context_env context_arg) x) of { !x -> (case (ml_eval (get_context_env context_arg) y) of { !y -> (if ((not (ml_check context_arg p (VId a x y))) || (not (ml_id_motive_ok context_arg a x (ml_infer context_arg m)))) then VError else (case (ml_eval (get_context_env context_arg) m) of { !m -> (if (ml_check context_arg d (ml_apply (ml_apply m x) (VRefl x))) then (ml_apply (ml_apply m y) (ml_eval (get_context_env context_arg) p)) else VError) })) }) })) })); (TFst p) -> (case (ml_infer context_arg p) of { (VSigma a _) -> a; _ -> VError }); (TSnd p) -> (case (ml_infer context_arg p) of { (VSigma _ c) -> (ml_instantiate c (ml_first (ml_eval (get_context_env context_arg) p))); _ -> VError }); _ -> VError })

ml_v :: Int64 -> Term

ml_v !i =
  (TVar i)

ml_u :: Int64 -> Term

ml_u !i =
  (TU i)

ml_pi :: Int64 -> Term -> Term -> Term

ml_pi !i !a !b =
  (TPi i a b)

ml_lam :: Int64 -> Term -> Term

ml_lam !i !body =
  (TLam i body)

ml_app :: Term -> Term -> Term

ml_app !f !a =
  (TApp f a)

ml_app2 :: Term -> Term -> Term -> Term

ml_app2 !f !a !b =
  (ml_app (ml_app f a) b)

ml_app3 :: Term -> Term -> Term -> Term -> Term

ml_app3 !f !a !b !c =
  (ml_app (ml_app2 f a b) c)

ml_let :: Int64 -> Term -> Term -> Term -> Term

ml_let !i !ty !rhs !body =
  (TLet i ty rhs body)

ml_ann :: Term -> Term -> Term

ml_ann !body !ty =
  (TAnn body ty)

ml_nat :: () -> Term

ml_nat () =
  TNat

ml_zero :: () -> Term

ml_zero () =
  TZero

ml_suc :: Term -> Term

ml_suc !n =
  (TSuc n)

ml_natelim :: Term -> Term -> Term -> Term -> Term

ml_natelim !m !z !s !n =
  (TNatElim m z s n)

ml_eq :: Term -> Term -> Term -> Term

ml_eq !a !x !y =
  (TId a x y)

ml_refl :: Term -> Term

ml_refl !x =
  (TRefl x)

ml_j :: Term -> Term -> Term -> Term -> Term -> Term -> Term

ml_j !a !x !m !d !y !p =
  (TJ a x m d y p)

ml_sigma :: Int64 -> Term -> Term -> Term

ml_sigma !i !a !b =
  (TSigma i a b)

ml_pair :: Term -> Term -> Term

ml_pair !a !b =
  (TPair a b)

ml_fst :: Term -> Term

ml_fst !p =
  (TFst p)

ml_snd :: Term -> Term

ml_snd !p =
  (TSnd p)

ml_is_error :: Value -> Bool

ml_is_error !value =
  (case value of { VError -> True; _ -> False })

ml_infer_top :: Context -> Term -> Value

ml_infer_top !context_arg !term =
  (ml_infer context_arg term)

ml_numeral :: Int64 -> Term

ml_numeral !n =
  (if (n == 0) then (ml_zero ()) else (ml_suc (ml_numeral (n - 1))))

ml_add :: Term -> Term -> Term

ml_add !x !y =
  (ml_app2 (ml_v 100) x y)

ml_cong :: Term -> Term -> Term -> Term

ml_cong !x !y !p =
  (ml_app3 (ml_v 101) x y p)

ml_trans :: Term -> Term -> Term -> Term -> Term -> Term

ml_trans !x !y !z !p !q =
  (ml_app2 (ml_app3 (ml_app (ml_v 105) (ml_nat ())) x y z) p q)

ml_add_type :: () -> Term

ml_add_type () =
  (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_nat ()) (ml_nat ())))

ml_add_body :: () -> Term

ml_add_body () =
  (ml_lam 0 (ml_lam 1 (ml_natelim (ml_ann (ml_lam 2 (ml_nat ())) (ml_pi 2 (ml_nat ()) (ml_u 0))) (ml_v 1) (ml_lam 3 (ml_lam 4 (ml_suc (ml_v 4)))) (ml_v 0))))

ml_cong_type :: () -> Term

ml_cong_type () =
  (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_nat ()) (ml_pi 2 (ml_eq (ml_nat ()) (ml_v 0) (ml_v 1)) (ml_eq (ml_nat ()) (ml_suc (ml_v 0)) (ml_suc (ml_v 1))))))

ml_cong_body :: () -> Term

ml_cong_body () =
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_j (ml_nat ()) (ml_v 0) (ml_ann (ml_lam 3 (ml_lam 4 (ml_eq (ml_nat ()) (ml_suc (ml_v 0)) (ml_suc (ml_v 3))))) (ml_pi 3 (ml_nat ()) (ml_pi 4 (ml_eq (ml_nat ()) (ml_v 0) (ml_v 3)) (ml_u 0)))) (ml_refl (ml_suc (ml_v 0))) (ml_v 1) (ml_v 2)))))

ml_right_type :: () -> Term

ml_right_type () =
  (ml_pi 0 (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_v 0) (ml_zero ())) (ml_v 0)))

ml_right_body :: () -> Term

ml_right_body () =
  (ml_lam 0 (ml_natelim (ml_ann (ml_lam 1 (ml_eq (ml_nat ()) (ml_add (ml_v 1) (ml_zero ())) (ml_v 1))) (ml_pi 1 (ml_nat ()) (ml_u 0))) (ml_refl (ml_zero ())) (ml_lam 2 (ml_lam 3 (ml_cong (ml_add (ml_v 2) (ml_zero ())) (ml_v 2) (ml_v 3)))) (ml_v 0)))

ml_assoc_type :: () -> Term

ml_assoc_type () =
  (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_nat ()) (ml_pi 2 (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_add (ml_v 0) (ml_v 1)) (ml_v 2)) (ml_add (ml_v 0) (ml_add (ml_v 1) (ml_v 2)))))))

ml_assoc_body :: () -> Term

ml_assoc_body () =
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_natelim (ml_ann (ml_lam 3 (ml_eq (ml_nat ()) (ml_add (ml_add (ml_v 3) (ml_v 1)) (ml_v 2)) (ml_add (ml_v 3) (ml_add (ml_v 1) (ml_v 2))))) (ml_pi 3 (ml_nat ()) (ml_u 0))) (ml_refl (ml_add (ml_v 1) (ml_v 2))) (ml_lam 4 (ml_lam 5 (ml_cong (ml_add (ml_add (ml_v 4) (ml_v 1)) (ml_v 2)) (ml_add (ml_v 4) (ml_add (ml_v 1) (ml_v 2))) (ml_v 5)))) (ml_v 0)))))

ml_sym_type :: () -> Term

ml_sym_type () =
  (ml_pi 0 (ml_u 0) (ml_pi 1 (ml_v 0) (ml_pi 2 (ml_v 0) (ml_pi 3 (ml_eq (ml_v 0) (ml_v 1) (ml_v 2)) (ml_eq (ml_v 0) (ml_v 2) (ml_v 1))))))

ml_sym_body :: () -> Term

ml_sym_body () =
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_lam 3 (ml_j (ml_v 0) (ml_v 1) (ml_ann (ml_lam 4 (ml_lam 5 (ml_eq (ml_v 0) (ml_v 4) (ml_v 1)))) (ml_pi 4 (ml_v 0) (ml_pi 5 (ml_eq (ml_v 0) (ml_v 1) (ml_v 4)) (ml_u 0)))) (ml_refl (ml_v 1)) (ml_v 2) (ml_v 3))))))

ml_trans_type :: () -> Term

ml_trans_type () =
  (ml_pi 0 (ml_u 0) (ml_pi 1 (ml_v 0) (ml_pi 2 (ml_v 0) (ml_pi 3 (ml_v 0) (ml_pi 4 (ml_eq (ml_v 0) (ml_v 1) (ml_v 2)) (ml_pi 5 (ml_eq (ml_v 0) (ml_v 2) (ml_v 3)) (ml_eq (ml_v 0) (ml_v 1) (ml_v 3))))))))

ml_trans_body :: () -> Term

ml_trans_body () =
  (ml_lam 0 (ml_lam 1 (ml_lam 2 (ml_lam 3 (ml_lam 4 (ml_lam 5 (ml_j (ml_v 0) (ml_v 2) (ml_ann (ml_lam 6 (ml_lam 7 (ml_eq (ml_v 0) (ml_v 1) (ml_v 6)))) (ml_pi 6 (ml_v 0) (ml_pi 7 (ml_eq (ml_v 0) (ml_v 2) (ml_v 6)) (ml_u 0)))) (ml_v 4) (ml_v 3) (ml_v 5))))))))

ml_bundle :: Term -> Term

ml_bundle !body =
  (ml_let 100 (ml_add_type ()) (ml_add_body ()) (ml_let 101 (ml_cong_type ()) (ml_cong_body ()) (ml_let 102 (ml_right_type ()) (ml_right_body ()) (ml_let 103 (ml_assoc_type ()) (ml_assoc_body ()) (ml_let 104 (ml_sym_type ()) (ml_sym_body ()) (ml_let 105 (ml_trans_type ()) (ml_trans_body ()) body))))))

ml_chain_end :: Int64 -> Term

ml_chain_end !i =
  (if ((i `rem` 2) == 0) then (ml_v 1000) else (ml_add (ml_v 1000) (ml_zero ())))

ml_chain_lets :: Int64 -> Term -> Bool -> Term

ml_chain_lets !i !rest !bad =
  (if (i == 0) then (ml_let 2000 (ml_eq (ml_nat ()) (ml_add (ml_v 1000) (ml_zero ())) (ml_v 1000)) (ml_app (ml_v 102) (ml_v 1000)) rest) else (case (if (bad && (i == 1)) then (ml_refl (ml_zero ())) else (if ((i `rem` 2) == 1) then (ml_app (ml_v 104) (ml_nat ())) else (ml_v 102))) of { !evidence -> (case (if (bad && (i == 1)) then evidence else (if ((i `rem` 2) == 1) then (ml_app3 evidence (ml_add (ml_v 1000) (ml_zero ())) (ml_v 1000) (ml_v 2000)) else (ml_app evidence (ml_v 1000)))) of { !q -> (ml_chain_lets (i - 1) (ml_let (2000 + i) (ml_eq (ml_nat ()) (ml_add (ml_v 1000) (ml_zero ())) (ml_chain_end i)) (ml_trans (ml_add (ml_v 1000) (ml_zero ())) (ml_chain_end (i - 1)) (ml_chain_end i) (ml_v (1999 + i)) q) rest) bad) }) }))

ml_workload :: Int64 -> Int64 -> Bool -> Proof

ml_workload !case_id !size !bad =
  (if (case_id == 0) then (case (ml_eq (ml_nat ()) (ml_add (ml_add (ml_numeral size) (ml_v 1000)) (ml_v 1001)) (ml_add (ml_numeral size) (ml_add (ml_v 1000) (ml_v 1001)))) of { !result -> (MkProof (ml_pi 1000 (ml_nat ()) (ml_pi 1001 (ml_nat ()) result)) (ml_lam 1000 (ml_lam 1001 (ml_app3 (ml_v 103) (ml_numeral size) (ml_v 1000) (if bad then (ml_suc (ml_v 1001)) else (ml_v 1001)))))) }) else (if (case_id == 1) then (MkProof (ml_pi 1000 (ml_nat ()) (ml_eq (ml_nat ()) (ml_add (ml_v 1000) (ml_zero ())) (ml_chain_end size))) (ml_lam 1000 (ml_chain_lets size (ml_v (2000 + size)) bad))) else (case (ml_add (ml_numeral size) (ml_numeral size)) of { !witness -> (MkProof (ml_sigma 1000 (ml_nat ()) (ml_eq (ml_nat ()) (ml_v 1000) (ml_numeral (size * 2)))) (ml_pair witness (ml_refl (ml_numeral ((size * 2) + (if bad then 1 else 0)))))) })))

ml_checked :: Term -> Bool

ml_checked !term =
  (case (MkContext (ml_empty ()) (ml_empty ()) 0) of { !context_arg -> (not (ml_is_error (ml_infer_top context_arg term))) })

ml_check_case :: Int64 -> Int64 -> Bool -> Int64

ml_check_case !case_id !size !bad =
  (case (ml_workload case_id size bad) of { !proof -> (if (ml_checked (ml_bundle (ml_ann (get_proof_body proof) (get_proof_ty proof)))) then 1 else 0) })

ml_regressions :: () -> Int64

ml_regressions () =
  (case (ml_ann (ml_pair (ml_zero ()) (ml_refl (ml_zero ()))) (ml_sigma 0 (ml_nat ()) (ml_eq (ml_nat ()) (ml_v 0) (ml_v 0)))) of { !good_pair -> (case (ml_checked (ml_ann (ml_u 0) (ml_u 1))) of { !a -> (case (not (ml_checked (ml_ann (ml_u 0) (ml_u 0)))) of { !b -> (case (not (ml_checked (ml_ann (ml_v 7) (ml_nat ())))) of { !c -> (case (not (ml_checked (ml_let 0 (ml_nat ()) (ml_u 0) (ml_zero ())))) of { !d -> (case (not (ml_checked (ml_ann (ml_app (ml_ann (ml_lam 0 (ml_zero ())) (ml_pi 0 (ml_nat ()) (ml_nat ()))) (ml_u 0)) (ml_nat ())))) of { !e -> (case (ml_checked (ml_ann (ml_fst good_pair) (ml_nat ()))) of { !f -> (case (ml_checked (ml_ann (ml_snd good_pair) (ml_eq (ml_nat ()) (ml_zero ()) (ml_zero ())))) of { !g -> (case (not (ml_checked (ml_ann (ml_refl (ml_zero ())) (ml_eq (ml_nat ()) (ml_zero ()) (ml_suc (ml_zero ())))))) of { !h -> (case (not (ml_checked (ml_natelim (ml_ann (ml_lam 0 (ml_nat ())) (ml_pi 0 (ml_nat ()) (ml_u 0))) (ml_zero ()) (ml_lam 0 (ml_lam 1 (ml_u 0))) (ml_zero ())))) of { !i -> (case (not (ml_checked (ml_j (ml_nat ()) (ml_zero ()) (ml_ann (ml_lam 0 (ml_lam 1 (ml_nat ()))) (ml_pi 0 (ml_nat ()) (ml_pi 1 (ml_eq (ml_nat ()) (ml_zero ()) (ml_v 0)) (ml_u 0)))) (ml_zero ()) (ml_suc (ml_zero ())) (ml_refl (ml_zero ()))))) of { !k -> (if (((((((((a && b) && c) && d) && e) && f) && g) && h) && i) && k) then 10 else 0) }) }) }) }) }) }) }) }) }) }) })

main :: IO ()

main = let !result = (((((((ml_regressions ()) + (ml_check_case 0 4096 False)) + (ml_check_case 1 4096 False)) + (ml_check_case 2 4096 False)) + (1 - (ml_check_case 0 4096 True))) + (1 - (ml_check_case 1 4096 True))) + (1 - (ml_check_case 2 4096 True))) in
  if result == 16 then print result else error "MLTT check failed"
