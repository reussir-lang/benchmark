// Iterative Fibonacci over num-bigint: 600000 steps of (a, b) -> (b, a + b),
// so both operands soon grow far beyond a machine word. The sum is formed in
// place in `a`'s buffer before the swap.
extern crate num_bigint;

use num_bigint::BigUint;

fn fib(n: u32) -> BigUint {
    let mut a = BigUint::ZERO;
    let mut b = BigUint::from(1u32);
    for _ in 0..n {
        a += &b;
        std::mem::swap(&mut a, &mut b);
    }
    a
}

fn main() {
    let r = fib(600_000) % 1_000_000_007u32;
    if r != BigUint::from(555_579_099u32) {
        eprintln!("FAIL: expected 555579099, got {}", r);
        std::process::exit(1);
    }
}
