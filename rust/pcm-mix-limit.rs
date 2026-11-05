const SAMPLES: usize = 262144;
const PASSES: i32 = 8192;

fn limit(sample: i32) -> i32 {
    let knee = if sample > 16384 {
        16384 + (sample - 16384) / 2
    } else if sample < -16384 {
        -16384 + (sample + 16384) / 2
    } else {
        sample
    };
    knee.clamp(-32768, 32767)
}

fn main() {
    let source: Vec<i32> = (0..SAMPLES as i32)
        .map(|i| {
            let fundamental = (i * 97) % 65536 - 32768;
            let harmonic = (i * 271) % 65536 - 32768;
            let noise = (i * 8191 + 37) % 1024 - 512;
            fundamental / 2 + harmonic / 4 + noise
        })
        .collect();
    let mut destination = vec![0_i32; SAMPLES];
    for pass in (1..=PASSES).rev() {
        let gain = (pass * 1103) % 98304 - 49152;
        for (i, (destination, &source)) in destination.iter_mut().zip(&source).enumerate() {
            let scaled = source * gain / 32768;
            let faded = scaled * (i / 8) as i32 / 32768;
            *destination = limit(*destination + faded);
        }
    }
    let energy: i64 = destination
        .iter()
        .map(|&sample| {
            let value = i64::from(sample);
            value * value
        })
        .sum();
    assert_eq!(energy, 124776496343097);
}
