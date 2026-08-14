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
// Linear variant: exactly one live version — no retention, so a
// mutable map updates in place throughout. The checksum folds the
// final map (iteration-order independent so all representations
// agree): result = lookup-sum + sum(key * 31 + value) + 7 * size.
// Final size 1,120,773.

use std::collections::HashMap;

const OPS: i64 = 8_000_000;
const EXPECTED: i64 = 144585704074329;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn main() {
    let mut m: HashMap<i64, i64> = HashMap::new();
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
    }
    let result =
        acc + m.iter().map(|(k, v)| k * 31 + v).sum::<i64>() + 7 * (m.len() as i64);
    if result != EXPECTED {
        eprintln!("FAIL: expected {EXPECTED}, got {result}");
        std::process::exit(1);
    }
}
