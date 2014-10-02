#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "print-impl.h"

// A key that isn't all zeros...
static const uint32_t test_k[4] = { 0x11223344, 0x10203040, 
                                    0x0a0b0c0d, 0xe0f01020};

// OpenSSL structures.
typedef struct aes_key_st {
    uint32_t rd_key[4 *(14 + 1)];
    int rounds;
} AesKey;
extern void aesni_set_encrypt_key(const void*, int, AesKey*);

extern void Rijndael_k8w4_expandkey(void*, const void*);

int test_expansion(void) {
  uint32_t ks_ossl[60] = {0};
  uint32_t ks_this[60] = {0};
  AesKey aeskey;
  aesni_set_encrypt_key((void*)test_k, 256, &aeskey);
  Rijndael_k8w4_expandkey(ks_this, test_k);

#ifdef APPLE_LIBCRYPTO_MADNESS
  // Apple's libcrypto rather puzzlingly byteswaps the AES
  // key. Thus...
  for (int i = 0; i < 60; i++) {
    aeskey.rd_key[i] = __builtin_bswap32(aeskey.rd_key[i]);
  }
#endif

  printbuf(ks_this, 60 * 4);
  printbuf(aeskey.rd_key, 60 * 4);

  if (memcmp(ks_this, aeskey.rd_key, 60 * 4) == 0) {
    printf("\nOKAY\n\n");
    return 0;
  } else {
    printf("\nFAIL\n\n");
    return -1;
  }
}

#define N (1 << 21)
#define cpc(COUNTER) (((double)(COUNTER)) / (double)(N))
#define pcp(COUNTER) printf("%10s=%5.1f\n", #COUNTER, cpc(COUNTER))

#define cycles __builtin_readcyclecounter

#define REP(COUNTER, STMT)             \
  do {                                 \
    COUNTER = cycles();                \
    for (uint64_t i = 0; i < N; i++) { \
      STMT;                            \
    }                                  \
    COUNTER = cycles() - COUNTER;      \
    pcp(COUNTER);                      \
  } while (0)

int time_expansion(void) {
  uint32_t ks_ossl[60] = {0};
  uint32_t ks_this[60] = {0};
  AesKey aeskey;

  uint64_t ossl, local;
  // Subsequent calls are independent. (That is, their execution
  // may overlap.)
  printf("Overlapped:\n");
  REP(ossl, aesni_set_encrypt_key((void*)test_k, 256, &aeskey));
  REP(local, Rijndael_k8w4_expandkey(ks_this, test_k));
  printf("\nDependent:\n");
  // Subsequent calls chain on the last round keys.
  REP(ossl, aesni_set_encrypt_key(aeskey.rd_key + 60-16, 256, &aeskey));
  REP(ossl, aesni_set_encrypt_key(aeskey.rd_key + 60-16, 256, &aeskey));
  REP(local, Rijndael_k8w4_expandkey(ks_this, ks_this+60-16));
  REP(local, Rijndael_k8w4_expandkey(ks_this, ks_this+60-16));
 
  printf("ratio=%5.2f\n", cpc(local) / cpc(ossl));
  printf("ratio=%5.2f\n", cpc(ossl) / cpc(local));

  return 0;
}

int main(void) {
  test_expansion();
  time_expansion();
  return 0;
}
