const PIXELS: usize = 262144;
const PASSES: u32 = 4096;

fn channel(source: u32, destination: u32, alpha: u32) -> u32 {
    (source * alpha + destination * (255 - alpha) + 127) / 255
}

fn blend(destination: u32, source: u32, opacity: u32) -> u32 {
    let alpha = ((source >> 24) * opacity + 127) / 255;
    let red = channel(source & 255, destination & 255, alpha);
    let green = channel((source >> 8) & 255, (destination >> 8) & 255, alpha);
    let blue = channel((source >> 16) & 255, (destination >> 16) & 255, alpha);
    red | (green << 8) | (blue << 16) | 0xff000000
}

fn main() {
    let source: Vec<u32> = (0..PIXELS as u32)
        .map(|i| {
            ((i * 17 + 23) % 256)
                | (((i * 43 + 7) % 256) << 8)
                | (((i * 97 + 61) % 256) << 16)
                | (((i * 31 + 13) % 256) << 24)
        })
        .collect();
    let mut destination: Vec<u32> = (0..PIXELS as u32)
        .map(|i| {
            ((i * 29 + 5) % 256)
                | (((i * 11 + 101) % 256) << 8)
                | (((i * 67 + 19) % 256) << 16)
                | 0xff000000
        })
        .collect();
    for pass in (1..=PASSES).rev() {
        let opacity = 96 + pass % 160;
        for (destination, &source) in destination.iter_mut().zip(&source) {
            *destination = blend(*destination, source, opacity);
        }
    }
    let checksum: u64 = destination.iter().map(|&pixel| u64::from(pixel)).sum();
    assert_eq!(checksum, 1123699998887936);
}
