// list-membership: 40000 membership queries against one 10000-element list
// that the caller keeps between queries (reussir-lang/reussir#762). Every
// query only reads the list; half of them miss and walk all of it. The list
// is a persistent cons list shared through `Rc`.

use std::rc::Rc;

enum List {
    Nil,
    Cons(i64, Rc<List>),
}

fn mem(x: i64, xs: &List) -> bool {
    match xs {
        List::Nil => false,
        List::Cons(y, ys) => {
            if x == *y {
                true
            } else {
                mem(x, ys)
            }
        }
    }
}

// [1 .. n]
fn build(n: i64) -> Rc<List> {
    let mut acc = Rc::new(List::Nil);
    for k in (1..=n).rev() {
        acc = Rc::new(List::Cons(k, acc));
    }
    acc
}

fn search(queries: i64, n: i64, xs: &Rc<List>) -> i64 {
    let mut hits = 0;
    for q in (1..=queries).rev() {
        let x = (q * 7919) % (2 * n) + 1;
        if mem(x, xs) {
            hits += 1;
        }
    }
    hits
}

fn main() {
    let xs = build(10000);
    let hits = search(40000, 10000, &xs);
    if hits != 20000 {
        eprintln!("FAIL: expected 20000, got {}", hits);
        std::process::exit(1);
    }
}
