#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#define SAMPLES 262144
int main(int argc, char **argv) {
  int64_t rounds = argc > 1 ? strtoll(argv[1], NULL, 10) : 8192;
  int32_t *src = malloc(SAMPLES * sizeof(*src));
  int32_t *dst = calloc(SAMPLES, sizeof(*dst));
  if (!src || !dst) return 2;
  for (int64_t i = 0; i < SAMPLES; ++i) {
    int32_t fundamental = (i * 97) % 65536 - 32768;
    int32_t harmonic = (i * 271) % 65536 - 32768;
    int32_t noise = (i * 8191 + 37) % 1024 - 512;
    src[i] = fundamental / 2 + harmonic / 4 + noise;
  }
  for (int64_t n = rounds; n > 0; --n) {
    int32_t gain = (n * 1103) % 98304 - 49152;
    for (int64_t i = 0; i < SAMPLES; ++i) {
      int32_t scaled = (src[i] * gain) / 32768;
      int32_t faded = (scaled * (int32_t)(i / 8)) / 32768;
      int32_t sample = dst[i] + faded;
      int32_t knee = sample > 16384 ? 16384 + (sample - 16384) / 2
                   : sample < -16384 ? -16384 + (sample + 16384) / 2 : sample;
      dst[i] = knee > 32767 ? 32767 : knee < -32768 ? -32768 : knee;
    }
  }
  int64_t energy = 0;
  for (int64_t i = 0; i < SAMPLES; ++i) energy += (int64_t)dst[i] * dst[i];
  printf("%" PRId64 "\n", energy);
  free(src);
  free(dst);
}
