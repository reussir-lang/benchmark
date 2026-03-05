#![allow(dead_code)]

use std::rc::Rc;

#[derive(Clone)]
enum Term {
    Var(i64),
    Lam(i64, Rc<Term>),
    App(Rc<Term>, Rc<Term>),
    Let(i64, Rc<Term>, Rc<Term>),
}

#[derive(Clone)]
enum Value {
    VVar(i64),
    VApp(Rc<Value>, Rc<Value>),
    VLam(i64, Rc<dyn Fn(Value) -> Value>),
}

#[derive(Clone)]
enum Env {
    Cons(i64, Value, Rc<Env>),
    Nil,
}

#[derive(Clone)]
enum Names {
    Cons(i64, Rc<Names>),
    Nil,
}

fn max_of_names(n: &Names, acc: i64) -> i64 {
    match n {
        Names::Cons(id, n1) => {
            let next = if acc > *id { acc } else { *id };
            max_of_names(n1, next)
        }
        Names::Nil => acc,
    }
}

fn names_of_env(env: &Env, acc: Names) -> Names {
    match env {
        Env::Cons(id, _, env1) =>
            names_of_env(env1, Names::Cons(*id, Rc::new(acc))),
        Env::Nil => acc,
    }
}

fn fresh(n: &Names) -> i64 {
    max_of_names(n, 0) + 1
}

fn lookup(env: &Env, id: i64) -> Value {
    match env {
        Env::Cons(id1, v, env1) =>
            if id == *id1 { v.clone() } else { lookup(env1, id) },
        Env::Nil => Value::VVar(id),
    }
}

fn eval(env: Rc<Env>, x: &Term) -> Value {
    match x {
        Term::Var(id) => lookup(&env, *id),
        Term::App(t, u) => vapp(eval(env.clone(), t), eval(env, u)),
        Term::Lam(x_id, t) => {
            let x_id = *x_id;
            let t = t.clone();
            let env = env.clone();
            Value::VLam(x_id, Rc::new(move |u: Value| {
                eval(Rc::new(Env::Cons(x_id, u, env.clone())), &t)
            }))
        }
        Term::Let(x_id, t, u) => {
            let v = eval(env.clone(), t);
            eval(Rc::new(Env::Cons(*x_id, v, env)), u)
        }
    }
}

fn vapp(v1: Value, v2: Value) -> Value {
    match v1 {
        Value::VLam(_, body) => body(v2),
        _ => Value::VApp(Rc::new(v1), Rc::new(v2)),
    }
}

fn quote(n: &Names, v: &Value) -> Term {
    match v {
        Value::VVar(i) => Term::Var(*i),
        Value::VApp(v1, v2) =>
            Term::App(Rc::new(quote(n, v1)), Rc::new(quote(n, v2))),
        Value::VLam(_, f) => {
            let y = fresh(n);
            let n2 = Names::Cons(y, Rc::new(n.clone()));
            Term::Lam(y, Rc::new(quote(&n2, &f(Value::VVar(y)))))
        }
    }
}

fn norm_form(env: Rc<Env>, t: &Term) -> Term {
    let names = names_of_env(&env, Names::Nil);
    let v = eval(env, t);
    quote(&names, &v)
}

fn five() -> Term {
    Term::Lam(0, Rc::new(
        Term::Lam(1, Rc::new(
            Term::App(Rc::new(Term::Var(0)), Rc::new(
                Term::App(Rc::new(Term::Var(0)), Rc::new(
                    Term::App(Rc::new(Term::Var(0)), Rc::new(
                        Term::App(Rc::new(Term::Var(0)), Rc::new(
                            Term::App(Rc::new(Term::Var(0)), Rc::new(Term::Var(1)))
                        ))
                    ))
                ))
            ))
        ))
    ))
}

fn add() -> Term {
    Term::Lam(0, Rc::new(
        Term::Lam(1, Rc::new(
            Term::Lam(2, Rc::new(
                Term::Lam(3, Rc::new(
                    Term::App(
                        Rc::new(Term::App(Rc::new(Term::Var(0)), Rc::new(Term::Var(2)))),
                        Rc::new(Term::App(
                            Rc::new(Term::App(Rc::new(Term::Var(1)), Rc::new(Term::Var(2)))),
                            Rc::new(Term::Var(3))
                        ))
                    )
                ))
            ))
        ))
    ))
}

fn mul() -> Term {
    Term::Lam(0, Rc::new(
        Term::Lam(1, Rc::new(
            Term::Lam(2, Rc::new(
                Term::Lam(3, Rc::new(
                    Term::App(
                        Rc::new(Term::App(
                            Rc::new(Term::Var(0)),
                            Rc::new(Term::App(Rc::new(Term::Var(1)), Rc::new(Term::Var(2))))
                        )),
                        Rc::new(Term::Var(3))
                    )
                ))
            ))
        ))
    ))
}

fn ten() -> Term {
    let x = five();
    let y = add();
    Term::App(Rc::new(Term::App(Rc::new(y), Rc::new(x.clone()))), Rc::new(x))
}

fn hundred() -> Term {
    let x = ten();
    let y = mul();
    Term::App(Rc::new(Term::App(Rc::new(y), Rc::new(x.clone()))), Rc::new(x))
}

fn two_hundred() -> Term {
    let x = hundred();
    let y = add();
    Term::App(Rc::new(Term::App(Rc::new(y), Rc::new(x.clone()))), Rc::new(x))
}

fn thousand() -> Term {
    let x = hundred();
    let z = ten();
    let y = mul();
    Term::App(Rc::new(Term::App(Rc::new(y), Rc::new(x))), Rc::new(z))
}

fn term200000() -> Term {
    let x = two_hundred();
    let y = mul();
    let z = thousand();
    Term::App(Rc::new(Term::App(Rc::new(y), Rc::new(x))), Rc::new(z))
}

fn term40000000() -> Term {
    let x = two_hundred();
    let y = mul();
    let z = term200000();
    Term::App(Rc::new(Term::App(Rc::new(y), Rc::new(x))), Rc::new(z))
}

fn nf_to_int(t: &Term, acc: i64) -> i64 {
    match t {
        Term::Lam(_, x) => nf_to_int(x, acc),
        Term::App(_, x) => nf_to_int(x, acc + 1),
        _ => acc,
    }
}

fn nbe_test() -> i64 {
    let t = term40000000();
    let n = norm_form(Rc::new(Env::Nil), &t);
    nf_to_int(&n, 0)
}

fn main() {
    let n = nbe_test();
    if n != 40000000 {
        eprintln!("FAIL: expected 40000000, got {}", n);
        std::process::exit(1);
    }
}
