use std::rc::Rc;

enum List {
    Nil,
    Cons(i64, Rc<List>),
}

type ListRef = Rc<List>;

enum Rotation {
    Idle,
    Reversing(i64, ListRef, ListRef, ListRef, ListRef),
    Appending(i64, ListRef, ListRef),
    Done(ListRef),
}

struct Queue {
    len_front: i64,
    front: ListRef,
    state: Rotation,
    len_rear: i64,
    rear: ListRef,
}

fn nil() -> ListRef { Rc::new(List::Nil) }
fn cons(value: i64, rest: ListRef) -> ListRef { Rc::new(List::Cons(value, rest)) }

fn exec(state: Rotation) -> Rotation {
    match state {
        Rotation::Reversing(ok, front, front_rev, rear, rear_rev) => {
            match (front.as_ref(), rear.as_ref()) {
                (List::Cons(x, f), List::Cons(y, r)) => Rotation::Reversing(
                    ok + 1,
                    f.clone(),
                    cons(*x, front_rev),
                    r.clone(),
                    cons(*y, rear_rev),
                ),
                (List::Nil, List::Cons(y, r)) if matches!(r.as_ref(), List::Nil) => {
                    Rotation::Appending(ok, front_rev, cons(*y, rear_rev))
                }
                _ => Rotation::Reversing(ok, front, front_rev, rear, rear_rev),
            }
        }
        Rotation::Appending(0, _, rear_rev) => Rotation::Done(rear_rev),
        Rotation::Appending(ok, front_rev, rear_rev) => match front_rev.as_ref() {
            List::Cons(x, rest) => Rotation::Appending(
                ok - 1,
                rest.clone(),
                cons(*x, rear_rev),
            ),
            List::Nil => Rotation::Appending(ok, front_rev, rear_rev),
        },
        state => state,
    }
}

fn invalidate(state: Rotation) -> Rotation {
    match state {
        Rotation::Reversing(ok, f, f2, r, r2) => Rotation::Reversing(ok - 1, f, f2, r, r2),
        Rotation::Appending(0, _, rear_rev) => match rear_rev.as_ref() {
            List::Cons(_, rest) => Rotation::Done(rest.clone()),
            List::Nil => Rotation::Appending(0, nil(), rear_rev),
        },
        Rotation::Appending(ok, f2, r2) => Rotation::Appending(ok - 1, f2, r2),
        state => state,
    }
}

fn exec2(mut queue: Queue) -> Queue {
    match exec(exec(queue.state)) {
        Rotation::Done(front) => {
            queue.front = front;
            queue.state = Rotation::Idle;
        }
        state => queue.state = state,
    }
    queue
}

fn check(queue: Queue) -> Queue {
    if queue.len_rear <= queue.len_front {
        exec2(queue)
    } else {
        let state = Rotation::Reversing(
            0,
            queue.front.clone(),
            nil(),
            queue.rear,
            nil(),
        );
        exec2(Queue {
            len_front: queue.len_front + queue.len_rear,
            front: queue.front,
            state,
            len_rear: 0,
            rear: nil(),
        })
    }
}

fn snoc(queue: Queue, value: i64) -> Queue {
    let rear = cons(value, queue.rear);
    check(Queue { len_rear: queue.len_rear + 1, rear, ..queue })
}

fn uncons(queue: Queue) -> (i64, Queue) {
    match queue.front.as_ref() {
        List::Cons(value, front) => {
            let value = *value;
            let front = front.clone();
            let state = invalidate(queue.state);
            let rest = check(Queue {
                len_front: queue.len_front - 1,
                front,
                state,
                len_rear: queue.len_rear,
                rear: queue.rear,
            });
            (value, rest)
        }
        List::Nil => panic!("empty queue"),
    }
}

fn main() {
    const P: i64 = 1_000_000_007;
    let mut queue = Queue { len_front: 0, front: nil(), state: Rotation::Idle, len_rear: 0, rear: nil() };
    for value in 0..65_536 { queue = snoc(queue, value); }
    let mut checksum = 0;
    for round in 0..1_000_000i64 {
        let (value, rest) = uncons(queue);
        checksum = (checksum + value) % P;
        queue = snoc(rest, (value + round + 1) % P);
    }
    for _ in 0..65_536 {
        let (value, rest) = uncons(queue);
        checksum = (checksum + value) % P;
        queue = rest;
    }
    if checksum != 66_797_929 {
        eprintln!("FAIL: expected 66797929, got {}", checksum);
        std::process::exit(1);
    }
}
