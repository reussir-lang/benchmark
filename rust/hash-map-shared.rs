// Std-collection workload on Rust's std hash map
// (std::collections::HashMap, mutable in place, default SipHash-1-3
// hasher). Zipfian mixed-op workload: keys follow an integer-only
// octave Zipf (theta ~ 1) — a stratum s drawn uniform in [0, 24), then
// a key uniform in [2^s, 2^(s+1)), so every octave carries equal mass
// and per-key probability decays as 1/key. 8M rounds, each drawing op,
// stratum, key from one MINSTD stream: 9/16 insert, 5/16 delete, 2/16
// lookup (sum, -1 on miss). Deletes land on present keys ~48% of the
// time.
//
// After each round one more draw decides retention: when it is
// divisible by 8192 (977 times over the run) the current version is
// parked in slot (draw / 8192) mod 8 of an eight-version ring, where
// it stays shared until that slot is next overwritten. Persistent maps
// pay path copies while a parked version is live; mutable maps pay a
// full copy per parked version. The checksum folds the working map and
// every ring slot, so retained versions stay live and verified. Final
// size 1,120,619; each ring slot ends holding a ~1.1M-entry version.
// A mutable map has no structural sharing, so retention is an explicit
// full clone at the event — the honest cost of versioning for this
// representation. The checksum is iteration-order independent so all
// representations agree.

use std::collections::HashMap;

const OPS: i64 = 8_000_000;
const EXPECTED: i64 = 1271164153412359;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: HashMap<i64, i64> = HashMap::new();
    let mut ring: Vec<HashMap<i64, i64>> = vec![HashMap::new(); 8];
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
            m.insert(k, i);
        } else if op < 14 {
            m.remove(&k);
        } else {
            acc += m.get(&k).copied().unwrap_or(-1);
        }
        x = lcg(x);
        if x % 8192 == 0 {
            ring[((x / 8192) % 8) as usize] = m.clone();
        }
    }
    let fold_one = |m: &HashMap<i64, i64>| -> i64 {
        m.iter().map(|(k, v)| k * 31 + v).sum::<i64>() + 7 * (m.len() as i64)
    };
    let result = acc + fold_one(&m) + ring.iter().map(&fold_one).sum::<i64>();
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
