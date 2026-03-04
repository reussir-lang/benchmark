#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t nbe_test_ffi(void);

int main(void) {
  int64_t n = nbe_test_ffi();
  if (n != 200000) {
    fprintf(stderr, "FAIL: expected 200000, got %ld\n", n);
    abort();
  }
  return 0;
}
