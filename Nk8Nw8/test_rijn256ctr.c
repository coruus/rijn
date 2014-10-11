#include "rijndael256ctr.h"
#include "print-impl.h"
#include "timenow.h"

#include <inttypes.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

static const uint8_t k32[32] = { 0x01, 0x11, 0x02, 0x22, 0x03, 0x33, 0x04, 0x44,
                                 0x55, 0x05, 0x66, 0x06, 0x77, 0x07, 0x88, 0x08,
                                 0x09, 0x99, 0x0a, 0xaa, 0x0b, 0xbb, 0x0c, 0xcc,
                                 0xdd, 0x0d, 0xee, 0x0e, 0xff, 0x0f, 0xf1, 0x1f };

#define cycles __builtin_readcyclecounter
#define N  ((uint64_t)1 << 24)
#define M 1530

int main(int argc, char** argv) {
  uint8_t out[M] = {0};
  uint8_t in[M] = {0};

  uint8_t n[24] = {0};

  if (argc > 1) {
    size_t len = strtoll(argv[1], NULL, 10);
    uint8_t* i = valloc(len);
    if (i == NULL) { return -1; }
    uint8_t* o = valloc(len);
    if (o == NULL) { free(i); return -1; }
    uint64_t t0 = time_now();
    uint64_t start = cycles();
    for (uint64_t j = 0; j < N; j++) {
      rijndael256_ctr_xor(o, i, len, n, k32);
    }
    double cpb = cycles() - start;
    double t1 = time_now() - t0;
    cpb /= (len * N);
    fprintf(stderr, "cpb=%f\n", cpb);
    fprintf(stderr, "MB/s=%f\n", (double)(len * N) / t1);
    free(i);
    free(o);
  } else {
    rijndael256_ctr_xor(out, in, M, n, k32);
    _printbuf(out, M);
  }
  return 0;
}
