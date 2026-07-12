#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t functional_queue_test_ffi(int64_t size, int64_t rounds);

int main(void) {
  int64_t result = functional_queue_test_ffi(65536, 1000000);
  if (result != 66797929) {
    fprintf(stderr, "FAIL: expected 66797929, got %ld\n", result);
    abort();
  }
  return 0;
}
