#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t nbe_closure_test_ffi(void);

int main(void) {
  int64_t n = nbe_closure_test_ffi();
  if (n != 28000021) {
    fprintf(stderr, "FAIL: expected 28000021, got %ld\n", n);
    abort();
  }
  return 0;
}
