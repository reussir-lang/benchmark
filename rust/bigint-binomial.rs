// The binomial row C(200000, i) by the multiplicative recurrence
// C(n, i + 1) = C(n, i) * (n - i) / (i + 1): every division is exact, by a
// word-sized divisor. The row must sum to 2^n and end at 1.
extern crate num_bigint;

use num_bigint::BigUint;

fn main() {
    let n = 200_000u64;
    let mut c = BigUint::from(1u32);
    let mut sum = BigUint::from(1u32);
    for i in 0..n {
        c = c * (n - i) / (i + 1);
        sum += &c;
    }
    let r = sum % 1_000_000_007u32;
    if c != BigUint::from(1u32) || r != BigUint::from(175_895_282u32) {
        eprintln!("FAIL: expected last 1 and 175895282, got {} and {}", c, r);
        std::process::exit(1);
    }
}
