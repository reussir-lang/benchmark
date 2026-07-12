#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t heap_test_ffi(int64_t m);

int main(void) {
  int64_t c = heap_test_ffi(6500000);
  if (c != 558972311) {
    fprintf(stderr, "FAIL: expected 558972311, got %ld\n", c);
    abort();
  }
  return 0;
}
