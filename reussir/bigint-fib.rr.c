#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t fib_test_ffi(int64_t n);

int main(void) {
  int64_t r = fib_test_ffi(600000);
  if (r != 555579099) {
    fprintf(stderr, "FAIL: expected 555579099, got %ld\n", r);
    abort();
  }
  return 0;
}
