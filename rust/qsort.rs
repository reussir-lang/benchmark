// Functional-style quicksort workload, direct-mutation baseline: Vec<i64>
// filled from a MINSTD LCG, hand-written Lomuto partition (the same
// algorithm the other variants use — not sort_unstable), checksum of the
// sorted array, 100 rounds.

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn fill(seed: i64) -> Vec<i64> {
    let mut v = Vec::with_capacity(65536);
    let mut x = seed;
    for _ in 0..65536 {
        x = lcg(x);
        v.push(x);
    }
    v
}

fn qsort(a: &mut [i64], lo: i64, hi: i64) {
    if lo >= hi {
        return;
    }
    let p = a[hi as usize];
    let mut i = lo;
    for j in lo..hi {
        if a[j as usize] < p {
            a.swap(i as usize, j as usize);
            i += 1;
        }
    }
    a.swap(i as usize, hi as usize);
    qsort(a, lo, i - 1);
    qsort(a, i + 1, hi);
}

fn checksum(a: &[i64]) -> i64 {
    let mut acc = 0i64;
    let mut prev = -1i64;
    for &v in a {
        if prev > v {
            return -1;
        }
        prev = v;
        acc = (acc + v) % 1000000007;
    }
    acc
}

fn main() {
    let rounds = 100i64;
    let mut acc = 0i64;
    for r in (1..=rounds).rev() {
        let mut a = fill(42 + r);
        qsort(&mut a, 0, 65535);
        acc = (acc + checksum(&a)) % 1000000007;
    }
    if acc != 276066679 {
        eprintln!("FAIL: expected 276066679, got {}", acc);
        std::process::abort();
    }
}
