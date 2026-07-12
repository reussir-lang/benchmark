#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t nbe_hoas_test_ffi(void);

int main(void) {
  int64_t n = nbe_hoas_test_ffi();
  if (n != 24000015) {
    fprintf(stderr, "FAIL: expected 24000015, got %ld\n", n);
    abort();
  }
  return 0;
}
