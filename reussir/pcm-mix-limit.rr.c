#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern int64_t pcm_mix_limit_test_ffi(int64_t rounds);

int main(void) {
    int64_t result = pcm_mix_limit_test_ffi(8192);
    if (result != INT64_C(124776496343097)) {
        fprintf(stderr, "FAIL: expected 124776496343097, got %" PRId64 "\n", result);
        return 1;
    }
    return 0;
}
