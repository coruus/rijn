#include "print-impl.h"

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

static const uint8_t k32[32] = { 0x01, 0x11, 0x02, 0x22, 0x03, 0x33, 0x04, 0x44,
                                 0x55, 0x05, 0x66, 0x06, 0x77, 0x07, 0x88, 0x08,
                                 0x09, 0x99, 0x0a, 0xaa, 0x0b, 0xbb, 0x0c, 0xcc,
                                 0xdd, 0x0d, 0xee, 0x0e, 0xff, 0x0f, 0xf1, 0x1f };

#define cycles __builtin_readcyclecounter
#define N  ((uint64_t)1 << 20)
#define M 1530

int main(int argc, char** argv) {
  uint8_t out[M] = {0};
  uint8_t in[M] = {0};

  uint8_t n[24] = {0};

  if (argc > 1) {
    uint64_t start = cycles();
    for (uint64_t i = 0; i < N; i++) {
      rijndael256_ctr(out, in, M, k32, n);
    }
    double cpb = cycles() - start;
    cpb /= (M * N);
    fprintf(stderr, "cpb=%f\n", cpb);
  } else {
    rijndael256_ctr(out, in, M, k32, n);
    _printbuf(out, M);
  }
  return 0;
}
