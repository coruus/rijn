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

#include "test_k32b32_k0.const"

#define LEN 8224
#define popcnt __builtin_popcount

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

#define cycles __builtin_readcyclecounter
#define EXP 33

void rijndael_k32b16_timelen(void* ks, void* out, void* in, size_t len) {
  size_t n = ((((size_t)1) << EXP) / len);
  uint64_t then = time_now();
  uint64_t start = cycles();
  for (size_t i = 0; i < n; i++) {
    for (size_t j = 0; j < len; j += 128) {
      Rijndael_k32b16_encrypt_x8(ks, out + j, in + j);
    }
  }
  uint64_t total = cycles() - start;
  double totals = time_now() - then;
  double cpb = (double)total / (double)(n * len);
  double gbs = (n * len) / totals;
  printf("%1x  ", ((uint8_t*)out)[0] & 0xf);
  printf("k32b16  len = %4zu: %4f cpb, %4f MB/s, %4f\n", len, cpb, gbs, totals);
}


void rijndael_k32b32_timelen(void* ks, void* out, void* in, size_t len) {
  size_t n = ((((size_t)1) << EXP) / len);
  uint64_t then = time_now();
  uint64_t start = cycles();
  for (size_t i = 0; i < n; i++) {
    for (size_t j = 0; j < len; j += 128) {
      Rijndael_k32b32_encrypt_x4(ks, out + j, in + j);
    }
  }
  uint64_t total = cycles() - start;
  double totals = time_now() - then;
  double cpb = (double)total / (double)(n * len);
  double gbs = (n * len) / totals;
  //gbs *= 1e-9;
  printf("%1x  ", ((uint8_t*)out)[0] & 0xf);
  printf("k32b32  len = %4zu: %4f cpb, %4f MB/s, %4f\n", len, cpb, gbs, totals);
}

void rijndael_expandkey_time(void) {
  uint32_t ks[240] = {0};
  uint8_t k[32] = {0};

  uint64_t start = cycles();
  for (size_t i = 0; i < (1<<20); i++) {
    Rijndael_k32b32_expandkey(ks, k);
  }
  double cpc = cycles() - start;
  cpc /= (((size_t)1)<<20);
  printf("%1x  ", ((uint8_t*)ks)[0] & 0xf);
  printf("expandk cpc %4f\n\n", cpc);
}

static inline int rijndael_k32b32_time(void* out) {
  uint8_t k[32] = {0};
  uint8_t in[8224] = {0};
  uint32_t ks[240] = {0};

  rijndael_expandkey_time();
  Rijndael_k32b32_expandkey(ks, k);

  memcpy(in, rijndael_k32b32_test0_plaintext, 8224);

  size_t sizes[4] = { 128, 1350, 4096, 8192 };
  for (int i = 0; i < 4; i++) {
    rijndael_k32b32_timelen(ks, out, in, sizes[i]);
    rijndael_k32b16_timelen(ks, out, in, sizes[i]);
  }
  return 0;
}

int main(void) {
  uint8_t out[LEN] = {0};
  int err = rijndael_k32b32_test();
  if (err) { return err; }
  return rijndael_k32b32_time(out);
}
