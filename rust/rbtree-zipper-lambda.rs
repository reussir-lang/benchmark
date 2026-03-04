use std::rc::Rc;

#[derive(Clone, Copy, PartialEq)]
enum Color { Red, Black }

#[derive(Clone)]
enum Tree {
    Branch(Color, Rc<Tree>, i64, bool, Rc<Tree>),
    Leaf,
}

#[derive(Clone)]
enum Zipper {
    NodeR(Color, Rc<Tree>, i64, bool, Rc<Zipper>),
    NodeL(Color, Rc<Zipper>, i64, bool, Rc<Tree>),
    Done,
}

fn branch(c: Color, l: Rc<Tree>, k: i64, v: bool, r: Rc<Tree>) -> Tree {
    Tree::Branch(c, l, k, v, r)
}

fn rc_t(t: Tree) -> Rc<Tree> { Rc::new(t) }
fn rc_z(z: Zipper) -> Rc<Zipper> { Rc::new(z) }

fn move_up(z: &Zipper, t: Tree) -> Tree {
    match z {
        Zipper::NodeR(c, l, k, v, z1) =>
            move_up(z1, branch(*c, l.clone(), *k, *v, rc_t(t))),
        Zipper::NodeL(c, z1, k, v, r) =>
            move_up(z1, branch(*c, rc_t(t), *k, *v, r.clone())),
        Zipper::Done => t,
    }
}

fn balance_red(z: &Zipper, l: Rc<Tree>, k: i64, v: bool, r: Rc<Tree>) -> Tree {
    match z {
        Zipper::NodeR(Color::Black, l1, k1, v1, z1) =>
            move_up(z1, branch(Color::Black, l1.clone(), *k1, *v1,
                rc_t(branch(Color::Red, l, k, v, r)))),

        Zipper::NodeL(Color::Black, z1, k1, v1, r1) =>
            move_up(z1, branch(Color::Black,
                rc_t(branch(Color::Red, l, k, v, r)),
                *k1, *v1, r1.clone())),

        Zipper::NodeR(Color::Red, l1, k1, v1, z1) => match z1.as_ref() {
            Zipper::NodeR(_, l2, k2, v2, z2) =>
                balance_red(z2,
                    rc_t(branch(Color::Black, l2.clone(), *k2, *v2, l1.clone())),
                    *k1, *v1,
                    rc_t(branch(Color::Black, l, k, v, r))),
            Zipper::NodeL(_, z2, k2, v2, r2) =>
                balance_red(z2,
                    rc_t(branch(Color::Black, l1.clone(), *k1, *v1, l.clone())),
                    k, v,
                    rc_t(branch(Color::Black, r.clone(), *k2, *v2, r2.clone()))),
            Zipper::Done =>
                branch(Color::Black, l1.clone(), *k1, *v1,
                    rc_t(branch(Color::Red, l, k, v, r))),
        },

        Zipper::NodeL(Color::Red, z1, k1, v1, r1) => match z1.as_ref() {
            Zipper::NodeR(_, l2, k2, v2, z2) =>
                balance_red(z2,
                    rc_t(branch(Color::Black, l2.clone(), *k2, *v2, l.clone())),
                    k, v,
                    rc_t(branch(Color::Black, r.clone(), *k1, *v1, r1.clone()))),
            Zipper::NodeL(_, z2, k2, v2, r2) =>
                balance_red(z2,
                    rc_t(branch(Color::Black, l, k, v, r)),
                    *k1, *v1,
                    rc_t(branch(Color::Black, r1.clone(), *k2, *v2, r2.clone()))),
            Zipper::Done =>
                branch(Color::Black,
                    rc_t(branch(Color::Red, l, k, v, r)),
                    *k1, *v1, r1.clone()),
        },

        Zipper::Done => branch(Color::Black, l, k, v, r),
    }
}

fn ins(t: &Tree, k: i64, v: bool, z: Rc<Zipper>, cmp: &dyn Fn(i64, i64) -> i64) -> Tree {
    match t {
        Tree::Branch(c, l, kx, vx, r) => {
            let delta = cmp(k, *kx);
            if delta < 0 {
                ins(l, k, v, rc_z(Zipper::NodeL(*c, z, *kx, *vx, r.clone())), cmp)
            } else if delta > 0 {
                ins(r, k, v, rc_z(Zipper::NodeR(*c, l.clone(), *kx, *vx, z)), cmp)
            } else {
                move_up(&z, branch(*c, l.clone(), *kx, *vx, r.clone()))
            }
        }
        Tree::Leaf => balance_red(&z, rc_t(Tree::Leaf), k, v, rc_t(Tree::Leaf)),
    }
}

fn insert(t: &Tree, k: i64, v: bool) -> Tree {
    ins(t, k, v, rc_z(Zipper::Done), &|a, b| b - a)
}

fn fold(t: &Tree, b: i64) -> i64 {
    match t {
        Tree::Branch(_, l, _k, v, r) => {
            let left = fold(l, b);
            let mid = if *v { left + 1 } else { left };
            fold(r, mid)
        }
        Tree::Leaf => b,
    }
}

fn make_tree(n: i64, t: Tree) -> Tree {
    if n <= 0 {
        t
    } else {
        let m = n - 1;
        let t2 = insert(&t, m, m % 10 == 0);
        make_tree(m, t2)
    }
}

fn fold_test(n: i64) -> i64 {
    let t = make_tree(n, Tree::Leaf);
    fold(&t, 0)
}

fn main() {
    let n: i64 = 4_200_000;
    let p = fold_test(n);
    if p != 420_000 {
        eprintln!("FAIL: expected 420000, got {}", p);
        std::process::exit(1);
    }
}
