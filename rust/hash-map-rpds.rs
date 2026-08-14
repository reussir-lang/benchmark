// Std-collection workload on Rust's de-facto standard *persistent* hash
// map (rpds::HashTrieMap — an Rc-linked HAMT, the same representation
// family as Reussir's std HashMap, hashed with the std RandomState
// SipHash). Updates use the `_mut` methods: rpds's owned-update path,
// copy-on-write when shared and in place when unique — the analog of
// Reussir's uniqueness-driven reuse for this linearly threaded
// workload. Same Zipfian mixed-op workload and checksum as hash-map.rs.

extern crate rpds;

use rpds::HashTrieMap;

const OPS: i64 = 8_000_000;
const EXPECTED: i64 = 144585704074329;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: HashTrieMap<i64, i64> = HashTrieMap::new();
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
    }
    let fold: i64 = m.iter().map(|(k, v)| k * 31 + v).sum();
    let result = acc + fold + 7 * (m.size() as i64);
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
