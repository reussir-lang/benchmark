// Persistent Braun min-heap. Every update path-copies through Rc; old roots
// remain valid and no unique-owner mutation is used.

use std::rc::Rc;

enum Heap {
    Node(i64, Rc<Heap>, Rc<Heap>),
    Leaf,
}

type HeapRef = Rc<Heap>;

const P: i64 = 1_000_000_007;

fn leaf() -> HeapRef { Rc::new(Heap::Leaf) }
fn node(value: i64, left: HeapRef, right: HeapRef) -> HeapRef {
    Rc::new(Heap::Node(value, left, right))
}

fn lcg(x: i64) -> i64 { (x * 48_271) % 2_147_483_647 }

fn gauss(mut x: i64) -> (i64, i64) {
    let mut sum = 0;
    for _ in 0..12 {
        x = lcg(x);
        sum += x;
    }
    (sum, x)
}

fn insert(heap: &HeapRef, value: i64) -> HeapRef {
    match heap.as_ref() {
        Heap::Leaf => node(value, leaf(), leaf()),
        Heap::Node(root, left, right) => {
            if value <= *root {
                node(value, insert(right, *root), left.clone())
            } else {
                node(*root, insert(right, value), left.clone())
            }
        }
    }
}

fn down(value: i64, left: &HeapRef, right: &HeapRef) -> HeapRef {
    match (left.as_ref(), right.as_ref()) {
        (Heap::Node(lv, ll, lr), Heap::Node(rv, rl, rr)) => {
            if lv <= rv {
                if value <= *lv {
                    node(value, left.clone(), right.clone())
                } else {
                    node(*lv, down(value, ll, lr), right.clone())
                }
            } else if value <= *rv {
                node(value, left.clone(), right.clone())
            } else {
                node(*rv, left.clone(), down(value, rl, rr))
            }
        }
        (Heap::Node(lv, ll, lr), Heap::Leaf) => {
            if value <= *lv {
                node(value, left.clone(), right.clone())
            } else {
                node(*lv, down(value, ll, lr), right.clone())
            }
        }
        (Heap::Leaf, Heap::Node(rv, rl, rr)) => {
            if value <= *rv {
                node(value, left.clone(), right.clone())
            } else {
                node(*rv, left.clone(), down(value, rl, rr))
            }
        }
        (Heap::Leaf, Heap::Leaf) => node(value, leaf(), leaf()),
    }
}

fn replace_top(heap: &HeapRef, value: i64) -> HeapRef {
    match heap.as_ref() {
        Heap::Node(_, left, right) => down(value, left, right),
        Heap::Leaf => node(value, leaf(), leaf()),
    }
}

fn top(heap: &HeapRef) -> i64 {
    match heap.as_ref() { Heap::Node(value, _, _) => *value, Heap::Leaf => 0 }
}

fn heap_sum(heap: &HeapRef, acc: i64) -> i64 {
    match heap.as_ref() {
        Heap::Leaf => acc,
        Heap::Node(value, left, right) => {
            heap_sum(right, heap_sum(left, (acc + value) % P))
        }
    }
}

fn heap_test(rounds: usize) -> i64 {
    let mut heap = leaf();
    let mut state = 20_260_711;
    for _ in 0..65_535 {
        let (value, next) = gauss(state);
        state = next;
        heap = insert(&heap, value);
    }
    let mut checksum = 0;
    for _ in 0..rounds {
        let (delta, next) = gauss(state);
        state = next;
        let root = top(&heap);
        checksum = (checksum + root) % P;
        heap = replace_top(&heap, root + delta);
    }
    (checksum + heap_sum(&heap, 0)) % P
}

fn main() {
    let result = heap_test(6_500_000);
    if result != 558_972_311 {
        eprintln!("FAIL: expected 558972311, got {}", result);
        std::process::exit(1);
    }
}
