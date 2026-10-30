// rbtree with num-bigint keys and values: insert the keys 2499999 .. 0, each
// mapped to itself, then sum the values. Every key and value is a small
// integer, so this measures the immediate path of big-integer arithmetic.
extern crate num_bigint;

use num_bigint::BigUint;
use std::rc::Rc;

#[derive(Clone, Copy, PartialEq)]
enum Color { Red, Black }

#[derive(Clone)]
enum Tree {
    Branch(Color, Rc<Tree>, BigUint, BigUint, Rc<Tree>),
    Leaf,
}

fn is_red(t: &Tree) -> bool {
    matches!(t, Tree::Branch(Color::Red, _, _, _, _))
}

fn branch(c: Color, l: Rc<Tree>, k: BigUint, v: BigUint, r: Rc<Tree>) -> Tree {
    Tree::Branch(c, l, k, v, r)
}

fn rc(t: Tree) -> Rc<Tree> {
    Rc::new(t)
}

fn balance_left(l: Tree, k: BigUint, v: BigUint, r: Rc<Tree>) -> Tree {
    match l {
        Tree::Branch(_, ref lx, ref kx, ref vx, ref rx)
            if matches!(lx.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, ll, kk, vv, rr) = lx.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, ll.clone(), kk.clone(), vv.clone(), rr.clone())),
                    kx.clone(), vx.clone(),
                    rc(branch(Color::Black, rx.clone(), k, v, r)))
            } else { unreachable!() }
        }
        Tree::Branch(_, ref ly, ref ky, ref vy, ref rx)
            if matches!(rx.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, lx, kx, vx, rxx) = rx.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, ly.clone(), ky.clone(), vy.clone(), lx.clone())),
                    kx.clone(), vx.clone(),
                    rc(branch(Color::Black, rxx.clone(), k, v, r)))
            } else { unreachable!() }
        }
        Tree::Branch(_, lx, kx, vx, rx) =>
            branch(Color::Black, rc(branch(Color::Red, lx, kx, vx, rx)), k, v, r),
        Tree::Leaf => Tree::Leaf,
    }
}

fn balance_right(l: Rc<Tree>, k: BigUint, v: BigUint, r: Tree) -> Tree {
    match r {
        Tree::Branch(_, ref lx, ref kx, ref vx, ref ry)
            if matches!(lx.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, ll, kk, vv, rr) = lx.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, l, k, v, ll.clone())),
                    kk.clone(), vv.clone(),
                    rc(branch(Color::Black, rr.clone(), kx.clone(), vx.clone(), ry.clone())))
            } else { unreachable!() }
        }
        Tree::Branch(_, ref lx, ref kx, ref vx, ref ry)
            if matches!(ry.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, ly, ky, vy, rr) = ry.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, l, k, v, lx.clone())),
                    kx.clone(), vx.clone(),
                    rc(branch(Color::Black, ly.clone(), ky.clone(), vy.clone(), rr.clone())))
            } else { unreachable!() }
        }
        Tree::Branch(_, lx, kx, vx, rx) =>
            branch(Color::Black, l, k, v, rc(branch(Color::Red, lx, kx, vx, rx))),
        Tree::Leaf => Tree::Leaf,
    }
}

fn ins(t: &Tree, k: BigUint, v: BigUint) -> Tree {
    match t {
        Tree::Branch(Color::Red, l, kx, vx, r) => {
            if k < *kx {
                branch(Color::Red, rc(ins(l, k, v)), kx.clone(), vx.clone(), r.clone())
            } else if k > *kx {
                branch(Color::Red, l.clone(), kx.clone(), vx.clone(), rc(ins(r, k, v)))
            } else {
                branch(Color::Red, l.clone(), k, v, r.clone())
            }
        }
        Tree::Branch(Color::Black, l, kx, vx, r) => {
            if k < *kx {
                if is_red(l) {
                    balance_left(ins(l, k, v), kx.clone(), vx.clone(), r.clone())
                } else {
                    branch(Color::Black, rc(ins(l, k, v)), kx.clone(), vx.clone(), r.clone())
                }
            } else if k > *kx {
                if is_red(r) {
                    balance_right(l.clone(), kx.clone(), vx.clone(), ins(r, k, v))
                } else {
                    branch(Color::Black, l.clone(), kx.clone(), vx.clone(), rc(ins(r, k, v)))
                }
            } else {
                branch(Color::Black, l.clone(), k, v, r.clone())
            }
        }
        Tree::Leaf => branch(Color::Red, rc(Tree::Leaf), k, v, rc(Tree::Leaf)),
    }
}

fn set_black(t: Tree) -> Tree {
    match t {
        Tree::Branch(_, l, k, v, r) => branch(Color::Black, l, k, v, r),
        Tree::Leaf => Tree::Leaf,
    }
}

fn insert(t: &Tree, k: BigUint, v: BigUint) -> Tree {
    set_black(ins(t, k, v))
}

fn make_tree_aux(n: u64, t: Tree) -> Tree {
    if n == 0 {
        t
    } else {
        let n1 = n - 1;
        let k = BigUint::from(n1);
        let t2 = insert(&t, k.clone(), k);
        make_tree_aux(n1, t2)
    }
}

fn make_tree(n: u64) -> Tree {
    make_tree_aux(n, Tree::Leaf)
}

fn fold(t: &Tree, b: BigUint) -> BigUint {
    match t {
        Tree::Branch(_, l, _k, v, r) => {
            let left = fold(l, b);
            fold(r, left + v)
        }
        Tree::Leaf => b,
    }
}

fn main() {
    let p = fold(&make_tree(2_500_000), BigUint::ZERO);
    if p != BigUint::from(3_124_998_750_000u64) {
        eprintln!("FAIL: expected 3124998750000, got {}", p);
        std::process::exit(1);
    }
}
