// expr-replace: substitution that keeps every unchanged subterm, the shape of
// Lean's Expr.replace. The term is a balanced sum of 256 summands
// Var(i % 16) * P that all share one polynomial P of 4096 literals. Each of
// 100 rounds substitutes one variable of the same retained term. A subterm
// is rebuilt only where the variable occurs, which an occurs check decides
// first (Lean caches that answer in each Expr; here it is recomputed). The
// check reads all of P at every summand it reaches, and P is shared through
// `Rc`.

use std::rc::Rc;

enum Expr {
    Lit(i64),
    Var(i64),
    Add(Rc<Expr>, Rc<Expr>),
    Mul(Rc<Expr>, Rc<Expr>),
}

fn poly(d: i64, s: i64) -> Rc<Expr> {
    if d == 0 {
        Rc::new(Expr::Lit(s % 7 + 1))
    } else {
        let l = poly(d - 1, 2 * s);
        let r = poly(d - 1, 2 * s + 1);
        Rc::new(if d % 2 == 1 { Expr::Add(l, r) } else { Expr::Mul(l, r) })
    }
}

// Summands lo .. hi-1 as a balanced sum.
fn sum(lo: i64, hi: i64, p: &Rc<Expr>) -> Rc<Expr> {
    if hi - lo == 1 {
        Rc::new(Expr::Mul(Rc::new(Expr::Var(lo % 16)), p.clone()))
    } else {
        let mid = (lo + hi) / 2;
        Rc::new(Expr::Add(sum(lo, mid, p), sum(mid, hi, p)))
    }
}

fn occurs(v: i64, e: &Expr) -> bool {
    match e {
        Expr::Lit(_) => false,
        Expr::Var(x) => *x == v,
        Expr::Add(a, b) | Expr::Mul(a, b) => occurs(v, a) || occurs(v, b),
    }
}

fn replace(v: i64, c: i64, e: &Rc<Expr>) -> Rc<Expr> {
    if occurs(v, e) {
        match &**e {
            Expr::Var(_) => Rc::new(Expr::Lit(c)),
            Expr::Add(a, b) => Rc::new(Expr::Add(replace(v, c, a), replace(v, c, b))),
            Expr::Mul(a, b) => Rc::new(Expr::Mul(replace(v, c, a), replace(v, c, b))),
            Expr::Lit(_) => e.clone(),
        }
    } else {
        e.clone()
    }
}

fn leaf(x: &Expr) -> i64 {
    match x {
        Expr::Lit(c) => *c,
        Expr::Var(y) => *y,
        _ => 0,
    }
}

// Sum of the summands' factors (never enters the polynomial).
fn factors(e: &Expr) -> i64 {
    match e {
        Expr::Add(a, b) => factors(a) + factors(b),
        Expr::Mul(x, _) => leaf(x),
        _ => 0,
    }
}

fn main() {
    let base = sum(0, 256, &poly(12, 1));
    let mut acc = 0;
    for k in 0..100 {
        acc += factors(&replace(k % 16, k, &base));
    }
    if acc != 259584 {
        eprintln!("FAIL: expected 259584, got {}", acc);
        std::process::exit(1);
    }
}
