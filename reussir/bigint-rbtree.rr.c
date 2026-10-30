#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t fold_test_ffi(int64_t n);

int main(void) {
  int64_t r = fold_test_ffi(2500000);
  if (r != 3124998750000) {
    fprintf(stderr, "FAIL: expected 3124998750000, got %ld\n", r);
    abort();
  }
  return 0;
}
