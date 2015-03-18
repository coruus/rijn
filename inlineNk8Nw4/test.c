#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "print-impl.h"

// A key that isn't all zeros...
static const uint32_t test_k[8] = { 0x11223344, 0x10203040, 
                                    0x0a0b0c0d, 0xe0f01020, 0xff, 0xcc, 0xdd, 0xee};

// OpenSSL structures.
typedef struct aes_key_st {
    uint32_t rd_key[4 * (14 + 1)];
    int rounds;
} AesKey;
extern void aesni_set_encrypt_key(const void*, int, AesKey*);
extern void intel_aes_encrypt_init_256(void*, const void*);
extern void aes_ctr(void*, const void*);
extern void aes256_ecb(void*, const void*, void*);
extern void aes256_ctr1(void*, const void*, void*);
extern void aes256_ctr2(void*, const void*, void*);
extern void aes256_ctr3(void*, const void*, void*);
extern void aes256_ctr4(void*, const void*, void*);
extern void aes256_ctr5(void*, const void*, void*);
extern void aes256_ctr6(void*, const void*, void*);
extern void aes256_ctr7(void*, const void*, void*);
extern void aes256_ctr8(void*, const void*, void*);
extern void aes_ctr_continue(void*, const void*, void*);

extern void AES_encrypt(void *in, void *out,
                                const AesKey *key);

void AES_ctr128_encrypt(const void*in, void* out,
                                       size_t len, const AesKey *key,
                                       uint8_t ivec[16],
                                       uint8_t ecount_buf[16],
                                       unsigned int *num);
int test_expansion(void) {
  uint32_t ks_ossl[60] = {0};
  uint32_t ks_this[60] = {0};
  AesKey aeskey;
//  aeskey.rounds = 13;
  aesni_set_encrypt_key((void*)test_k, 256, &aeskey);
  memset(((uint8_t*)&aeskey) + 224, 0xff, 16);
  //intel_aes_encrypt_init_256(aeskey.rd_key, test_k);
  //Rijndael_k8w4_expandkey(ks_this, test_k);



  uint64_t ot[16] = {0};
  uint64_t oo[16] = {0};
  aes256_ctr8(ks_this, test_k, ot);
  //AES_encrypt(oo, oo, &aeskey);
  AES_ctr128_encrypt(oo, oo, 16*8, &aeskey, ivec, ecou, &num);
  printbuf(test_k, 128);
  printbuf(oo, 16*8);
  printbuf(ot, 16*8);
  printf("%u %u\n", aeskey.rounds, memcmp(ot, oo, 128));
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

int test_i(void) {
  {                                                                              
    num = 0;
    uint8_t buf[128] = {0};
    uint8_t buf_ossl[128] = {0};
    uint8_t ivec[16] = {0};
    uint8_t ecou[16] = {0};
    unsigned int num = 0;
    aes256_ctr##N(ks, test_k, buf);                                            
    AES_ctr128_encrypt(buf_ossl, buf_ossl, 16 * N, &aeskey, ivec, ecou, &num); 
    if (memcmp(ks, aeskey.rd_key, 224) != 0) {                                 
      printf("%u EXP: FAIL\n", N);                                          
      printbuf(ks, 224);                                                       
      printbuf(aeskey.rd_key, 224);                                            
    } else {                                                                   
      printf("%u EXP: OKAY\n", N);                                          
    }                                                                          
    if (memcmp(buf, buf_ossl, 16 * N) != 0) {                                  
      printf("%u CTR_32: FAIL\n", N);                                          
      printbuf(buf, 128);                                                      
      printbuf(buf_ossl, 128);                                                 
    } else {                                                                   
      printf("%u CTR: OKAY\n", N);                                          
    }                                                                          
    if ((128 - 16 * N) && (memcmp(buf + 16 * N, ZERO, 128 - 16 * N) != 0)) {   
      printf("%u CTR: OVERWRITE\n", N);                                     
    } else {                                                                   
      /*printf("%u CTR_32: OOKAY\n", N);     */                                   
    }                                                                          
  }
}

static const uint8_t ZERO[128] = {0};  

int test_ctrs(void) {
  uint32_t ks[60] = {0};
  AesKey aeskey;
  aeskey.rounds = 14;
  aesni_set_encrypt_key((void*)test_k, 256, &aeskey);

  uint8_t buf[128];
  uint8_t buf_ossl[128];

  uint8_t ivec[16];
  uint8_t ecou[16];
  uint32_t num;

  TEST_CTREX(1);
  TEST_CTREX(2);
  TEST_CTREX(3);
  TEST_CTREX(4);
  TEST_CTREX(5);
  TEST_CTREX(6);
  TEST_CTREX(7);
  TEST_CTREX(8);
  return 0;
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

  uint64_t ossl, local, nss, blend, ecb, ctr1, ctr2, 
           ctr3, ctr4, ctr5, ctr6, ctr7, ctr8, ctd;
  // Subsequent calls are independent. (That is, their execution
  // may overlap.)
  printf("Overlapped:\n");
  REP(ossl, aesni_set_encrypt_key((void*)test_k, 256, &aeskey));
  REP(local, Rijndael_k8w4_expandkey(ks_this, test_k));
  REP(nss, intel_aes_encrypt_init_256(ks_this, test_k));
  printf("\nDependent:\n");
  // Subsequent calls chain on the last round keys.
  //REP(ossl, aesni_set_encrypt_key(aeskey.rd_key + 60-16, 256, &aeskey));
  //REP(ossl, aesni_set_encrypt_key(aeskey.rd_key + 60-16, 256, &aeskey));
  //REP(local, Rijndael_k8w4_expandkey(ks_this, ks_this+60-16));
  //REP(local, Rijndael_k8w4_expandkey(ks_this, ks_this+60-16));
  //REP(nss, intel_aes_encrypt_init_256(ks_this, test_k+60-16));
  //REP(nss, intel_aes_encrypt_init_256(ks_this, test_k+60-16));
  //REP(blend, aes_ctr(ks_this, test_k+60-16));
  uint64_t out[64] = {0};
  REP(ecb, aes256_ecb(ks_this, test_k+60-16, out));
  REP(ctr1, aes256_ctr1(ks_this, test_k+60-16, out));
  REP(ctr2, aes256_ctr2(ks_this, test_k+60-16, out));
  REP(ctr3, aes256_ctr3(ks_this, test_k+60-16, out));
  REP(ctr4, aes256_ctr4(ks_this, test_k+60-16, out));
  REP(ctr5, aes256_ctr5(ks_this, test_k+60-16, out));
  REP(ctr6, aes256_ctr6(ks_this, test_k+60-16, out));
  REP(ctr7, aes256_ctr7(ks_this, test_k+60-16, out));
  REP(ctr8, aes256_ctr8(ks_this, test_k+60-16, out));
  REP(ctd,  aes_ctr_continue(ks_this, test_k+60-16, out));
 
  printf("ratio=%5.2f\n", cpc(local) / cpc(ossl));
  printf("ratio=%5.2f\n", cpc(ossl) / cpc(local));

  return 0;
}

int main(void) {
  test_expansion();
  test_ctrs();
#ifdef TIMEIT
  time_expansion();
#endif
  return 0;
}
