// Std-collection workload on Rust's de-facto standard *persistent* hash
// map (rpds::HashTrieMap — an Rc-linked HAMT, the same representation
// family as Reussir's std HashMap, hashed with the std RandomState
// SipHash). Updates use the `_mut` methods: rpds's owned-update path,
// copy-on-write when shared and in place when unique — the analog of
// Reussir's uniqueness-driven reuse for this linearly threaded
// workload. Same workload and checksum as hash-map.rs.

extern crate rpds;

use rpds::HashTrieMap;

const KEYSPACE: i64 = 524287;
const BUILD: i64 = 1_000_000;
const CHURN: i64 = 1_000_000;
const LOOKUPS: i64 = 1_000_000;
const EXPECTED: i64 = 105140861851414131;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: HashTrieMap<i64, i64> = HashTrieMap::new();
    let mut x = 1i64;
    for i in 0..BUILD {
        x = lcg(x);
        m.insert_mut(x % KEYSPACE, i);
    }
    for i in 0..CHURN {
        x = lcg(x);
        let k = x % KEYSPACE;
        if x % 4 == 3 {
            m.remove_mut(&k);
        } else {
            m.insert_mut(k, BUILD + i);
        }
    }
    let mut acc = 0i64;
    for _ in 0..LOOKUPS {
        x = lcg(x);
        acc += m.get(&(x % KEYSPACE)).copied().unwrap_or(-1);
    }
    let fold: i64 = m.iter().map(|(k, v)| k * 1000003 + v).sum();
    let result = acc + fold + 7 * (m.size() as i64);
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
