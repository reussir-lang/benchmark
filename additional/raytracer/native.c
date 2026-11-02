#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern uint64_t raytracer_original(void);

int main(void) {
  printf("%" PRIu64 "\n", raytracer_original());
  return 0;
}
