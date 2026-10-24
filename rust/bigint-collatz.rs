// Total Collatz trajectory length over the starting values 1 .. 999999 in
// num-bigint arithmetic. Every intermediate value stays below 2^37, so this
// measures the small-integer path.
extern crate num_bigint;
extern crate num_integer;
extern crate num_traits;

use num_bigint::BigUint;
use num_integer::Integer;
use num_traits::One;

fn steps(mut n: BigUint) -> u64 {
    let mut c = 0;
    while !n.is_one() {
        if n.is_even() {
            n /= 2u32;
        } else {
            n = n * 3u32 + 1u32;
        }
        c += 1;
    }
    c
}

fn main() {
    let total: u64 = (1..1_000_000u32).map(|s| steps(BigUint::from(s))).sum();
    if total != 131_434_272 {
        eprintln!("FAIL: expected 131434272, got {}", total);
        std::process::exit(1);
    }
}
