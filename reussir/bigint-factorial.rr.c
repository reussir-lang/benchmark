#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t factorial_test_ffi(int64_t n);

int main(void) {
  int64_t r = factorial_test_ffi(120000);
  if (r != 118586228) {
    fprintf(stderr, "FAIL: expected 118586228, got %ld\n", r);
    abort();
  }
  return 0;
}
