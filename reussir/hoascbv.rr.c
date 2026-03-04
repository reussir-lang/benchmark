#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t hoascbv_test_ffi(void);

int main(void) {
  int64_t n = hoascbv_test_ffi();
  if (n != 16777214) {
    fprintf(stderr, "FAIL: expected 16777214, got %ld\n", n);
    abort();
  }
  return 0;
}
