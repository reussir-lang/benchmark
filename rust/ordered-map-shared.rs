// Std-collection workload on Rust's std ordered map
// (std::collections::BTreeMap, mutable in place). Build 500k MINSTD-keyed
// inserts over a 524287 keyspace, churn 1M insert/remove rounds, sum
// 500k lookups (-1 for a miss), then fold the final map:
// result = lookup-sum + sum(key * 1000003 + value) + 7 * size.
//
// During the two mutating phases a second draw per round decides
// retention: when it is divisible by 8192 (265 times over the run) the
// current version is parked in slot (draw / 8192) mod 8 of an
// eight-version ring, where it stays shared until that slot is next
// overwritten. The checksum folds the final map and every ring slot, so
// retained versions stay live and verified. Final size 401,258; each
// ring slot ends holding a ~401k-entry version.
// A mutable map has no structural sharing, so retention is an explicit
// full clone at the event.

use std::collections::BTreeMap;

const KEYSPACE: i64 = 524287;
const BUILD: i64 = 1_000_000;
const CHURN: i64 = 1_000_000;
const LOOKUPS: i64 = 1_000_000;
const EXPECTED: i64 = 948266134564763663;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: BTreeMap<i64, i64> = BTreeMap::new();
    let mut ring: Vec<BTreeMap<i64, i64>> = vec![BTreeMap::new(); 8];
    let mut x = 1i64;
    for i in 0..BUILD {
        x = lcg(x);
        m.insert(x % KEYSPACE, i);
        x = lcg(x);
        if x % 8192 == 0 {
            ring[((x / 8192) % 8) as usize] = m.clone();
        }
    }
    for i in 0..CHURN {
        x = lcg(x);
        let k = x % KEYSPACE;
        if x % 4 == 3 {
            m.remove(&k);
        } else {
            m.insert(k, BUILD + i);
        }
        x = lcg(x);
        if x % 8192 == 0 {
            ring[((x / 8192) % 8) as usize] = m.clone();
        }
    }
    let mut acc = 0i64;
    for _ in 0..LOOKUPS {
        x = lcg(x);
        acc += m.get(&(x % KEYSPACE)).copied().unwrap_or(-1);
    }
    let fold_one = |m: &BTreeMap<i64, i64>| -> i64 {
        m.iter().map(|(k, v)| k * 1000003 + v).sum::<i64>() + 7 * (m.len() as i64)
    };
    let result = acc + fold_one(&m) + ring.iter().map(&fold_one).sum::<i64>();
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
