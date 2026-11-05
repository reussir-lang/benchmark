#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#ifndef PIXELS
#define PIXELS 262144
#endif
static uint32_t channel(uint32_t s, uint32_t d, uint32_t a) {
  return (s * a + d * (255 - a) + 127) / 255;
}
int main(int argc, char **argv) {
  int rounds = argc > 1 ? atoi(argv[1]) : 4096;
  uint32_t *dst = malloc(PIXELS * sizeof(*dst));
  uint32_t *src = malloc(PIXELS * sizeof(*src));
  if (!dst || !src) return 2;
  for (uint32_t i = 0; i < PIXELS; ++i) {
    src[i] = ((i * 17 + 23) % 256) | (((i * 43 + 7) % 256) << 8)
           | (((i * 97 + 61) % 256) << 16) | (((i * 31 + 13) % 256) << 24);
    dst[i] = ((i * 29 + 5) % 256) | (((i * 11 + 101) % 256) << 8)
           | (((i * 67 + 19) % 256) << 16) | UINT32_C(0xff000000);
  }
  for (int n = rounds; n > 0; --n) {
    uint32_t opacity = 96 + n % 160;
    for (uint32_t i = 0; i < PIXELS; ++i) {
      uint32_t s = src[i], d = dst[i], a = ((s >> 24) * opacity + 127) / 255;
      dst[i] = channel(s & 255, d & 255, a)
             | (channel((s >> 8) & 255, (d >> 8) & 255, a) << 8)
             | (channel((s >> 16) & 255, (d >> 16) & 255, a) << 16)
             | UINT32_C(0xff000000);
    }
  }
  int64_t checksum = 0;
  for (uint32_t i = 0; i < PIXELS; ++i) checksum += dst[i];
  printf("%" PRId64 "\n", checksum);
  free(src);
  free(dst);
}
