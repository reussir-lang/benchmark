#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t replace_test_ffi(int64_t depth, int64_t summands, int64_t rounds);

int main(void) {
  int64_t r = replace_test_ffi(12, 256, 100);
  if (r != 259584) {
    fprintf(stderr, "FAIL: expected 259584, got %ld\n", r);
    abort();
  }
  return 0;
}
