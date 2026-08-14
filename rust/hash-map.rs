// Std-collection workload on Rust's std hash map
// (std::collections::HashMap, mutable in place, default SipHash-1-3
// hasher). Same workload and checksum as ordered-map.rs; the checksum
// is iteration-order independent so the representations agree.

use std::collections::HashMap;

const KEYSPACE: i64 = 524287;
const BUILD: i64 = 1_000_000;
const CHURN: i64 = 1_000_000;
const LOOKUPS: i64 = 1_000_000;
const EXPECTED: i64 = 105140861851414131;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: HashMap<i64, i64> = HashMap::new();
    let mut x = 1i64;
    for i in 0..BUILD {
        x = lcg(x);
        m.insert(x % KEYSPACE, i);
    }
    for i in 0..CHURN {
        x = lcg(x);
        let k = x % KEYSPACE;
        if x % 4 == 3 {
            m.remove(&k);
        } else {
            m.insert(k, BUILD + i);
        }
    }
    let mut acc = 0i64;
    for _ in 0..LOOKUPS {
        x = lcg(x);
        acc += m.get(&(x % KEYSPACE)).copied().unwrap_or(-1);
    }
    let fold: i64 = m.iter().map(|(k, v)| k * 1000003 + v).sum();
    let result = acc + fold + 7 * (m.len() as i64);
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
