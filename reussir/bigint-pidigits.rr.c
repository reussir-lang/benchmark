#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t pidigits_test_ffi(int64_t n);

int main(void) {
  int64_t r = pidigits_test_ffi(10000);
  if (r != 334354775) {
    fprintf(stderr, "FAIL: expected 334354775, got %ld\n", r);
    abort();
  }
  return 0;
}
