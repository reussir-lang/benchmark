#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t lookup_test_ffi(int64_t n);

int main(void) {
  int64_t hits = lookup_test_ffi(1000000);
  if (hits != 2059798) {
    fprintf(stderr, "FAIL: expected 2059798, got %ld\n", hits);
    abort();
  }
  return 0;
}
