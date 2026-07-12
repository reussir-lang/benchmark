#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t qsort_test_ffi(int64_t rounds);

int main(void) {
  int64_t c = qsort_test_ffi(100);
  if (c != 276066679) {
    fprintf(stderr, "FAIL: expected 276066679, got %ld\n", c);
    abort();
  }
  return 0;
}
