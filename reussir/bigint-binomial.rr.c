#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t binomial_test_ffi(int64_t n);

int main(void) {
  int64_t r = binomial_test_ffi(200000);
  if (r != 175895282) {
    fprintf(stderr, "FAIL: expected 175895282, got %ld\n", r);
    abort();
  }
  return 0;
}
