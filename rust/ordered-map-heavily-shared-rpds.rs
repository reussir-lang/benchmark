// Std-collection workload on Rust's de-facto standard *persistent*
// ordered map (rpds::RedBlackTreeMap — Rc-linked red-black tree, the
// representation family closest to Reussir's std WavlMap). Updates use
// the `_mut` methods: rpds's owned-update path, which copies-on-write
// through Rc::make_mut when nodes are shared and updates in place when
// unique — the analog of Reussir's uniqueness-driven reuse for this
// linearly threaded workload. Same workload, eight-slot heavily-
// shared-tier version retention, and checksum as
// ordered-map-heavily-shared.rs; parking a version here is
// an O(1) handle clone, and later `_mut` updates path-copy while it
// lives.

extern crate rpds;

use rpds::RedBlackTreeMap;

const KEYSPACE: i64 = 524287;
const BUILD: i64 = 500_000;
const CHURN: i64 = 500_000;
const LOOKUPS: i64 = 500_000;
const EXPECTED: i64 = 861736461765462691;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: RedBlackTreeMap<i64, i64> = RedBlackTreeMap::new();
    let mut ring: Vec<RedBlackTreeMap<i64, i64>> = vec![RedBlackTreeMap::new(); 8];
    let mut x = 1i64;
    for i in 0..BUILD {
        x = lcg(x);
        m.insert_mut(x % KEYSPACE, i);
        x = lcg(x);
        if x % 512 == 0 {
            ring[((x / 512) % 8) as usize] = m.clone();
        }
    }
    for i in 0..CHURN {
        x = lcg(x);
        let k = x % KEYSPACE;
        if x % 4 == 3 {
            m.remove_mut(&k);
        } else {
            m.insert_mut(k, BUILD + i);
        }
        x = lcg(x);
        if x % 512 == 0 {
            ring[((x / 512) % 8) as usize] = m.clone();
        }
    }
    let mut acc = 0i64;
    for _ in 0..LOOKUPS {
        x = lcg(x);
        acc += m.get(&(x % KEYSPACE)).copied().unwrap_or(-1);
    }
    let fold_one = |m: &RedBlackTreeMap<i64, i64>| -> i64 {
        m.iter().map(|(k, v)| k * 1000003 + v).sum::<i64>() + 7 * (m.size() as i64)
    };
    let result = acc + fold_one(&m) + ring.iter().map(&fold_one).sum::<i64>();
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
