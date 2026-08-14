#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t map_test_ffi(void);

int main(void) {
  const int64_t expected = 144585704074329LL;
  int64_t r = map_test_ffi();
  if (r != expected) {
    fprintf(stderr, "FAIL: expected %lld, got %lld\n", (long long)expected,
            (long long)r);
    abort();
  }
  return 0;
}
