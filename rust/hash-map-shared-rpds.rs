// Std-collection workload on Rust's de-facto standard *persistent* hash
// map (rpds::HashTrieMap — an Rc-linked HAMT, the same representation
// family as Reussir's std HashMap, hashed with the std RandomState
// SipHash). Updates use the `_mut` methods: rpds's owned-update path,
// copy-on-write when shared and in place when unique — the analog of
// Reussir's uniqueness-driven reuse for this linearly threaded
// workload. Same Zipfian mixed-op workload, eight-slot version
// retention, and checksum as hash-map-shared.rs; parking a version here is an
// O(1) handle clone, and later `_mut` updates path-copy while it lives.

extern crate rpds;

use rpds::HashTrieMap;

const OPS: i64 = 2_000_000;
const EXPECTED: i64 = 317327888655435;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: HashTrieMap<i64, i64> = HashTrieMap::new();
    let mut ring: Vec<HashTrieMap<i64, i64>> = vec![HashTrieMap::new(); 8];
    let mut x = 1i64;
    let mut acc = 0i64;
    for i in 0..OPS {
        x = lcg(x);
        let op = x % 16;
        x = lcg(x);
        let s = x % 24;
        x = lcg(x);
        let k = (1i64 << s) + (x % (1i64 << s));
        if op < 9 {
            m.insert_mut(k, i);
        } else if op < 14 {
            m.remove_mut(&k);
        } else {
            acc += m.get(&k).copied().unwrap_or(-1);
        }
        x = lcg(x);
        if x % 8192 == 0 {
            ring[((x / 8192) % 8) as usize] = m.clone();
        }
    }
    let fold_one = |m: &HashTrieMap<i64, i64>| -> i64 {
        m.iter().map(|(k, v)| k * 31 + v).sum::<i64>() + 7 * (m.size() as i64)
    };
    let result = acc + fold_one(&m) + ring.iter().map(&fold_one).sum::<i64>();
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
