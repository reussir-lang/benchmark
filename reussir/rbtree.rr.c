#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t fold_test_ffi(int64_t size);

int main(void) {
  const int64_t n = 2500000;
  int64_t p = fold_test_ffi(n);
  if (p != 250000) {
    fprintf(stderr, "FAIL: expected 250000, got %ld\n", p);
    abort();
  }
  return 0;
}
