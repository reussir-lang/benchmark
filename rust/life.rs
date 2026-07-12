// Game of Life, toroidal 64x64 — the direct-mutation baseline: two flat
// i32 buffers swapped each generation. Same seed hash, rule, and wrap as
// the other language variants.

const N: usize = 64;
const CELLS: usize = N * N;

fn wrap(x: i64) -> usize {
    ((x + 64) % 64) as usize
}

fn step(src: &[i32; CELLS], dst: &mut [i32; CELLS]) {
    for i in 0..N {
        for j in 0..N {
            let (ii, jj) = (i as i64, j as i64);
            let im = wrap(ii - 1);
            let ip = wrap(ii + 1);
            let jm = wrap(jj - 1);
            let jp = wrap(jj + 1);
            let n = src[im * N + jm]
                + src[im * N + j]
                + src[im * N + jp]
                + src[i * N + jm]
                + src[i * N + jp]
                + src[ip * N + jm]
                + src[ip * N + j]
                + src[ip * N + jp];
            let alive = src[i * N + j];
            dst[i * N + j] = if alive == 1 {
                if n == 2 || n == 3 { 1 } else { 0 }
            } else {
                if n == 3 { 1 } else { 0 }
            };
        }
    }
}

fn seed() -> Box<[i32; CELLS]> {
    let mut g = Box::new([0i32; CELLS]);
    for i in 0..N as i64 {
        for j in 0..N as i64 {
            g[(i * 64 + j) as usize] =
                if (i * 2654435761 + j * 40503 + i * j * 2246822519) % 97 < 33 {
                    1
                } else {
                    0
                };
        }
    }
    g
}

fn main() {
    let gens = 200000usize;
    let mut src = seed();
    let mut dst = Box::new([0i32; CELLS]);
    for _ in 0..gens {
        step(&src, &mut dst);
        std::mem::swap(&mut src, &mut dst);
    }
    let pop: i64 = src.iter().map(|&c| c as i64).sum();
    if pop != 115 {
        eprintln!("FAIL: expected 115, got {}", pop);
        std::process::abort();
    }
}
