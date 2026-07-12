#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t qsort_test_ffi(int64_t rounds);

int main(void) {
  int64_t c = qsort_test_ffi(400);
  if (c != 853505117) {
    fprintf(stderr, "FAIL: expected 853505117, got %ld\n", c);
    abort();
  }
  return 0;
}
