// Std-collection workload on Rust's std ordered map
// (std::collections::BTreeMap, mutable in place). Build 1M MINSTD-keyed
// inserts over a 524287 keyspace, churn 1M insert/remove rounds, sum 1M
// lookups (-1 for a miss), then fold the final map:
// result = lookup-sum + sum(key * 1000003 + value) + 7 * size.

use std::collections::BTreeMap;

const KEYSPACE: i64 = 524287;
const BUILD: i64 = 1_000_000;
const CHURN: i64 = 1_000_000;
const LOOKUPS: i64 = 1_000_000;
const EXPECTED: i64 = 105140861851414131;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: BTreeMap<i64, i64> = BTreeMap::new();
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
