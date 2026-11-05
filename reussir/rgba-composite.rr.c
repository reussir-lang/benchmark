#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern int64_t rgba_composite_test_ffi(int64_t rounds);

int main(void) {
    int64_t result = rgba_composite_test_ffi(4096);
    if (result != INT64_C(1123699998887936)) {
        fprintf(stderr, "FAIL: expected 1123699998887936, got %" PRId64 "\n", result);
        return 1;
    }
    return 0;
}
