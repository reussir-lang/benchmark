#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t fold_test_ffi(int64_t size);

int main(void) {
  const int64_t n = 10000000;
  int64_t p = fold_test_ffi(n);
  if (p != 1000000) {
    fprintf(stderr, "FAIL: expected 1000000, got %ld\n", p);
    abort();
  }
  return 0;
}
