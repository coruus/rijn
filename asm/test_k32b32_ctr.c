#include "rijn-asm.h"
#include "print-impl.h"

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "test/test_k32b32_ecb_k0.const"

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
    return -1;
  } else {
    return 0;
  }
}

/*
int rijndael_k32b32_ctr_test(void) {
  uint32_t ks[240] = {0};
  uint8_t k[32] = {1};
  Rijndael_k32b32_expandkey(ks, k);
  uint64_t blocks[8][4] = { { 1, 2, 3, 0 },
                            { 1, 2, 3, 1 },
                            { 1, 2, 3, 2 },
                            { 1, 2, 3, 3 },
                            { 1, 2, 3, 4 },
                            { 1, 2, 3, 5 },
                            { 1, 2, 3, 6 },
                            { 1, 2, 3, 7 } };
  uint8_t enc_ecb[256] = { 0 };
  uint8_t enc_ctr[256] = { 0 };
  uint64_t nc[4] = { 1, 2, 3, 0 };
  Rijndael_k32b32_encrypt_x4(ks, enc_ecb, blocks);
  Rijndael_k32b32_encrypt_x4(ks, enc_ecb + 128, &blocks[4]);
  memset_s(enc_ctr, 256, 0, 256);
  Rijndael_k32b32_ctr(ks, enc_ctr, enc_ctr, nc, 2);
  printbuf(enc_ecb, 256);
  printbuf(enc_ctr, 256);
  printbuf(nc, 4*8);
  if (memcmp(enc_ecb, enc_ctr, 256) != 0) {
    printf("FAIL\n");
    return -1;
  } else {
    printf("OKAY\n");
    return 0;
  }
}
*/


int main(void) {
  uint8_t out[LEN] = {0};
  int err = rijndael_k32b32_test();
  printf("K32B32: ");
  if (err) {
    printf("FAIL");
    return err;
  } else {
    printf("OKAY");
  }
  printf("\n");

  //err = rijndael_k32b32_ctr_test();
  printf("err=%u: OKAY\n", err);
  return 0 ;//rijndael_k32b32_time(out);
}
