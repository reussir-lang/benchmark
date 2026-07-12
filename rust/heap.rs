// Binary heap maintenance under a Gaussian workload — direct-mutation
// baseline: min-heap of 65535 i64 in a Vec, Irwin-Hall draws (sum of 12
// consecutive MINSTD outputs), M rounds of unconditional replace-top.
// Checksum = (sum of evicted minima + final heap contents) mod 1e9+7.

const N: usize = 65535;
const P: i64 = 1000000007;

fn lcg(x: i64) -> i64 {
    (x * 48271) % 2147483647
}

fn gauss(x: i64) -> (i64, i64) {
    let mut s = 0i64;
    let mut x = x;
    for _ in 0..12 {
        x = lcg(x);
        s += x;
    }
    (s, x)
}

fn sift_up(a: &mut [i64], mut i: usize) {
    while i > 0 {
        let p = (i - 1) / 2;
        if a[i] < a[p] {
            a.swap(i, p);
            i = p;
        } else {
            break;
        }
    }
}

fn sift_down(a: &mut [i64], mut i: usize) {
    loop {
        let l = 2 * i + 1;
        if l >= N {
            break;
        }
        let r = l + 1;
        let c = if r < N && a[r] < a[l] { r } else { l };
        if a[c] < a[i] {
            a.swap(i, c);
            i = c;
        } else {
            break;
        }
    }
}

fn heap_test(m: i64) -> i64 {
    let mut a = vec![0i64; N];
    let mut x = 20260711i64;
    for k in 0..N {
        let (g, x1) = gauss(x);
        x = x1;
        a[k] = g;
        sift_up(&mut a, k);
    }
    let mut acc = 0i64;
    for _ in 0..m {
        let (g, x1) = gauss(x);
        x = x1;
        let top = a[0];
        acc = (acc + top) % P;
        a[0] = top + g;
        sift_down(&mut a, 0);
    }
    let mut s = 0i64;
    for &v in &a {
        s = (s + v) % P;
    }
    (acc + s) % P
}

fn main() {
    let m: i64 = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(26000000);
    println!("{}", heap_test(m));
}
