// rbtree-lookup: rbtree's tree code with lookups. Insert 1M scattered keys
// and after every insert look up 8 keys in the current tree, which stays
// live for the next insert. The inserts path-copy through `Rc`; the lookups
// only read the tree.

use std::rc::Rc;

#[derive(Clone, Copy, PartialEq)]
enum Color { Red, Black }

#[derive(Clone)]
enum Tree {
    Branch(Color, Rc<Tree>, i64, bool, Rc<Tree>),
    Leaf,
}

fn is_red(t: &Tree) -> bool {
    matches!(t, Tree::Branch(Color::Red, _, _, _, _))
}

fn branch(c: Color, l: Rc<Tree>, k: i64, v: bool, r: Rc<Tree>) -> Tree {
    Tree::Branch(c, l, k, v, r)
}

fn rc(t: Tree) -> Rc<Tree> {
    Rc::new(t)
}

fn balance_left(l: Tree, k: i64, v: bool, r: Rc<Tree>) -> Tree {
    match l {
        Tree::Branch(_, ref lx, ref kx, ref vx, ref rx)
            if matches!(lx.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, ll, kk, vv, rr) = lx.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, ll.clone(), *kk, *vv, rr.clone())),
                    *kx, *vx,
                    rc(branch(Color::Black, rx.clone(), k, v, r)))
            } else { unreachable!() }
        }
        Tree::Branch(_, ref ly, ref ky, ref vy, ref rx)
            if matches!(rx.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, lx, kx, vx, rxx) = rx.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, ly.clone(), *ky, *vy, lx.clone())),
                    *kx, *vx,
                    rc(branch(Color::Black, rxx.clone(), k, v, r)))
            } else { unreachable!() }
        }
        Tree::Branch(_, lx, kx, vx, rx) =>
            branch(Color::Black, rc(branch(Color::Red, lx, kx, vx, rx)), k, v, r),
        Tree::Leaf => Tree::Leaf,
    }
}

fn balance_right(l: Rc<Tree>, k: i64, v: bool, r: Tree) -> Tree {
    match r {
        Tree::Branch(_, ref lx, ref kx, ref vx, ref ry)
            if matches!(lx.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, ll, kk, vv, rr) = lx.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, l, k, v, ll.clone())),
                    *kk, *vv,
                    rc(branch(Color::Black, rr.clone(), *kx, *vx, ry.clone())))
            } else { unreachable!() }
        }
        Tree::Branch(_, ref lx, ref kx, ref vx, ref ry)
            if matches!(ry.as_ref(), Tree::Branch(Color::Red, _, _, _, _)) =>
        {
            if let Tree::Branch(_, ly, ky, vy, rr) = ry.as_ref() {
                branch(Color::Red,
                    rc(branch(Color::Black, l, k, v, lx.clone())),
                    *kx, *vx,
                    rc(branch(Color::Black, ly.clone(), *ky, *vy, rr.clone())))
            } else { unreachable!() }
        }
        Tree::Branch(_, lx, kx, vx, rx) =>
            branch(Color::Black, l, k, v, rc(branch(Color::Red, lx, kx, vx, rx))),
        Tree::Leaf => Tree::Leaf,
    }
}

fn ins(t: &Tree, k: i64, v: bool) -> Tree {
    match t {
        Tree::Branch(Color::Red, l, kx, vx, r) => {
            if k < *kx {
                branch(Color::Red, rc(ins(l, k, v)), *kx, *vx, r.clone())
            } else if k > *kx {
                branch(Color::Red, l.clone(), *kx, *vx, rc(ins(r, k, v)))
            } else {
                branch(Color::Red, l.clone(), k, v, r.clone())
            }
        }
        Tree::Branch(Color::Black, l, kx, vx, r) => {
            if k < *kx {
                if is_red(l) {
                    balance_left(ins(l, k, v), *kx, *vx, r.clone())
                } else {
                    branch(Color::Black, rc(ins(l, k, v)), *kx, *vx, r.clone())
                }
            } else if k > *kx {
                if is_red(r) {
                    balance_right(l.clone(), *kx, *vx, ins(r, k, v))
                } else {
                    branch(Color::Black, l.clone(), *kx, *vx, rc(ins(r, k, v)))
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

fn insert(t: &Tree, k: i64, v: bool) -> Tree {
    set_black(ins(t, k, v))
}

fn get(t: &Tree, k: i64) -> bool {
    match t {
        Tree::Branch(_, l, kx, _, r) => {
            if k < *kx {
                get(l, k)
            } else if k > *kx {
                get(r, k)
            } else {
                true
            }
        }
        Tree::Leaf => false,
    }
}

fn probe(i: i64, t: &Tree, mut hits: i64) -> i64 {
    for j in (1..=8).rev() {
        if get(t, (i * 31 + j * 7919) % 2000000) {
            hits += 1;
        }
    }
    hits
}

fn main() {
    let n: i64 = 1_000_000;
    let mut t = Tree::Leaf;
    let mut hits = 0;
    for i in 0..n {
        t = insert(&t, (i * 7919) % n, true);
        hits = probe(i, &t, hits);
    }
    if hits != 2059798 {
        eprintln!("FAIL: expected 2059798, got {}", hits);
        std::process::exit(1);
    }
}
