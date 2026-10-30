#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t collatz_test_ffi(int64_t n);

int main(void) {
  int64_t r = collatz_test_ffi(1000000);
  if (r != 131434272) {
    fprintf(stderr, "FAIL: expected 131434272, got %ld\n", r);
    abort();
  }
  return 0;
}
