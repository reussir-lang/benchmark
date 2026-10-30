// 120000! by sequential multiplication 2 * 3 * ... * n: a growing big
// integer times a word-sized factor.
extern crate num_bigint;

use num_bigint::BigUint;

fn main() {
    let mut acc = BigUint::from(1u32);
    for i in 2..=120_000u64 {
        acc *= i;
    }
    let r = acc % 1_000_000_007u32;
    if r != BigUint::from(118_586_228u32) {
        eprintln!("FAIL: expected 118586228, got {}", r);
        std::process::exit(1);
    }
}
