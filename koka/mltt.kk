import std/num/int64



div type term

  TVar(f0: int64)

  TU(f0: int64)

  TPi(f0: int64, f1: term, f2: term)

  TLam(f0: int64, f1: term)

  TApp(f0: term, f1: term)

  TLet(f0: int64, f1: term, f2: term, f3: term)

  TAnn(f0: term, f1: term)

  TNat

  TZero

  TSuc(f0: term)

  TNatElim(f0: term, f1: term, f2: term, f3: term)

  TId(f0: term, f1: term, f2: term)

  TRefl(f0: term)

  TJ(f0: term, f1: term, f2: term, f3: term, f4: term, f5: term)

  TSigma(f0: int64, f1: term, f2: term)

  TPair(f0: term, f1: term)

  TFst(f0: term)

  TSnd(f0: term)

div type closure

  MkClosure(f0: int64, f1: term, f2: env)

div type value

  VError

  VU(f0: int64)

  VPi(f0: value, f1: closure)

  VLam(f0: closure)

  VNat

  VZero

  VSuc(f0: value)

  VId(f0: value, f1: value, f2: value)

  VRefl(f0: value)

  VSigma(f0: value, f1: closure)

  VPair(f0: value, f1: value)

  VVar(f0: int64)

  VApp(f0: value, f1: value)

  VNatElim(f0: value, f1: value, f2: value, f3: value)

  VJ(f0: value, f1: value, f2: value, f3: value, f4: value, f5: value)

  VFst(f0: value)

  VSnd(f0: value)

div type env

  ENil

  EBind(f0: int64, f1: value, f2: env)

div type ctx_state

  MkContext(f0: env, f1: env, f2: int64)

div type proof

  MkProof(f0: term, f1: term)

fun get_closure_name(v: closure) : int64 { match v { MkClosure(x0, _, _) -> x0 } }

fun get_closure_body(v: closure) : term { match v { MkClosure(_, x1, _) -> x1 } }

fun get_closure_env(v: closure) : env { match v { MkClosure(_, _, x2) -> x2 } }

fun get_context_env(v: ctx_state) : env { match v { MkContext(x0, _, _) -> x0 } }

fun get_context_types(v: ctx_state) : env { match v { MkContext(_, x1, _) -> x1 } }

fun get_context_level(v: ctx_state) : int64 { match v { MkContext(_, _, x2) -> x2 } }

fun get_proof_ty(v: proof) : term { match v { MkProof(x0, _) -> x0 } }

fun get_proof_body(v: proof) : term { match v { MkProof(_, x1) -> x1 } }

// Linked environments and explicit semantic closures.
fun ml_empty() : div env {
  ENil
}

fun ml_bind(name: int64, value: value, env: env) : div env {
  EBind(name, value, env)
}

fun ml_lookup(env: env, name: int64) : div value {
  (match env {
    ENil ->
      VError;
    EBind(key, value, rest) ->
      (if (key == name) then value else ml_lookup(rest, name))
  })
}

fun ml_extend(context_arg: ctx_state, name: int64, ty: value, value: value, level: int64) : div ctx_state {
  MkContext(ml_bind(name, value, get_context_env(context_arg)), ml_bind(name, ty, get_context_types(context_arg)), level)
}

fun ml_fresh(level: int64) : div value {
  VVar(level)
}

fun ml_closure(name: int64, body: term, env: env) : div closure {
  MkClosure(name, body, env)
}

fun ml_instantiate(c: closure, arg: value) : div value {
  ml_eval(ml_bind(get_closure_name(c), arg, get_closure_env(c)), get_closure_body(c))
}

fun ml_apply(arg_fun: value, arg: value) : div value {
  (match arg_fun { VLam(c) -> ml_instantiate(c, arg); _ -> VApp(arg_fun, arg) })
}

fun ml_nat_elim(m: value, z: value, s: value, n: value) : div value {
  (match n {
    VZero ->
      z;
    VSuc(k) ->
      ml_apply(ml_apply(s, k), ml_nat_elim(m, z, s, k));
    _ ->
      VNatElim(m, z, s, n)
  })
}

fun ml_id_elim(a: value, x: value, m: value, d: value, y: value, p: value) : div value {
  (match p { VRefl(_) -> d; _ -> VJ(a, x, m, d, y, p) })
}

fun ml_first(p: value) : div value {
  (match p { VPair(a, _) -> a; _ -> VFst(p) })
}

fun ml_second(p: value) : div value {
  (match p { VPair(_, b) -> b; _ -> VSnd(p) })
}

// Evaluation; eliminators reduce on constructors and stay neutral otherwise.
fun ml_eval(env: env, term: term) : div value {
  (match term {
    TVar(i) ->
      ml_lookup(env, i);
    TU(i) ->
      VU(i);
    TPi(i, a, b) ->
      VPi(ml_eval(env, a), ml_closure(i, b, env));
    TLam(i, b) ->
      VLam(ml_closure(i, b, env));
    TApp(f, a) ->
      ml_apply(ml_eval(env, f), ml_eval(env, a));
    TLet(i, _, a, b) ->
      ml_eval(ml_bind(i, ml_eval(env, a), env), b);
    TAnn(a, _) ->
      ml_eval(env, a);
    TNat ->
      VNat;
    TZero ->
      VZero;
    TSuc(n) ->
      VSuc(ml_eval(env, n));
    TNatElim(m, z, s, n) ->
      ml_nat_elim(ml_eval(env, m), ml_eval(env, z), ml_eval(env, s), ml_eval(env, n));
    TId(a, x, y) ->
      VId(ml_eval(env, a), ml_eval(env, x), ml_eval(env, y));
    TRefl(x) ->
      VRefl(ml_eval(env, x));
    TJ(a, x, m, d, y, p) ->
      ml_id_elim(ml_eval(env, a), ml_eval(env, x), ml_eval(env, m), ml_eval(env, d), ml_eval(env, y), ml_eval(env, p));
    TSigma(i, a, b) ->
      VSigma(ml_eval(env, a), ml_closure(i, b, env));
    TPair(a, b) ->
      VPair(ml_eval(env, a), ml_eval(env, b));
    TFst(p) ->
      ml_first(ml_eval(env, p));
    TSnd(p) ->
      ml_second(ml_eval(env, p))
  })
}

// Conversion compares semantic values using fresh neutral variables.
fun ml_conv(level: int64, a: value, b: value) : div bool {
  (match a {
    VU(i) ->
      (match b { VU(j) -> (i == j); _ -> False });
    VVar(i) ->
      (match b { VVar(j) -> (i == j); _ -> False });
    VNat ->
      (match b { VNat -> True; _ -> False });
    VZero ->
      (match b { VZero -> True; _ -> False });
    VPi(a, c) ->
      (match b {
        VPi(b, d) ->
          (ml_conv(level, a, b) && ml_conv((level + 1.int64), ml_instantiate(c, ml_fresh(level)), ml_instantiate(d, ml_fresh(level))));
        _ ->
          False
      });
    VSigma(a, c) ->
      (match b {
        VSigma(b, d) ->
          (ml_conv(level, a, b) && ml_conv((level + 1.int64), ml_instantiate(c, ml_fresh(level)), ml_instantiate(d, ml_fresh(level))));
        _ ->
          False
      });
    VLam(c) ->
      (match b {
        VLam(d) ->
          ml_conv((level + 1.int64), ml_instantiate(c, ml_fresh(level)), ml_instantiate(d, ml_fresh(level)));
        _ ->
          False
      });
    VSuc(a) ->
      (match b { VSuc(b) -> ml_conv(level, a, b); _ -> False });
    VRefl(a) ->
      (match b { VRefl(b) -> ml_conv(level, a, b); _ -> False });
    VFst(a) ->
      (match b { VFst(b) -> ml_conv(level, a, b); _ -> False });
    VSnd(a) ->
      (match b { VSnd(b) -> ml_conv(level, a, b); _ -> False });
    VApp(a, x) ->
      (match b { VApp(b, y) -> (ml_conv(level, a, b) && ml_conv(level, x, y)); _ -> False });
    VPair(a, x) ->
      (match b { VPair(b, y) -> (ml_conv(level, a, b) && ml_conv(level, x, y)); _ -> False });
    VId(a, x, y) ->
      (match b {
        VId(b, u, v) ->
          ((ml_conv(level, a, b) && ml_conv(level, x, u)) && ml_conv(level, y, v));
        _ ->
          False
      });
    VNatElim(m, z, s, n) ->
      (match b {
        VNatElim(m2, z2, s2, n2) ->
          (((ml_conv(level, m, m2) && ml_conv(level, z, z2)) && ml_conv(level, s, s2)) && ml_conv(level, n, n2));
        _ ->
          False
      });
    VJ(a, x, m, d, y, p) ->
      (match b {
        VJ(a2, x2, m2, d2, y2, p2) ->
          (((((ml_conv(level, a, a2) && ml_conv(level, x, x2)) && ml_conv(level, m, m2)) && ml_conv(level, d, d2)) && ml_conv(level, y, y2)) && ml_conv(level, p, p2));
        _ ->
          False
      });
    VError ->
      False
  })
}

// Bidirectional type checking with exact universe levels.
fun ml_sort(context_arg: ctx_state, term: term) : div int64 {
  (match ml_infer(context_arg, term) { VU(i) -> i; _ -> (-1.int64) })
}

fun ml_check(context_arg: ctx_state, term: term, ty: value) : div bool {
  (match term {
    TLam(name, body) ->
      (match ty {
        VPi(a, c) ->
          {
            val neutral =
              ml_fresh(get_context_level(context_arg));
            ml_check(ml_extend(context_arg, name, a, neutral, (get_context_level(context_arg) + 1.int64)), body, ml_instantiate(c, neutral))
          };
        _ ->
          False
      });
    TPair(a, b) ->
      (match ty {
        VSigma(domain, c) ->
          (ml_check(context_arg, a, domain) && ml_check(context_arg, b, ml_instantiate(c, ml_eval(get_context_env(context_arg), a))));
        _ ->
          False
      });
    _ ->
      ml_conv(get_context_level(context_arg), ml_infer(context_arg, term), ty)
  })
}

fun ml_nat_step_type(motive: value) : div value {
    val body =
      ml_pi((-2.int64), ml_app(ml_v((-3.int64)), ml_v((-1.int64))), ml_app(ml_v((-3.int64)), ml_suc(ml_v((-1.int64)))));
    VPi(VNat, ml_closure((-1.int64), body, ml_bind((-3.int64), motive, ml_empty())))
}

fun ml_is_universe(ty: value) : div bool {
  (match ty { VU(_) -> True; _ -> False })
}

fun ml_nat_motive_ok(context_arg: ctx_state, ty: value) : div bool {
  (match ty {
    VPi(a, c) ->
      (match a {
        VNat ->
          ml_is_universe(ml_instantiate(c, ml_fresh(get_context_level(context_arg))));
        _ ->
          False
      });
    _ ->
      False
  })
}

fun ml_id_motive_ok(context_arg: ctx_state, a: value, x: value, ty: value) : div bool {
  (match ty {
    VPi(b, c) ->
      (if ml_conv(get_context_level(context_arg), a, b) then { val y = ml_fresh(get_context_level(context_arg)); (match ml_instantiate(c, y) { VPi(p, d) -> (ml_conv((get_context_level(context_arg) + 1.int64), p, VId(a, x, y)) && ml_is_universe(ml_instantiate(d, ml_fresh((get_context_level(context_arg) + 1.int64))))); _ -> False }) } else False);
    _ ->
      False
  })
}

fun ml_infer_binder(context_arg: ctx_state, name: int64, a: term, b: term) : div value {
    val i =
      ml_sort(context_arg, a);
    (if (i < 0.int64) then VError else { val next = ml_extend(context_arg, name, ml_eval(get_context_env(context_arg), a), ml_fresh(get_context_level(context_arg)), (get_context_level(context_arg) + 1.int64)); val j = ml_sort(next, b); (if (j < 0.int64) then VError else VU((if (i > j) then i else j))) })
}

fun ml_infer(context_arg: ctx_state, term: term) : div value {
  (match term {
    TVar(i) ->
      ml_lookup(get_context_types(context_arg), i);
    TU(i) ->
      (if ((i >= 0.int64) && (i < 9223372036854775807.int64)) then VU((i + 1.int64)) else VError);
    TPi(name, a, b) ->
      ml_infer_binder(context_arg, name, a, b);
    TSigma(name, a, b) ->
      ml_infer_binder(context_arg, name, a, b);
    TApp(f, x) ->
      (match ml_infer(context_arg, f) {
        VPi(a, c) ->
          (if ml_check(context_arg, x, a) then ml_instantiate(c, ml_eval(get_context_env(context_arg), x)) else VError);
        _ ->
          VError
      });
    TLet(name, ty, rhs, body) ->
      (if (ml_sort(context_arg, ty) < 0.int64) then VError else { val ty = ml_eval(get_context_env(context_arg), ty); (if ml_check(context_arg, rhs, ty) then ml_infer(ml_extend(context_arg, name, ty, ml_eval(get_context_env(context_arg), rhs), get_context_level(context_arg)), body) else VError) });
    TAnn(body, ty) ->
      (if (ml_sort(context_arg, ty) < 0.int64) then VError else { val ty = ml_eval(get_context_env(context_arg), ty); (if ml_check(context_arg, body, ty) then ty else VError) });
    TNat ->
      VU(0.int64);
    TZero ->
      VNat;
    TSuc(n) ->
      (if ml_check(context_arg, n, VNat) then VNat else VError);
    TNatElim(m, z, s, n) ->
      (if ((!ml_nat_motive_ok(context_arg, ml_infer(context_arg, m))) || (!ml_check(context_arg, n, VNat))) then VError else { val m = ml_eval(get_context_env(context_arg), m); (if (ml_check(context_arg, z, ml_apply(m, VZero)) && ml_check(context_arg, s, ml_nat_step_type(m))) then ml_apply(m, ml_eval(get_context_env(context_arg), n)) else VError) });
    TId(a, x, y) ->
      {
        val level =
          ml_sort(context_arg, a);
        (if (level < 0.int64) then VError else { val a = ml_eval(get_context_env(context_arg), a); (if (ml_check(context_arg, x, a) && ml_check(context_arg, y, a)) then VU(level) else VError) })
      };
    TRefl(x) ->
      {
        val a =
          ml_infer(context_arg, x);
        (if ml_is_error(a) then VError else { val x = ml_eval(get_context_env(context_arg), x); VId(a, x, x) })
      };
    TJ(a, x, m, d, y, p) ->
      (if (ml_sort(context_arg, a) < 0.int64) then VError else { val a = ml_eval(get_context_env(context_arg), a); (if ((!ml_check(context_arg, x, a)) || (!ml_check(context_arg, y, a))) then VError else { val x = ml_eval(get_context_env(context_arg), x); val y = ml_eval(get_context_env(context_arg), y); (if ((!ml_check(context_arg, p, VId(a, x, y))) || (!ml_id_motive_ok(context_arg, a, x, ml_infer(context_arg, m)))) then VError else { val m = ml_eval(get_context_env(context_arg), m); (if ml_check(context_arg, d, ml_apply(ml_apply(m, x), VRefl(x))) then ml_apply(ml_apply(m, y), ml_eval(get_context_env(context_arg), p)) else VError) }) }) });
    TFst(p) ->
      (match ml_infer(context_arg, p) { VSigma(a, _) -> a; _ -> VError });
    TSnd(p) ->
      (match ml_infer(context_arg, p) {
        VSigma(_, c) ->
          ml_instantiate(c, ml_first(ml_eval(get_context_env(context_arg), p)));
        _ ->
          VError
      });
    _ ->
      VError
  })
}

// Syntax helpers used to construct the standalone proofs.
fun ml_v(i: int64) : div term {
  TVar(i)
}

fun ml_u(i: int64) : div term {
  TU(i)
}

fun ml_pi(i: int64, a: term, b: term) : div term {
  TPi(i, a, b)
}

fun ml_lam(i: int64, body: term) : div term {
  TLam(i, body)
}

fun ml_app(f: term, a: term) : div term {
  TApp(f, a)
}

fun ml_app2(f: term, a: term, b: term) : div term {
  ml_app(ml_app(f, a), b)
}

fun ml_app3(f: term, a: term, b: term, c: term) : div term {
  ml_app(ml_app2(f, a, b), c)
}

fun ml_let(i: int64, ty: term, rhs: term, body: term) : div term {
  TLet(i, ty, rhs, body)
}

fun ml_ann(body: term, ty: term) : div term {
  TAnn(body, ty)
}

fun ml_nat() : div term {
  TNat
}

fun ml_zero() : div term {
  TZero
}

fun ml_suc(n: term) : div term {
  TSuc(n)
}

fun ml_natelim(m: term, z: term, s: term, n: term) : div term {
  TNatElim(m, z, s, n)
}

fun ml_eq(a: term, x: term, y: term) : div term {
  TId(a, x, y)
}

fun ml_refl(x: term) : div term {
  TRefl(x)
}

fun ml_j(a: term, x: term, m: term, d: term, y: term, p: term) : div term {
  TJ(a, x, m, d, y, p)
}

fun ml_sigma(i: int64, a: term, b: term) : div term {
  TSigma(i, a, b)
}

fun ml_pair(a: term, b: term) : div term {
  TPair(a, b)
}

fun ml_fst(p: term) : div term {
  TFst(p)
}

fun ml_snd(p: term) : div term {
  TSnd(p)
}

fun ml_is_error(value: value) : div bool {
  (match value { VError -> True; _ -> False })
}

fun ml_infer_top(context_arg: ctx_state, term: term) : div value {
  ml_infer(context_arg, term)
}

// Proof library: addition, congruence, right identity, associativity, symmetry, transitivity.
fun ml_numeral(n: int64) : div term {
  (if (n == 0.int64) then ml_zero() else ml_suc(ml_numeral((n - 1.int64))))
}

fun ml_add(x: term, y: term) : div term {
  ml_app2(ml_v(100.int64), x, y)
}

fun ml_cong(x: term, y: term, p: term) : div term {
  ml_app3(ml_v(101.int64), x, y, p)
}

fun ml_trans(x: term, y: term, z: term, p: term, q: term) : div term {
  ml_app2(ml_app3(ml_app(ml_v(105.int64), ml_nat()), x, y, z), p, q)
}

fun ml_add_type() : div term {
  ml_pi(0.int64, ml_nat(), ml_pi(1.int64, ml_nat(), ml_nat()))
}

fun ml_add_body() : div term {
  ml_lam(0.int64, ml_lam(1.int64, ml_natelim(ml_ann(ml_lam(2.int64, ml_nat()), ml_pi(2.int64, ml_nat(), ml_u(0.int64))), ml_v(1.int64), ml_lam(3.int64, ml_lam(4.int64, ml_suc(ml_v(4.int64)))), ml_v(0.int64))))
}

fun ml_cong_type() : div term {
  ml_pi(0.int64, ml_nat(), ml_pi(1.int64, ml_nat(), ml_pi(2.int64, ml_eq(ml_nat(), ml_v(0.int64), ml_v(1.int64)), ml_eq(ml_nat(), ml_suc(ml_v(0.int64)), ml_suc(ml_v(1.int64))))))
}

fun ml_cong_body() : div term {
  ml_lam(0.int64, ml_lam(1.int64, ml_lam(2.int64, ml_j(ml_nat(), ml_v(0.int64), ml_ann(ml_lam(3.int64, ml_lam(4.int64, ml_eq(ml_nat(), ml_suc(ml_v(0.int64)), ml_suc(ml_v(3.int64))))), ml_pi(3.int64, ml_nat(), ml_pi(4.int64, ml_eq(ml_nat(), ml_v(0.int64), ml_v(3.int64)), ml_u(0.int64)))), ml_refl(ml_suc(ml_v(0.int64))), ml_v(1.int64), ml_v(2.int64)))))
}

fun ml_right_type() : div term {
  ml_pi(0.int64, ml_nat(), ml_eq(ml_nat(), ml_add(ml_v(0.int64), ml_zero()), ml_v(0.int64)))
}

fun ml_right_body() : div term {
  ml_lam(0.int64, ml_natelim(ml_ann(ml_lam(1.int64, ml_eq(ml_nat(), ml_add(ml_v(1.int64), ml_zero()), ml_v(1.int64))), ml_pi(1.int64, ml_nat(), ml_u(0.int64))), ml_refl(ml_zero()), ml_lam(2.int64, ml_lam(3.int64, ml_cong(ml_add(ml_v(2.int64), ml_zero()), ml_v(2.int64), ml_v(3.int64)))), ml_v(0.int64)))
}

fun ml_assoc_type() : div term {
  ml_pi(0.int64, ml_nat(), ml_pi(1.int64, ml_nat(), ml_pi(2.int64, ml_nat(), ml_eq(ml_nat(), ml_add(ml_add(ml_v(0.int64), ml_v(1.int64)), ml_v(2.int64)), ml_add(ml_v(0.int64), ml_add(ml_v(1.int64), ml_v(2.int64)))))))
}

fun ml_assoc_body() : div term {
  ml_lam(0.int64, ml_lam(1.int64, ml_lam(2.int64, ml_natelim(ml_ann(ml_lam(3.int64, ml_eq(ml_nat(), ml_add(ml_add(ml_v(3.int64), ml_v(1.int64)), ml_v(2.int64)), ml_add(ml_v(3.int64), ml_add(ml_v(1.int64), ml_v(2.int64))))), ml_pi(3.int64, ml_nat(), ml_u(0.int64))), ml_refl(ml_add(ml_v(1.int64), ml_v(2.int64))), ml_lam(4.int64, ml_lam(5.int64, ml_cong(ml_add(ml_add(ml_v(4.int64), ml_v(1.int64)), ml_v(2.int64)), ml_add(ml_v(4.int64), ml_add(ml_v(1.int64), ml_v(2.int64))), ml_v(5.int64)))), ml_v(0.int64)))))
}

fun ml_sym_type() : div term {
  ml_pi(0.int64, ml_u(0.int64), ml_pi(1.int64, ml_v(0.int64), ml_pi(2.int64, ml_v(0.int64), ml_pi(3.int64, ml_eq(ml_v(0.int64), ml_v(1.int64), ml_v(2.int64)), ml_eq(ml_v(0.int64), ml_v(2.int64), ml_v(1.int64))))))
}

fun ml_sym_body() : div term {
  ml_lam(0.int64, ml_lam(1.int64, ml_lam(2.int64, ml_lam(3.int64, ml_j(ml_v(0.int64), ml_v(1.int64), ml_ann(ml_lam(4.int64, ml_lam(5.int64, ml_eq(ml_v(0.int64), ml_v(4.int64), ml_v(1.int64)))), ml_pi(4.int64, ml_v(0.int64), ml_pi(5.int64, ml_eq(ml_v(0.int64), ml_v(1.int64), ml_v(4.int64)), ml_u(0.int64)))), ml_refl(ml_v(1.int64)), ml_v(2.int64), ml_v(3.int64))))))
}

fun ml_trans_type() : div term {
  ml_pi(0.int64, ml_u(0.int64), ml_pi(1.int64, ml_v(0.int64), ml_pi(2.int64, ml_v(0.int64), ml_pi(3.int64, ml_v(0.int64), ml_pi(4.int64, ml_eq(ml_v(0.int64), ml_v(1.int64), ml_v(2.int64)), ml_pi(5.int64, ml_eq(ml_v(0.int64), ml_v(2.int64), ml_v(3.int64)), ml_eq(ml_v(0.int64), ml_v(1.int64), ml_v(3.int64))))))))
}

fun ml_trans_body() : div term {
  ml_lam(0.int64, ml_lam(1.int64, ml_lam(2.int64, ml_lam(3.int64, ml_lam(4.int64, ml_lam(5.int64, ml_j(ml_v(0.int64), ml_v(2.int64), ml_ann(ml_lam(6.int64, ml_lam(7.int64, ml_eq(ml_v(0.int64), ml_v(1.int64), ml_v(6.int64)))), ml_pi(6.int64, ml_v(0.int64), ml_pi(7.int64, ml_eq(ml_v(0.int64), ml_v(2.int64), ml_v(6.int64)), ml_u(0.int64)))), ml_v(4.int64), ml_v(3.int64), ml_v(5.int64))))))))
}

// Every proof bundle checks all six supporting definitions from scratch.
fun ml_bundle(body: term) : div term {
  ml_let(100.int64, ml_add_type(), ml_add_body(), ml_let(101.int64, ml_cong_type(), ml_cong_body(), ml_let(102.int64, ml_right_type(), ml_right_body(), ml_let(103.int64, ml_assoc_type(), ml_assoc_body(), ml_let(104.int64, ml_sym_type(), ml_sym_body(), ml_let(105.int64, ml_trans_type(), ml_trans_body(), body))))))
}

fun ml_chain_end(i: int64) : div term {
  (if ((i % 2.int64) == 0.int64) then ml_v(1000.int64) else ml_add(ml_v(1000.int64), ml_zero()))
}

fun ml_chain_lets(i: int64, rest: term, bad: bool) : div term {
  (if (i == 0.int64) then ml_let(2000.int64, ml_eq(ml_nat(), ml_add(ml_v(1000.int64), ml_zero()), ml_v(1000.int64)), ml_app(ml_v(102.int64), ml_v(1000.int64)), rest) else { val evidence = (if (bad && (i == 1.int64)) then ml_refl(ml_zero()) else (if ((i % 2.int64) == 1.int64) then ml_app(ml_v(104.int64), ml_nat()) else ml_v(102.int64))); val q = (if (bad && (i == 1.int64)) then evidence else (if ((i % 2.int64) == 1.int64) then ml_app3(evidence, ml_add(ml_v(1000.int64), ml_zero()), ml_v(1000.int64), ml_v(2000.int64)) else ml_app(evidence, ml_v(1000.int64)))); ml_chain_lets((i - 1.int64), ml_let((2000.int64 + i), ml_eq(ml_nat(), ml_add(ml_v(1000.int64), ml_zero()), ml_chain_end(i)), ml_trans(ml_add(ml_v(1000.int64), ml_zero()), ml_chain_end((i - 1.int64)), ml_chain_end(i), ml_v((1999.int64 + i)), q), rest), bad) })
}

// Three proof families; bad deliberately corrupts the proposition or a proof step.
fun ml_workload(case_id: int64, size: int64, bad: bool) : div proof {
  (if (case_id == 0.int64) then { val result = ml_eq(ml_nat(), ml_add(ml_add(ml_numeral(size), ml_v(1000.int64)), ml_v(1001.int64)), ml_add(ml_numeral(size), ml_add(ml_v(1000.int64), ml_v(1001.int64)))); MkProof(ml_pi(1000.int64, ml_nat(), ml_pi(1001.int64, ml_nat(), result)), ml_lam(1000.int64, ml_lam(1001.int64, ml_app3(ml_v(103.int64), ml_numeral(size), ml_v(1000.int64), (if bad then ml_suc(ml_v(1001.int64)) else ml_v(1001.int64)))))) } else (if (case_id == 1.int64) then MkProof(ml_pi(1000.int64, ml_nat(), ml_eq(ml_nat(), ml_add(ml_v(1000.int64), ml_zero()), ml_chain_end(size))), ml_lam(1000.int64, ml_chain_lets(size, ml_v((2000.int64 + size)), bad))) else { val witness = ml_add(ml_numeral(size), ml_numeral(size)); MkProof(ml_sigma(1000.int64, ml_nat(), ml_eq(ml_nat(), ml_v(1000.int64), ml_numeral((size * 2.int64)))), ml_pair(witness, ml_refl(ml_numeral(((size * 2.int64) + (if bad then 1.int64 else 0.int64)))))) }))
}

fun ml_checked(term: term) : div bool {
    val context_arg =
      MkContext(ml_empty(), ml_empty(), 0.int64);
    (!ml_is_error(ml_infer_top(context_arg, term)))
}

fun ml_check_case(case_id: int64, size: int64, bad: bool) : div int64 {
    val proof =
      ml_workload(case_id, size, bad);
    (if ml_checked(ml_bundle(ml_ann(get_proof_body(proof), get_proof_ty(proof)))) then 1.int64 else 0.int64)
}

// Ten small acceptance/rejection checks, including invalid eliminators.
fun ml_regressions() : div int64 {
    val good_pair =
      ml_ann(ml_pair(ml_zero(), ml_refl(ml_zero())), ml_sigma(0.int64, ml_nat(), ml_eq(ml_nat(), ml_v(0.int64), ml_v(0.int64))));
    val a =
      ml_checked(ml_ann(ml_u(0.int64), ml_u(1.int64)));
    val b =
      (!ml_checked(ml_ann(ml_u(0.int64), ml_u(0.int64))));
    val c =
      (!ml_checked(ml_ann(ml_v(7.int64), ml_nat())));
    val d =
      (!ml_checked(ml_let(0.int64, ml_nat(), ml_u(0.int64), ml_zero())));
    val e =
      (!ml_checked(ml_ann(ml_app(ml_ann(ml_lam(0.int64, ml_zero()), ml_pi(0.int64, ml_nat(), ml_nat())), ml_u(0.int64)), ml_nat())));
    val f =
      ml_checked(ml_ann(ml_fst(good_pair), ml_nat()));
    val g =
      ml_checked(ml_ann(ml_snd(good_pair), ml_eq(ml_nat(), ml_zero(), ml_zero())));
    val h =
      (!ml_checked(ml_ann(ml_refl(ml_zero()), ml_eq(ml_nat(), ml_zero(), ml_suc(ml_zero())))));
    val i =
      (!ml_checked(ml_natelim(ml_ann(ml_lam(0.int64, ml_nat()), ml_pi(0.int64, ml_nat(), ml_u(0.int64))), ml_zero(), ml_lam(0.int64, ml_lam(1.int64, ml_u(0.int64))), ml_zero())));
    val k =
      (!ml_checked(ml_j(ml_nat(), ml_zero(), ml_ann(ml_lam(0.int64, ml_lam(1.int64, ml_nat())), ml_pi(0.int64, ml_nat(), ml_pi(1.int64, ml_eq(ml_nat(), ml_zero(), ml_v(0.int64)), ml_u(0.int64)))), ml_zero(), ml_suc(ml_zero()), ml_refl(ml_zero()))));
    (if (((((((((a && b) && c) && d) && e) && f) && g) && h) && i) && k) then 10.int64 else 0.int64)
}

pub fun main() {
  val result = ((((((ml_regressions() + ml_check_case(0.int64, 4096.int64, False)) + ml_check_case(1.int64, 4096.int64, False)) + ml_check_case(2.int64, 4096.int64, False)) + (1.int64 - ml_check_case(0.int64, 4096.int64, True))) + (1.int64 - ml_check_case(1.int64, 4096.int64, True))) + (1.int64 - ml_check_case(2.int64, 4096.int64, True)))
  if result != 16.int64 then throw("MLTT check failed")
  println(result.show)
}
