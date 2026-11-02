#include <stdint.h>
#include <stdio.h>
extern int64_t mltt_check_case(int64_t case_id, int64_t size, _Bool bad);
extern int64_t mltt_regressions(void);
int main(void) {
  int64_t result = mltt_regressions();
  for (int64_t id = 0; id < 3; ++id) {
    result += mltt_check_case(id, 4096, 0);
    result += 1 - mltt_check_case(id, 4096, 1);
  }
  if (result != 16) {
    fputs("MLTT check failed\n", stderr);
    return 1;
  }
  puts("16");
  return 0;
}
