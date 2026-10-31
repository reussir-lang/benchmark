#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t membership_ffi(int64_t n, int64_t queries);

int main(void) {
  int64_t hits = membership_ffi(10000, 40000);
  if (hits != 20000) {
    fprintf(stderr, "FAIL: expected 20000, got %ld\n", hits);
    abort();
  }
  return 0;
}
