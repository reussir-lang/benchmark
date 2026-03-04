#![allow(dead_code)]

use std::rc::Rc;

enum Term {
    Var(i64),
    App(Rc<Term>, Rc<Term>),
    Lam(Rc<Term>),
}

#[derive(Clone)]
enum Value {
    VVar(i64),
    VApp(Rc<Value>, Rc<Value>),
    VLam(Rc<dyn Fn(Value) -> Value>),
}

fn vlam<F>(f: F) -> Value
where
    F: Fn(Value) -> Value + 'static,
{
    Value::VLam(Rc::new(f))
}

fn ap(t: Value, u: Value) -> Value {
    match t {
        Value::VLam(f) => f(u),
        t => Value::VApp(Rc::new(t), Rc::new(u)),
    }
}

fn ap2(t: Value, u: Value, v: Value) -> Value {
    ap(ap(t, u), v)
}

fn n2() -> Value {
    vlam(|s| vlam(move |z| ap(s.clone(), ap(s.clone(), z))))
}

fn n5() -> Value {
    vlam(|s| {
        vlam(move |z| ap(s.clone(), ap(s.clone(), ap(s.clone(), ap(s.clone(), ap(s.clone(), z))))))
    })
}

fn mul() -> Value {
    vlam(|a| {
        vlam(move |b| {
            let a1 = a.clone();
            vlam(move |s| {
                let a2 = a1.clone();
                let b1 = b.clone();
                vlam(move |z| ap(ap(a2.clone(), ap(b1.clone(), s.clone())), z))
            })
        })
    })
}

fn suc(n: Value) -> Value {
    vlam(move |s| {
        let n1 = n.clone();
        vlam(move |z| ap(s.clone(), ap2(n1.clone(), s.clone(), z)))
    })
}

fn leaf() -> Value {
    vlam(|l| vlam(move |_n| l.clone()))
}

fn node() -> Value {
    vlam(|t1| {
        vlam(move |t2| {
            let t1a = t1.clone();
            vlam(move |_l| {
                let t1b = t1a.clone();
                let t2b = t2.clone();
                vlam(move |n| ap2(n, t1b.clone(), t2b.clone()))
            })
        })
    })
}

fn full_tree() -> Value {
    vlam(|n| ap2(n, vlam(|t| ap2(node(), t.clone(), t)), leaf()))
}

fn quote(level: i64, v: &Value) -> Term {
    match v {
        Value::VVar(x) => Term::Var(level - x - 1),
        Value::VApp(t, u) => Term::App(Rc::new(quote(level, t)), Rc::new(quote(level, u))),
        Value::VLam(f) => {
            let body = f(Value::VVar(level));
            Term::Lam(Rc::new(quote(level + 1, &body)))
        }
    }
}

fn quote0(v: &Value) -> Term {
    quote(0, v)
}

fn force(t: &Term) -> i64 {
    match t {
        Term::Var(_) => 0,
        Term::App(t1, t2) => force(t1) + force(t2),
        Term::Lam(body) => 1 + force(body),
    }
}

fn main() {
    let n10 = ap2(mul(), n2(), n5());
    let n20 = ap2(mul(), n2(), n10);
    let n21 = suc(n20);
    let n22 = suc(n21);

    let tree8m = ap(full_tree(), n22);
    let quoted = quote0(&tree8m);
    let lam_count = force(&quoted);

    if lam_count != 16_777_214 {
        eprintln!("FAIL: expected 16777214, got {}", lam_count);
        std::process::exit(1);
    }
}
