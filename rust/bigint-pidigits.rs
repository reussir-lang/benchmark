// The first 10000 decimal digits of pi with Gibbons' unbounded spigot (the
// Computer Language Benchmarks Game algorithm), folded into a rolling hash.
// The accumulator goes negative between digits, so the state is BigInt.
extern crate num_bigint;
extern crate num_integer;

use num_bigint::BigInt;
use num_integer::Integer;

fn spigot(count: u32) -> BigInt {
    let modulus = BigInt::from(1_000_000_007u32);
    let mut i = 0;
    let mut k = 0u32;
    let mut k1 = 1u32;
    let mut n = BigInt::from(1u32);
    let mut a = BigInt::ZERO;
    let mut d = BigInt::from(1u32);
    let mut h = BigInt::ZERO;
    loop {
        k += 1;
        let t = &n * 2u32;
        n *= k;
        a += t;
        k1 += 2;
        a *= k1;
        d *= k1;
        if a >= n {
            let (q, r) = (&n * 3u32 + &a).div_rem(&d);
            let u = r + &n;
            if d > u {
                h = (h * 10u32 + &q) % &modulus;
                i += 1;
                if i >= count {
                    return h;
                }
                a -= &d * &q;
                a *= 10u32;
                n *= 10u32;
            }
        }
    }
}

fn main() {
    let r = spigot(10_000);
    if r != BigInt::from(334_354_775u32) {
        eprintln!("FAIL: expected 334354775, got {}", r);
        std::process::exit(1);
    }
}
