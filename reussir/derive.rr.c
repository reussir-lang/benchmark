#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t derive_test_ffi(void);

int main(void) {
  int64_t n = derive_test_ffi();
  if (n != 40230090) {
    fprintf(stderr, "FAIL: expected 40230090, got %ld\n", n);
    abort();
  }
  return 0;
}
