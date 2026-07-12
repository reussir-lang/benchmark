#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t life_test_ffi(int64_t gens);

int main(void) {
  int64_t p = life_test_ffi(50000);
  if (p != 115) {
    fprintf(stderr, "FAIL: expected 115, got %ld\n", p);
    abort();
  }
  return 0;
}
