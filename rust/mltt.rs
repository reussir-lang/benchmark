use std::rc::Rc;

type T = Rc<Term>;
type V = Rc<Value>;
type E = Rc<Env>;

enum Term {
    Var(i64),
    U(i64),
    Pi(i64, T, T),
    Lam(i64, T),
    App(T, T),
    Let(i64, T, T, T),
    Ann(T, T),
    Nat,
    Zero,
    Suc(T),
    NatElim(T, T, T, T),
    Id(T, T, T),
    Refl(T),
    J(T, T, T, T, T, T),
    Sigma(i64, T, T),
    Pair(T, T),
    Fst(T),
    Snd(T),
}

#[derive(Clone)]
struct Closure {
    name: i64,
    body: T,
    env: E,
}

enum Value {
    Error,
    U(i64),
    Pi(V, Closure),
    Lam(Closure),
    Nat,
    Zero,
    Suc(V),
    Id(V, V, V),
    Refl(V),
    Sigma(V, Closure),
    Pair(V, V),
    Var(i64),
    App(V, V),
    NatElim(V, V, V, V),
    J(V, V, V, V, V, V),
    Fst(V),
    Snd(V),
}

enum Env {
    Nil,
    Bind(i64, V, E),
}

#[derive(Clone)]
struct Context {
    env: E,
    types: E,
    level: i64,
}

fn empty() -> E {
    Rc::new(Env::Nil)
}
fn bind(name: i64, value: V, env: E) -> E {
    Rc::new(Env::Bind(name, value, env))
}
fn lookup(env: &E, name: i64) -> V {
    let mut env = env;
    loop {
        match env.as_ref() {
            Env::Nil => return Rc::new(Value::Error),
            Env::Bind(key, value, _) if *key == name => return value.clone(),
            Env::Bind(_, _, rest) => env = rest,
        }
    }
}
fn extend(ctx: &Context, name: i64, ty: V, value: V, level: i64) -> Context {
    Context {
        env: bind(name, value, ctx.env.clone()),
        types: bind(name, ty, ctx.types.clone()),
        level,
    }
}
fn fresh(level: i64) -> V {
    Rc::new(Value::Var(level))
}
fn closure(name: i64, body: &T, env: &E) -> Closure {
    Closure {
        name,
        body: body.clone(),
        env: env.clone(),
    }
}
fn instantiate(c: &Closure, arg: V) -> V {
    eval(&bind(c.name, arg, c.env.clone()), &c.body)
}
fn apply(fun: V, arg: V) -> V {
    match fun.as_ref() {
        Value::Lam(c) => instantiate(c, arg),
        _ => Rc::new(Value::App(fun, arg)),
    }
}
fn nat_elim(m: V, z: V, s: V, n: V) -> V {
    match n.as_ref() {
        Value::Zero => z,
        Value::Suc(k) => apply(apply(s.clone(), k.clone()), nat_elim(m, z, s, k.clone())),
        _ => Rc::new(Value::NatElim(m, z, s, n)),
    }
}
fn id_elim(a: V, x: V, m: V, d: V, y: V, p: V) -> V {
    match p.as_ref() {
        Value::Refl(_) => d,
        _ => Rc::new(Value::J(a, x, m, d, y, p)),
    }
}
fn first(p: V) -> V {
    match p.as_ref() {
        Value::Pair(a, _) => a.clone(),
        _ => Rc::new(Value::Fst(p)),
    }
}
fn second(p: V) -> V {
    match p.as_ref() {
        Value::Pair(_, b) => b.clone(),
        _ => Rc::new(Value::Snd(p)),
    }
}
fn eval(env: &E, term: &T) -> V {
    match term.as_ref() {
        Term::Var(i) => lookup(env, *i),
        Term::U(i) => Rc::new(Value::U(*i)),
        Term::Pi(i, a, b) => Rc::new(Value::Pi(eval(env, a), closure(*i, b, env))),
        Term::Lam(i, b) => Rc::new(Value::Lam(closure(*i, b, env))),
        Term::App(f, a) => apply(eval(env, f), eval(env, a)),
        Term::Let(i, _, a, b) => eval(&bind(*i, eval(env, a), env.clone()), b),
        Term::Ann(a, _) => eval(env, a),
        Term::Nat => Rc::new(Value::Nat),
        Term::Zero => Rc::new(Value::Zero),
        Term::Suc(n) => Rc::new(Value::Suc(eval(env, n))),
        Term::NatElim(m, z, s, n) => {
            nat_elim(eval(env, m), eval(env, z), eval(env, s), eval(env, n))
        }
        Term::Id(a, x, y) => Rc::new(Value::Id(eval(env, a), eval(env, x), eval(env, y))),
        Term::Refl(x) => Rc::new(Value::Refl(eval(env, x))),
        Term::J(a, x, m, d, y, p) => id_elim(
            eval(env, a),
            eval(env, x),
            eval(env, m),
            eval(env, d),
            eval(env, y),
            eval(env, p),
        ),
        Term::Sigma(i, a, b) => Rc::new(Value::Sigma(eval(env, a), closure(*i, b, env))),
        Term::Pair(a, b) => Rc::new(Value::Pair(eval(env, a), eval(env, b))),
        Term::Fst(p) => first(eval(env, p)),
        Term::Snd(p) => second(eval(env, p)),
    }
}

// Conversion compares semantic values under fresh neutral variables.
fn conv(level: i64, a: &V, b: &V) -> bool {
    match (a.as_ref(), b.as_ref()) {
        (Value::U(i), Value::U(j)) | (Value::Var(i), Value::Var(j)) => i == j,
        (Value::Nat, Value::Nat) | (Value::Zero, Value::Zero) => true,
        (Value::Pi(a, c), Value::Pi(b, d)) | (Value::Sigma(a, c), Value::Sigma(b, d)) => {
            conv(level, a, b)
                && conv(
                    level + 1,
                    &instantiate(c, fresh(level)),
                    &instantiate(d, fresh(level)),
                )
        }
        (Value::Lam(c), Value::Lam(d)) => conv(
            level + 1,
            &instantiate(c, fresh(level)),
            &instantiate(d, fresh(level)),
        ),
        (Value::Suc(a), Value::Suc(b))
        | (Value::Refl(a), Value::Refl(b))
        | (Value::Fst(a), Value::Fst(b))
        | (Value::Snd(a), Value::Snd(b)) => conv(level, a, b),
        (Value::App(a, x), Value::App(b, y)) | (Value::Pair(a, x), Value::Pair(b, y)) => {
            conv(level, a, b) && conv(level, x, y)
        }
        (Value::Id(a, x, y), Value::Id(b, u, v)) => {
            conv(level, a, b) && conv(level, x, u) && conv(level, y, v)
        }
        (Value::NatElim(m, z, s, n), Value::NatElim(m2, z2, s2, n2)) => {
            conv(level, m, m2) && conv(level, z, z2) && conv(level, s, s2) && conv(level, n, n2)
        }
        (Value::J(a, x, m, d, y, p), Value::J(a2, x2, m2, d2, y2, p2)) => {
            conv(level, a, a2)
                && conv(level, x, x2)
                && conv(level, m, m2)
                && conv(level, d, d2)
                && conv(level, y, y2)
                && conv(level, p, p2)
        }
        _ => false,
    }
}

fn sort(ctx: &Context, term: &T) -> Option<i64> {
    match infer(ctx, term).as_ref() {
        Value::U(i) => Some(*i),
        _ => None,
    }
}
fn check(ctx: &Context, term: &T, ty: &V) -> bool {
    match (term.as_ref(), ty.as_ref()) {
        (Term::Lam(name, body), Value::Pi(a, c)) => {
            let variable = fresh(ctx.level);
            check(
                &extend(ctx, *name, a.clone(), variable.clone(), ctx.level + 1),
                body,
                &instantiate(c, variable),
            )
        }
        (Term::Pair(a, b), Value::Sigma(domain, c)) => {
            check(ctx, a, domain) && check(ctx, b, &instantiate(c, eval(&ctx.env, a)))
        }
        _ => conv(ctx.level, &infer(ctx, term), ty),
    }
}
fn nat_step_type(motive: V) -> V {
    let body = pi(-2, app(v(-3), v(-1)), app(v(-3), suc(v(-1))));
    Rc::new(Value::Pi(
        Rc::new(Value::Nat),
        Closure {
            name: -1,
            body,
            env: bind(-3, motive, empty()),
        },
    ))
}
fn nat_motive_ok(ctx: &Context, ty: &V) -> bool {
    match ty.as_ref() {
        Value::Pi(a, c) if matches!(a.as_ref(), Value::Nat) => {
            matches!(instantiate(c, fresh(ctx.level)).as_ref(), Value::U(_))
        }
        _ => false,
    }
}
fn id_motive_ok(ctx: &Context, a: &V, x: &V, ty: &V) -> bool {
    match ty.as_ref() {
        Value::Pi(b, c) if conv(ctx.level, a, b) => {
            let y = fresh(ctx.level);
            match instantiate(c, y.clone()).as_ref() {
                Value::Pi(p, d)
                    if conv(
                        ctx.level + 1,
                        p,
                        &Rc::new(Value::Id(a.clone(), x.clone(), y)),
                    ) =>
                {
                    matches!(instantiate(d, fresh(ctx.level + 1)).as_ref(), Value::U(_))
                }
                _ => false,
            }
        }
        _ => false,
    }
}
fn infer(ctx: &Context, term: &T) -> V {
    let error = || Rc::new(Value::Error);
    match term.as_ref() {
        Term::Var(i) => lookup(&ctx.types, *i),
        Term::U(i) if *i >= 0 && *i < i64::MAX => Rc::new(Value::U(i + 1)),
        Term::Pi(name, a, b) | Term::Sigma(name, a, b) => {
            let Some(i) = sort(ctx, a) else {
                return error();
            };
            let next = extend(
                ctx,
                *name,
                eval(&ctx.env, a),
                fresh(ctx.level),
                ctx.level + 1,
            );
            match sort(&next, b) {
                Some(j) => Rc::new(Value::U(i.max(j))),
                None => error(),
            }
        }
        Term::App(f, x) => match infer(ctx, f).as_ref() {
            Value::Pi(a, c) if check(ctx, x, a) => instantiate(c, eval(&ctx.env, x)),
            _ => error(),
        },
        Term::Let(name, ty, rhs, body) => {
            if sort(ctx, ty).is_none() {
                return error();
            }
            let ty = eval(&ctx.env, ty);
            if !check(ctx, rhs, &ty) {
                return error();
            }
            infer(
                &extend(ctx, *name, ty, eval(&ctx.env, rhs), ctx.level),
                body,
            )
        }
        Term::Ann(body, ty) => {
            if sort(ctx, ty).is_none() {
                return error();
            }
            let ty = eval(&ctx.env, ty);
            if check(ctx, body, &ty) {
                ty
            } else {
                error()
            }
        }
        Term::Nat => Rc::new(Value::U(0)),
        Term::Zero => Rc::new(Value::Nat),
        Term::Suc(n) => {
            if check(ctx, n, &Rc::new(Value::Nat)) {
                Rc::new(Value::Nat)
            } else {
                error()
            }
        }
        Term::NatElim(m, z, s, n) => {
            if !nat_motive_ok(ctx, &infer(ctx, m)) || !check(ctx, n, &Rc::new(Value::Nat)) {
                return error();
            }
            let m = eval(&ctx.env, m);
            if !check(ctx, z, &apply(m.clone(), Rc::new(Value::Zero)))
                || !check(ctx, s, &nat_step_type(m.clone()))
            {
                return error();
            }
            apply(m, eval(&ctx.env, n))
        }
        Term::Id(a, x, y) => {
            let Some(level) = sort(ctx, a) else {
                return error();
            };
            let a = eval(&ctx.env, a);
            if check(ctx, x, &a) && check(ctx, y, &a) {
                Rc::new(Value::U(level))
            } else {
                error()
            }
        }
        Term::Refl(x) => {
            let a = infer(ctx, x);
            if matches!(a.as_ref(), Value::Error) {
                return error();
            }
            let x = eval(&ctx.env, x);
            Rc::new(Value::Id(a, x.clone(), x))
        }
        Term::J(a, x, m, d, y, p) => {
            if sort(ctx, a).is_none() {
                return error();
            }
            let a = eval(&ctx.env, a);
            if !check(ctx, x, &a) || !check(ctx, y, &a) {
                return error();
            }
            let x = eval(&ctx.env, x);
            let y = eval(&ctx.env, y);
            if !check(ctx, p, &Rc::new(Value::Id(a.clone(), x.clone(), y.clone())))
                || !id_motive_ok(ctx, &a, &x, &infer(ctx, m))
            {
                return error();
            }
            let m = eval(&ctx.env, m);
            if !check(
                ctx,
                d,
                &apply(apply(m.clone(), x.clone()), Rc::new(Value::Refl(x))),
            ) {
                return error();
            }
            apply(apply(m, y), eval(&ctx.env, p))
        }
        Term::Fst(p) => match infer(ctx, p).as_ref() {
            Value::Sigma(a, _) => a.clone(),
            _ => error(),
        },
        Term::Snd(p) => match infer(ctx, p).as_ref() {
            Value::Sigma(_, c) => instantiate(c, first(eval(&ctx.env, p))),
            _ => error(),
        },
        _ => error(),
    }
}

fn v(i: i64) -> T {
    Rc::new(Term::Var(i))
}
fn u(i: i64) -> T {
    Rc::new(Term::U(i))
}
fn pi(i: i64, a: T, b: T) -> T {
    Rc::new(Term::Pi(i, a, b))
}
fn lam(i: i64, body: T) -> T {
    Rc::new(Term::Lam(i, body))
}
fn app(f: T, a: T) -> T {
    Rc::new(Term::App(f, a))
}
fn app2(f: T, a: T, b: T) -> T {
    app(app(f, a), b)
}
fn app3(f: T, a: T, b: T, c: T) -> T {
    app(app2(f, a, b), c)
}
fn let_(i: i64, ty: T, rhs: T, body: T) -> T {
    Rc::new(Term::Let(i, ty, rhs, body))
}
fn ann(body: T, ty: T) -> T {
    Rc::new(Term::Ann(body, ty))
}
fn nat() -> T {
    Rc::new(Term::Nat)
}
fn zero() -> T {
    Rc::new(Term::Zero)
}
fn suc(n: T) -> T {
    Rc::new(Term::Suc(n))
}
fn natelim(m: T, z: T, s: T, n: T) -> T {
    Rc::new(Term::NatElim(m, z, s, n))
}
fn eq(a: T, x: T, y: T) -> T {
    Rc::new(Term::Id(a, x, y))
}
fn refl(x: T) -> T {
    Rc::new(Term::Refl(x))
}
fn j(a: T, x: T, m: T, d: T, y: T, p: T) -> T {
    Rc::new(Term::J(a, x, m, d, y, p))
}
fn sigma(i: i64, a: T, b: T) -> T {
    Rc::new(Term::Sigma(i, a, b))
}
fn pair(a: T, b: T) -> T {
    Rc::new(Term::Pair(a, b))
}
fn fst(p: T) -> T {
    Rc::new(Term::Fst(p))
}
fn snd(p: T) -> T {
    Rc::new(Term::Snd(p))
}

struct Proof {
    ty: T,
    body: T,
}

fn numeral(n: i64) -> T {
    if n == 0 {
        zero()
    } else {
        suc(numeral(n - 1))
    }
}
fn add(x: T, y: T) -> T {
    app2(v(100), x, y)
}
fn cong(x: T, y: T, p: T) -> T {
    app3(v(101), x, y, p)
}
fn trans(x: T, y: T, z: T, p: T, q: T) -> T {
    app2(app3(app(v(105), nat()), x, y, z), p, q)
}
fn add_type() -> T {
    pi(0, nat(), pi(1, nat(), nat()))
}
fn add_body() -> T {
    lam(
        0,
        lam(
            1,
            natelim(
                ann(lam(2, nat()), pi(2, nat(), u(0))),
                v(1),
                lam(3, lam(4, suc(v(4)))),
                v(0),
            ),
        ),
    )
}
fn cong_type() -> T {
    pi(
        0,
        nat(),
        pi(
            1,
            nat(),
            pi(2, eq(nat(), v(0), v(1)), eq(nat(), suc(v(0)), suc(v(1)))),
        ),
    )
}
fn cong_body() -> T {
    lam(
        0,
        lam(
            1,
            lam(
                2,
                j(
                    nat(),
                    v(0),
                    ann(
                        lam(3, lam(4, eq(nat(), suc(v(0)), suc(v(3))))),
                        pi(3, nat(), pi(4, eq(nat(), v(0), v(3)), u(0))),
                    ),
                    refl(suc(v(0))),
                    v(1),
                    v(2),
                ),
            ),
        ),
    )
}
fn right_type() -> T {
    pi(0, nat(), eq(nat(), add(v(0), zero()), v(0)))
}
fn right_body() -> T {
    lam(
        0,
        natelim(
            ann(
                lam(1, eq(nat(), add(v(1), zero()), v(1))),
                pi(1, nat(), u(0)),
            ),
            refl(zero()),
            lam(2, lam(3, cong(add(v(2), zero()), v(2), v(3)))),
            v(0),
        ),
    )
}
fn assoc_type() -> T {
    pi(
        0,
        nat(),
        pi(
            1,
            nat(),
            pi(
                2,
                nat(),
                eq(
                    nat(),
                    add(add(v(0), v(1)), v(2)),
                    add(v(0), add(v(1), v(2))),
                ),
            ),
        ),
    )
}
fn assoc_body() -> T {
    lam(
        0,
        lam(
            1,
            lam(
                2,
                natelim(
                    ann(
                        lam(
                            3,
                            eq(
                                nat(),
                                add(add(v(3), v(1)), v(2)),
                                add(v(3), add(v(1), v(2))),
                            ),
                        ),
                        pi(3, nat(), u(0)),
                    ),
                    refl(add(v(1), v(2))),
                    lam(
                        4,
                        lam(
                            5,
                            cong(add(add(v(4), v(1)), v(2)), add(v(4), add(v(1), v(2))), v(5)),
                        ),
                    ),
                    v(0),
                ),
            ),
        ),
    )
}
fn sym_type() -> T {
    pi(
        0,
        u(0),
        pi(
            1,
            v(0),
            pi(2, v(0), pi(3, eq(v(0), v(1), v(2)), eq(v(0), v(2), v(1)))),
        ),
    )
}
fn sym_body() -> T {
    lam(
        0,
        lam(
            1,
            lam(
                2,
                lam(
                    3,
                    j(
                        v(0),
                        v(1),
                        ann(
                            lam(4, lam(5, eq(v(0), v(4), v(1)))),
                            pi(4, v(0), pi(5, eq(v(0), v(1), v(4)), u(0))),
                        ),
                        refl(v(1)),
                        v(2),
                        v(3),
                    ),
                ),
            ),
        ),
    )
}
fn trans_type() -> T {
    pi(
        0,
        u(0),
        pi(
            1,
            v(0),
            pi(
                2,
                v(0),
                pi(
                    3,
                    v(0),
                    pi(
                        4,
                        eq(v(0), v(1), v(2)),
                        pi(5, eq(v(0), v(2), v(3)), eq(v(0), v(1), v(3))),
                    ),
                ),
            ),
        ),
    )
}
fn trans_body() -> T {
    lam(
        0,
        lam(
            1,
            lam(
                2,
                lam(
                    3,
                    lam(
                        4,
                        lam(
                            5,
                            j(
                                v(0),
                                v(2),
                                ann(
                                    lam(6, lam(7, eq(v(0), v(1), v(6)))),
                                    pi(6, v(0), pi(7, eq(v(0), v(2), v(6)), u(0))),
                                ),
                                v(4),
                                v(3),
                                v(5),
                            ),
                        ),
                    ),
                ),
            ),
        ),
    )
}
fn bundle(body: T) -> T {
    let_(
        100,
        add_type(),
        add_body(),
        let_(
            101,
            cong_type(),
            cong_body(),
            let_(
                102,
                right_type(),
                right_body(),
                let_(
                    103,
                    assoc_type(),
                    assoc_body(),
                    let_(
                        104,
                        sym_type(),
                        sym_body(),
                        let_(105, trans_type(), trans_body(), body),
                    ),
                ),
            ),
        ),
    )
}

fn chain_end(i: i64) -> T {
    if i % 2 == 0 {
        v(1000)
    } else {
        add(v(1000), zero())
    }
}
fn chain_lets(i: i64, rest: T, bad: bool) -> T {
    if i == 0 {
        let_(
            2000,
            eq(nat(), add(v(1000), zero()), v(1000)),
            app(v(102), v(1000)),
            rest,
        )
    } else {
        let evidence = if bad && i == 1 {
            refl(zero())
        } else {
            if i % 2 == 1 {
                app(v(104), nat())
            } else {
                v(102)
            }
        };
        let q = if bad && i == 1 {
            evidence
        } else {
            if i % 2 == 1 {
                app3(evidence, add(v(1000), zero()), v(1000), v(2000))
            } else {
                app(evidence, v(1000))
            }
        };
        chain_lets(
            i - 1,
            let_(
                2000 + i,
                eq(nat(), add(v(1000), zero()), chain_end(i)),
                trans(
                    add(v(1000), zero()),
                    chain_end(i - 1),
                    chain_end(i),
                    v(1999 + i),
                    q,
                ),
                rest,
            ),
            bad,
        )
    }
}
fn workload(case_id: i64, size: i64, bad: bool) -> Proof {
    if case_id == 0 {
        let result = eq(
            nat(),
            add(add(numeral(size), v(1000)), v(1001)),
            add(numeral(size), add(v(1000), v(1001))),
        );
        Proof {
            ty: pi(1000, nat(), pi(1001, nat(), result)),
            body: lam(
                1000,
                lam(
                    1001,
                    app3(
                        v(103),
                        numeral(size),
                        v(1000),
                        if bad { suc(v(1001)) } else { v(1001) },
                    ),
                ),
            ),
        }
    } else {
        if case_id == 1 {
            Proof {
                ty: pi(
                    1000,
                    nat(),
                    eq(nat(), add(v(1000), zero()), chain_end(size)),
                ),
                body: lam(1000, chain_lets(size, v(2000 + size), bad)),
            }
        } else {
            let witness = add(numeral(size), numeral(size));
            Proof {
                ty: sigma(1000, nat(), eq(nat(), v(1000), numeral(size * 2))),
                body: pair(witness, refl(numeral(size * 2 + if bad { 1 } else { 0 }))),
            }
        }
    }
}
fn checked(term: T) -> bool {
    let ctx = Context {
        env: empty(),
        types: empty(),
        level: 0,
    };
    !is_error(infer_top(ctx, term))
}
fn check_case(case_id: i64, size: i64, bad: bool) -> i64 {
    let proof = workload(case_id, size, bad);
    if checked(bundle(ann(proof.body, proof.ty))) {
        1
    } else {
        0
    }
}
fn regressions() -> i64 {
    let good_pair = ann(
        pair(zero(), refl(zero())),
        sigma(0, nat(), eq(nat(), v(0), v(0))),
    );
    let a = checked(ann(u(0), u(1)));
    let b = !checked(ann(u(0), u(0)));
    let c = !checked(ann(v(7), nat()));
    let d = !checked(let_(0, nat(), u(0), zero()));
    let e = !checked(ann(
        app(ann(lam(0, zero()), pi(0, nat(), nat())), u(0)),
        nat(),
    ));
    let f = checked(ann(fst(good_pair.clone()), nat()));
    let g = checked(ann(snd(good_pair), eq(nat(), zero(), zero())));
    let h = !checked(ann(refl(zero()), eq(nat(), zero(), suc(zero()))));
    let i = !checked(natelim(
        ann(lam(0, nat()), pi(0, nat(), u(0))),
        zero(),
        lam(0, lam(1, u(0))),
        zero(),
    ));
    let k = !checked(j(
        nat(),
        zero(),
        ann(
            lam(0, lam(1, nat())),
            pi(0, nat(), pi(1, eq(nat(), zero(), v(0)), u(0))),
        ),
        zero(),
        suc(zero()),
        refl(zero()),
    ));
    if a && b && c && d && e && f && g && h && i && k {
        10
    } else {
        0
    }
}

fn is_error(value: V) -> bool {
    matches!(value.as_ref(), Value::Error)
}
fn infer_top(ctx: Context, term: T) -> V {
    infer(&ctx, &term)
}

fn main() {
    let mut result = regressions();
    for id in 0..3 {
        result += check_case(id, 4096, false);
        result += 1 - check_case(id, 4096, true);
    }
    assert_eq!(result, 16, "MLTT check failed");
    println!("{result}");
}
