// Std-collection workload on Rust's std hash map
// (std::collections::HashMap, mutable in place, default SipHash-1-3
// hasher). Large and broad: keys are raw MINSTD draws, uniform over
// [1, 2^31-2]; MINSTD is a full-period permutation, so fresh draws
// never repeat, and removals plus the hit half of the lookups replay
// the build key stream through a second MINSTD state. Build 4M
// inserts, churn 2M rounds, 2M lookups alternating replayed hits and
// fresh misses. Final size 4,999,834; the checksum is iteration-order
// independent so all representations agree.

use std::collections::HashMap;

const BUILD: i64 = 4_000_000;
const CHURN: i64 = 2_000_000;
const LOOKUPS: i64 = 2_000_000;
const EXPECTED: i64 = 166401892080070584;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: HashMap<i64, i64> = HashMap::new();
    let mut x = 1i64;
    for i in 0..BUILD {
        x = lcg(x);
        m.insert(x, i);
    }
    let mut r = 1i64;
    for i in 0..CHURN {
        x = lcg(x);
        if x % 4 == 3 {
            r = lcg(r);
            m.remove(&r);
        } else {
            m.insert(x, BUILD + i);
        }
    }
    let mut acc = 0i64;
    for _ in 0..LOOKUPS {
        x = lcg(x);
        let k = if x % 2 == 0 {
            r = lcg(r);
            r
        } else {
            x
        };
        acc += m.get(&k).copied().unwrap_or(-1);
    }
    let fold: i64 = m.iter().map(|(k, v)| k * 31 + v).sum();
    let result = acc + fold + 7 * (m.len() as i64);
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
