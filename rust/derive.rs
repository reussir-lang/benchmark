#![allow(unreachable_patterns)]

use std::rc::Rc;

#[derive(Clone)]
enum Expr {
    Val(i64),
    Var(i64),
    Add(Rc<Expr>, Rc<Expr>),
    Mul(Rc<Expr>, Rc<Expr>),
    Pow(Rc<Expr>, Rc<Expr>),
    Ln(Rc<Expr>),
}

fn rc(e: Expr) -> Rc<Expr> { Rc::new(e) }

fn pown(a: i64, b: i64) -> i64 {
    if b <= 0 {
        if b == 0 { 1 } else { 0 }
    } else {
        a * pown(a, b - 1)
    }
}

fn expr_add(n0: Expr, m0: Expr) -> Expr {
    match (&n0, &m0) {
        (Expr::Val(n), Expr::Val(m)) => Expr::Val(n + m),
        (Expr::Val(n), _) if *n == 0 => m0,
        (Expr::Val(n), Expr::Add(inner_l, f)) => {
            if let Expr::Val(m) = inner_l.as_ref() {
                expr_add(Expr::Val(n + m), f.as_ref().clone())
            } else {
                Expr::Add(rc(n0), rc(m0))
            }
        }
        (Expr::Val(_), _) => {
            match &m0 {
                Expr::Val(0) => n0,
                Expr::Add(inner_l, f) => {
                    if let Expr::Val(m) = inner_l.as_ref() {
                        if let Expr::Val(n) = &n0 {
                            expr_add(Expr::Val(n + m), f.as_ref().clone())
                        } else {
                            Expr::Add(rc(n0), rc(m0))
                        }
                    } else {
                        Expr::Add(rc(n0), rc(m0))
                    }
                }
                _ => Expr::Add(rc(n0), rc(m0)),
            }
        }
        (Expr::Add(_, _), _) => {
            match &m0 {
                Expr::Val(0) => n0,
                _ => {
                    if let Expr::Add(f, g) = n0 {
                        let g_val = g.as_ref().clone();
                        let f_val = f.as_ref().clone();
                        expr_add(f_val, expr_add(g_val, m0))
                    } else {
                        unreachable!()
                    }
                }
            }
        }
        _ => {
            match &m0 {
                Expr::Val(0) => n0,
                Expr::Val(n) => expr_add(Expr::Val(*n), n0),
                Expr::Add(inner_l, g) => {
                    if let Expr::Val(n) = inner_l.as_ref() {
                        expr_add(Expr::Val(*n), expr_add(n0, g.as_ref().clone()))
                    } else {
                        Expr::Add(rc(n0), rc(m0))
                    }
                }
                _ => Expr::Add(rc(n0), rc(m0)),
            }
        }
    }
}

fn expr_mul(n0: Expr, m0: Expr) -> Expr {
    match (&n0, &m0) {
        (Expr::Val(n), Expr::Val(m)) => Expr::Val(n * m),
        (Expr::Val(n), _) if *n == 0 => Expr::Val(0),
        (Expr::Val(n), _) if *n == 1 => m0,
        (Expr::Val(_), _) => {
            match &m0 {
                Expr::Val(0) => Expr::Val(0),
                Expr::Val(1) => n0,
                Expr::Mul(inner_l, f) => {
                    if let (Expr::Val(n), Expr::Val(m)) = (&n0, inner_l.as_ref()) {
                        expr_mul(Expr::Val(n * m), f.as_ref().clone())
                    } else {
                        Expr::Mul(rc(n0), rc(m0))
                    }
                }
                _ => Expr::Mul(rc(n0), rc(m0)),
            }
        }
        (Expr::Mul(_, _), _) => {
            match &m0 {
                Expr::Val(0) => Expr::Val(0),
                Expr::Val(1) => n0,
                _ => {
                    if let Expr::Mul(f, g) = n0 {
                        let g_val = g.as_ref().clone();
                        let f_val = f.as_ref().clone();
                        expr_mul(f_val, expr_mul(g_val, m0))
                    } else {
                        unreachable!()
                    }
                }
            }
        }
        _ => {
            match &m0 {
                Expr::Val(0) => Expr::Val(0),
                Expr::Val(1) => n0,
                Expr::Val(n) => expr_mul(Expr::Val(*n), n0),
                Expr::Mul(inner_l, g) => {
                    if let Expr::Val(n) = inner_l.as_ref() {
                        expr_mul(Expr::Val(*n), expr_mul(n0, g.as_ref().clone()))
                    } else {
                        Expr::Mul(rc(n0), rc(m0))
                    }
                }
                _ => Expr::Mul(rc(n0), rc(m0)),
            }
        }
    }
}

fn expr_pow(m0: Expr, n0: Expr) -> Expr {
    match (&m0, &n0) {
        (Expr::Val(m), Expr::Val(n)) => Expr::Val(pown(*m, *n)),
        (Expr::Val(_), Expr::Val(0)) => Expr::Val(1),
        (Expr::Val(m), Expr::Val(1)) => Expr::Val(*m),
        (Expr::Val(m), _) if *m == 0 => Expr::Val(0),
        (Expr::Val(_), _) => Expr::Pow(rc(m0), rc(n0)),
        _ => {
            match &n0 {
                Expr::Val(0) => Expr::Val(1),
                Expr::Val(1) => m0,
                _ => Expr::Pow(rc(m0), rc(n0)),
            }
        }
    }
}

fn expr_ln(n: Expr) -> Expr {
    match &n {
        Expr::Val(1) => Expr::Val(0),
        _ => Expr::Ln(rc(n)),
    }
}

fn d(x: i64, e: &Expr) -> Expr {
    match e {
        Expr::Val(_) => Expr::Val(0),
        Expr::Var(y) => if x == *y { Expr::Val(1) } else { Expr::Val(0) },
        Expr::Add(f, g) => expr_add(d(x, f), d(x, g)),
        Expr::Mul(f, g) => {
            let f = f.as_ref();
            let g = g.as_ref();
            expr_add(
                expr_mul(f.clone(), d(x, g)),
                expr_mul(g.clone(), d(x, f)),
            )
        }
        Expr::Pow(f, g) => {
            let f = f.as_ref();
            let g = g.as_ref();
            expr_mul(
                expr_pow(f.clone(), g.clone()),
                expr_add(
                    expr_mul(
                        expr_mul(g.clone(), d(x, f)),
                        expr_pow(f.clone(), Expr::Val(-1)),
                    ),
                    expr_mul(expr_ln(f.clone()), d(x, g)),
                ),
            )
        }
        Expr::Ln(f) => {
            let f = f.as_ref();
            expr_mul(d(x, f), expr_pow(f.clone(), Expr::Val(-1)))
        }
    }
}

fn count(e: &Expr) -> i64 {
    match e {
        Expr::Val(_) => 1,
        Expr::Var(_) => 1,
        Expr::Add(f, g) => count(f) + count(g),
        Expr::Mul(f, g) => count(f) + count(g),
        Expr::Pow(f, g) => count(f) + count(g),
        Expr::Ln(f) => count(f),
    }
}

fn nest_aux(_s: i64, n: i64, x: Expr) -> Expr {
    if n == 0 {
        x
    } else {
        let y = d(0, &x);
        nest_aux(_s, n - 1, y)
    }
}

fn derive_test() -> i64 {
    let x = Expr::Var(0);
    let f = expr_pow(x.clone(), x);
    let res = nest_aux(10, 10, f);
    count(&res)
}

fn main() {
    let n = derive_test();
    if n != 40_230_090 {
        eprintln!("FAIL: expected 40230090, got {}", n);
        std::process::exit(1);
    }
}
