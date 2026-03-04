#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t fold_test_ffi(int64_t size);

int main(void) {
  const int64_t n = 4200000;
  int64_t p = fold_test_ffi(n);
  if (p != 420000) {
    fprintf(stderr, "FAIL: expected 420000, got %ld\n", p);
    abort();
  }
  return 0;
}
