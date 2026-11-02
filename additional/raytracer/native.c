#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern uint64_t raytracer_original(void);

int main(void) {
  uint64_t checksum = raytracer_original();
  if (checksum != UINT64_C(64158141444)) {
    fprintf(stderr, "unexpected raytracer checksum: %" PRIu64 "\n", checksum);
    return 1;
  }
  printf("%" PRIu64 "\n", checksum);
  return 0;
}
