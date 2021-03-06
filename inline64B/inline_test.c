#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "print-impl.h"

// A key that isn't all zeros...
static const uint32_t test_k[8] =
    {0x11223344, 0x10203040, 0x0a0b0c0d, 0xe0f01020, 0xff, 0xcc, 0xdd, 0xee};

// OpenSSL expanded AES key structure.
typedef struct aes_key_st {
  uint32_t rd_key[4 * (14 + 1)];
  int rounds;
} AesKey;
extern void AES_set_encrypt_key(const void*, int, AesKey*);


extern void aes256_ctr(void* out,
                        const void* in,
                        size_t oplen,
                        const void* key,
                        const void* nc);
extern void aes256_ctr8(void* out,
                        const void* in,
                        const void* key,
                        const void* nc,
                        void* ks);

extern void aesni_set_encrypt_key(const void*, int, AesKey*);
extern void aesni_ctr32_encrypt_blocks(const void* in,
                                       void* out,
                                       size_t blocks,
                                       const AesKey* key,
                                       const char* ivec);

/** Expand a key and encrypt 64B with it in CTR mode; this uses the
 *  aesni_ API for a fairer comparison. Note that this way of invoking
 *  CTR mode does not produce correct results for blocks % 8 != 0.
 */
static inline void osslctr(void* buf_ossl, const void* k, void* aeskey, size_t blocks) {
  aesni_set_encrypt_key(k, 256, aeskey);
  aesni_ctr32_encrypt_blocks(buf_ossl, buf_ossl, 4, aeskey, buf_ossl);
}

extern void AES_ctr128_encrypt(const void* in,
                               void* out,
                               size_t len,
                               const AesKey* key,
                               uint8_t ivec[16],
                               uint8_t ecount_buf[16],
                               unsigned int* num);

/** Expand a key and encrypt 64B with it. This uses OpenSSL's public API.
 *  And incurs some additional overhead as a result.
 */
static inline void osslctr128(void* buf_ossl, const void* k, void* aeskey) {
  uint64_t ecou[2] = {0};
  uint64_t ivec[2] = {0};
  uint32_t num = 0;
  AES_set_encrypt_key(k, 256, aeskey);
  AES_ctr128_encrypt(
      buf_ossl, buf_ossl, 16 * 4, aeskey, (void*)ivec, (void*)ecou, &num);
}

static const uint8_t ZERO[128] = {0};

int test_ctrs(void) {
  uint32_t ks[60] = {0};
  AesKey aeskey;
  AES_set_encrypt_key(test_k, 256, &aeskey);
  printf("rounds = %u\n", aeskey.rounds);

  for (int i = 128; i > 0; i--) {
    uint8_t buf[256] = {0};
    uint8_t buf_ossl[256] = {0};

    uint8_t ivec[16] = {0};
    uint8_t ecou[16] = {0};
    uint32_t num = 0;

    uint8_t iv[16] = {0};
    for (int j = 0; j < i; j++) {
      buf[j] = buf_ossl[j] = j+1;
    }
    memset(ivec, 0xef, 12);
    memset(iv, 0xef, 12);
    AES_ctr128_encrypt(buf_ossl, buf_ossl, i, &aeskey, ivec, ecou, &num);
    aes256_ctr(buf, buf, i, test_k, iv);
    if (memcmp(buf, buf_ossl, i) != 0) {
      printf("%u CTR: FAIL\n", i);
      printbuf(buf, i);
      printbuf(buf_ossl, i);
      return -1;
    } else {
      printf("%u CTR: OKAY\n", i);
    }
    if (memcmp(buf + i, ZERO, 128 - i) != 0) {
      printf("%u CTR: OVERWRITE\n", i);
      printbuf(buf, 128);
      printbuf(buf_ossl, 128);
    } else {
      /*printf("%u CTR_32: OOKAYn", N);     */
    }
    if (i == 128) {
      printbuf(buf, 128);    
      printbuf(buf_ossl, 128);
    }
  }
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
  uint64_t buf[64] = {0};
  AesKey aeskey;
  AES_set_encrypt_key(test_k, 256, &aeskey);


  // Subsequent calls are independent. (That is, their execution
  // may overlap.)
  printf("AES-256-CTR 64B:\n");
  uint64_t ossl32, local, ossl128; // cycle counters
  REP(ossl128, osslctr128(buf, test_k, &aeskey));
  REP(ossl32, osslctr(buf, test_k, &aeskey, 4));
  REP(local, aes256_ctr(buf, buf, 64, test_k,  buf));
  REP(ossl32, osslctr(buf, test_k, &aeskey, 8));
  REP(local, aes256_ctr(buf, buf, 128, test_k,  buf));

  printf("%5.2fx faster\n", cpc(ossl32) / cpc(local));

  return 0;
}

int main(void) {
  test_ctrs();
#ifdef TIMEIT
  time_expansion();
#endif
  return 0;
}
