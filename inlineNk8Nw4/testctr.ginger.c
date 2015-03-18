#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "print-impl.h"
#include "aesctr.h"
// A key that isn't all zeros...
static const uint32_t test_k[8] = { 0x11223344, 0x10203040, 
                                    0x0a0b0c0d, 0xe0f01020,
                                    0xff, 0xcc, 0xdd, 0xee};

// OpenSSL structures.
typedef struct aes_key_st {
    uint32_t rd_key[4 * (14 + 1)];
    int rounds;
} AesKey;
extern void aesni_set_encrypt_key(const void*, int, AesKey*);
extern void aesni_ctr32_encrypt_blocks(const void *in, void *out, size_t blocks, const AesKey *key, const char *ivec);
extern void AES_encrypt(const uint8_t *in, uint8_t *out,
                                const AesKey *key);
extern void AES_encrypt(void *in, void *out, const AesKey *key);
    static const uint8_t ZERO[128] = {0};

/*% for i in range(8) */
int test_`i`(void) {
  {  
    uint32_t ks[60] = {0};
    AesKey aeskey;
    //aeskey.rounds = 13;
    AES_set_encrypt_key((void*)test_k, 256, &aeskey);
    uint8_t buf[128] = {0};
    uint8_t buf_ossl[128] = {0};
    uint8_t ivec[16] = {0};
    uint8_t ecou[16] = {0};
    unsigned int num = 0;
    aes256_ctr`i`(ks, test_k, buf);                                      
    aesni_ctr32_encrypt_blocks(buf_ossl, buf_ossl, `i`, &aeskey, ivec); 
    if (memcmp(buf, buf_ossl, `16 * i`) != 0) {                                  
      printf("%u CTR_32: FAIL\n", `i`);                                          
      printbuf(buf, 128);                                                      
      printbuf(buf_ossl, 128);                                                 
    } else {                                                                   
      printf("%u CTR: OKAY\n", `i`);                                          
    }                                                                          
    if ((128 - 16 * `i`) && (memcmp(buf + `16 * i`, ZERO, `128 - 16 * i`) != 0)) {   
      printf("%u CTR: OVERWRITE\n", `i`);                                     
    } else {                                                                   
      /*printf("%u CTR_32: OOKAY\n", N);     */                                   
    }                                                                          
  }
}
/*% endfor */

int test_all(void) {
  int err = 0;
/*% for i in range(8) */
  err = test_`i`();
  if (err) { return err; }
/*% endfor */
  return 0;
}



/*#define N (1 << 21)
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
}*/

int main(void) {
//  test_expansion();
  test_all();
#ifdef TIMEIT
  time_expansion();
#endif
  return 0;
}
