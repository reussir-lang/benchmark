// Persistent finger tree. The constructors and snoc/view-left rotations
// mirror Data.FingerTree; Rc path-copying keeps every prior root valid.

use std::rc::Rc;

enum Elem {
    Value(i64),
    Node2(ElemRef, ElemRef),
    Node3(ElemRef, ElemRef, ElemRef),
}

type ElemRef = Rc<Elem>;

enum Digit {
    One(ElemRef),
    Two(ElemRef, ElemRef),
    Three(ElemRef, ElemRef, ElemRef),
    Four(ElemRef, ElemRef, ElemRef, ElemRef),
}

enum Tree {
    Empty,
    Single(ElemRef),
    Deep(Digit, TreeRef, Digit),
}

type TreeRef = Rc<Tree>;

fn empty() -> TreeRef { Rc::new(Tree::Empty) }
fn value(value: i64) -> ElemRef { Rc::new(Elem::Value(value)) }
fn node3(a: ElemRef, b: ElemRef, c: ElemRef) -> ElemRef { Rc::new(Elem::Node3(a, b, c)) }

fn node_to_digit(node: &ElemRef) -> Digit {
    match node.as_ref() {
        Elem::Node2(a, b) => Digit::Two(a.clone(), b.clone()),
        Elem::Node3(a, b, c) => Digit::Three(a.clone(), b.clone(), c.clone()),
        Elem::Value(_) => panic!("invalid middle-tree element"),
    }
}

fn digit_to_tree(digit: &Digit) -> TreeRef {
    match digit {
        Digit::One(a) => Rc::new(Tree::Single(a.clone())),
        Digit::Two(a, b) => Rc::new(Tree::Deep(
            Digit::One(a.clone()), empty(), Digit::One(b.clone()),
        )),
        Digit::Three(a, b, c) => Rc::new(Tree::Deep(
            Digit::Two(a.clone(), b.clone()), empty(), Digit::One(c.clone()),
        )),
        Digit::Four(a, b, c, d) => Rc::new(Tree::Deep(
            Digit::Two(a.clone(), b.clone()), empty(), Digit::Two(c.clone(), d.clone()),
        )),
    }
}

fn snoc(tree: &TreeRef, x: ElemRef) -> TreeRef {
    match tree.as_ref() {
        Tree::Empty => Rc::new(Tree::Single(x)),
        Tree::Single(a) => Rc::new(Tree::Deep(
            Digit::One(a.clone()), empty(), Digit::One(x),
        )),
        Tree::Deep(prefix, middle, Digit::Four(a, b, c, d)) => Rc::new(Tree::Deep(
            clone_digit(prefix),
            snoc(middle, node3(a.clone(), b.clone(), c.clone())),
            Digit::Two(d.clone(), x),
        )),
        Tree::Deep(prefix, middle, Digit::One(a)) => Rc::new(Tree::Deep(
            clone_digit(prefix), middle.clone(), Digit::Two(a.clone(), x),
        )),
        Tree::Deep(prefix, middle, Digit::Two(a, b)) => Rc::new(Tree::Deep(
            clone_digit(prefix), middle.clone(), Digit::Three(a.clone(), b.clone(), x),
        )),
        Tree::Deep(prefix, middle, Digit::Three(a, b, c)) => Rc::new(Tree::Deep(
            clone_digit(prefix), middle.clone(), Digit::Four(a.clone(), b.clone(), c.clone(), x),
        )),
    }
}

fn clone_digit(digit: &Digit) -> Digit {
    match digit {
        Digit::One(a) => Digit::One(a.clone()),
        Digit::Two(a, b) => Digit::Two(a.clone(), b.clone()),
        Digit::Three(a, b, c) => Digit::Three(a.clone(), b.clone(), c.clone()),
        Digit::Four(a, b, c, d) => Digit::Four(a.clone(), b.clone(), c.clone(), d.clone()),
    }
}

fn view_left(tree: &TreeRef) -> Option<(ElemRef, TreeRef)> {
    match tree.as_ref() {
        Tree::Empty => None,
        Tree::Single(x) => Some((x.clone(), empty())),
        Tree::Deep(Digit::One(x), middle, suffix) => {
            let rest = match view_left(middle) {
                None => digit_to_tree(suffix),
                Some((node, middle_rest)) => Rc::new(Tree::Deep(
                    node_to_digit(&node), middle_rest, clone_digit(suffix),
                )),
            };
            Some((x.clone(), rest))
        }
        Tree::Deep(Digit::Two(a, b), middle, suffix) => Some((
            a.clone(),
            Rc::new(Tree::Deep(Digit::One(b.clone()), middle.clone(), clone_digit(suffix))),
        )),
        Tree::Deep(Digit::Three(a, b, c), middle, suffix) => Some((
            a.clone(),
            Rc::new(Tree::Deep(
                Digit::Two(b.clone(), c.clone()), middle.clone(), clone_digit(suffix),
            )),
        )),
        Tree::Deep(Digit::Four(a, b, c, d), middle, suffix) => Some((
            a.clone(),
            Rc::new(Tree::Deep(
                Digit::Three(b.clone(), c.clone(), d.clone()), middle.clone(), clone_digit(suffix),
            )),
        )),
    }
}

fn main() {
    const P: i64 = 1_000_000_007;
    let mut tree = empty();
    for x in 0..65_536 { tree = snoc(&tree, value(x)); }
    let mut checksum = 0;
    for round in 0..1_000_000i64 {
        let (element, rest) = view_left(&tree).expect("non-empty tree");
        let x = match element.as_ref() { Elem::Value(x) => *x, _ => unreachable!() };
        checksum = (checksum + x) % P;
        tree = snoc(&rest, value((x + round + 1) % P));
    }
    while let Some((element, rest)) = view_left(&tree) {
        let x = match element.as_ref() { Elem::Value(x) => *x, _ => unreachable!() };
        checksum = (checksum + x) % P;
        tree = rest;
    }
    if checksum != 66_797_929 {
        eprintln!("FAIL: expected 66797929, got {}", checksum);
        std::process::exit(1);
    }
}
