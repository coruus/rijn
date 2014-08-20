#include "rijn-asm.h"
#include "print-impl.h"

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <time.h>
#include <sys/time.h>

static uint64_t time_now() {
  struct timeval tv;
  uint64_t ret;

  gettimeofday(&tv, NULL);
  ret = tv.tv_sec;
  ret *= 1000000;
  ret += tv.tv_usec;
  return ret;
}

#define LEN 8224
#define popcnt __builtin_popcount
/*
int rijndael_k32b32_test(void) {
  uint32_t ks[240] = {0};
  uint8_t k[32] = {0};
  uint8_t ibuf[LEN] = {0};
  uint8_t obuf[LEN] = {0};
  Rijndael_k32b32_expandkey(ks, k);
  memcpy(ibuf, rijndael_k32b32_test0_plaintext, rijndael_k32b32_test0_len);
  for (size_t i = 0; i < LEN; i += 128) {
      Rijndael_k32b32_encrypt_x4(ks, obuf + i, ibuf + i);
  }
  if (memcmp(obuf, rijndael_k32b32_test0_ciphertext, rijndael_k32b32_test0_len) != 0) {
    printbuf(obuf, 128);
    printbuf(rijndael_k32b32_test0_ciphertext, 128);
    exit(0);
    printf("FAIL");
    return -1;
  } else {
    return 0;
  }
}

int rijndael_k32b32_ctr_test(void) {
  uint32_t ks[240] = {0};
  uint8_t k[32] = {1};
  Rijndael_k32b32_expandkey(ks, k);
  uint64_t blocks[4][4] = { { 1, 2, 3, 0 },
                            { 1, 2, 3, 1 },
                            { 1, 2, 3, 2 },
                            { 1, 2, 3, 3 } };
  uint8_t enc_ecb[128] = { 0 };
  uint8_t enc_ctr[128] = { 0 };
  memset_s(enc_ctr, 128, 0, 128);
  uint64_t nc[4] = { 1, 2, 3, 0 };
  Rijndael_k32b32_encrypt_x4(ks, enc_ecb, blocks);
  Rijndael_k32b32_ctr(ks, enc_ctr, nc, 1);
  printbuf(enc_ecb, 128);
  printbuf(enc_ctr, 128);
  printbuf(nc, 4*8);
  if (memcmp(enc_ecb, enc_ctr, 128) != 0) {
    printf("FAIL\n");
    return -1;
  } else {
    printf("OKAY\n");
    return 0;
  }
}

*/
#define cycles __builtin_readcyclecounter
#define EXP 33
/*
double rijndael_k32b32_ctr_time(void* ks, void* out, size_t len) {
  size_t n = ((((size_t)1) << EXP) / len);
  uint64_t nc[2] = {0, 0};
  
  uint64_t start = cycles();
  for (size_t i = 0; i < n; i++) {
    Rijndael_k32b32_ctr(ks, out, nc, len/128);
  }
  double cpb = cycles() - start;
  cpb /= (n * len);
  printf("k32b32_ctr %4f cpb\n", cpb);
  return cpb;
}
*/
double rijndael_k16b16_timelen(void* ks, void* out, void* in, size_t len) {
  size_t n = ((((size_t)1) << EXP) / 64);
  uint64_t then = time_now();
  uint64_t start = cycles();
  for (size_t i = 0; i < n; i++) {
    for (size_t j = 0; j < len; j += 64) {
      Rijndael_k16b16_encrypt_k64b64(out + j, in + j, ks);
    }
  }
  uint64_t total = cycles() - start;
  double totals = time_now() - then;
  double cpb = (double)total / (double)(n * len);
  double gbs = (n * len) / totals;
  printf("%1x  ", ((uint8_t*)out)[0] & 0xf);
  printf("k16b16_k64b64  len = %4zu: %4f cpb, %4f MB/s, %4f\n", len, cpb, gbs, totals);
  return cpb;
}

static inline int rijndael_k16b16_time(void* out) {
  uint8_t k[128] = {0};
  uint8_t in[8224] = {0};
  uint64_t ks[32] = {0};

  size_t sizes[4] = { 128, 1350, 4096, 8192 };
  for (int i = 0; i < 4; i++) {
    double cpb32 = rijndael_k16b16_b128_timelen(ks, out, in, sizes[i]);
    double cpb16 = rijndael_k16b16_timelen(ks, out, in, sizes[i]);
    printf("cpb128/cpb64 = %f\n", cpb32/cpb16);
  }
  return 0;
}

int main(void) {
  uint8_t out[8224] = {0};
  return rijndael_k16b16_time(out);
}
