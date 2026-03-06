#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t derive_test_ffi(void);

int main(void) {
  int64_t n = derive_test_ffi();
  if (n != 524) {
    fprintf(stderr, "FAIL: expected 524, got %ld\n", n);
    abort();
  }
  return 0;
}
