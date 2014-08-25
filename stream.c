#include <stddef.h>
#include <stdint.h>
#include <string.h>

extern void Rijndael_k32b32_expandkey(void* ks, const void* key);
extern void Rijndael_k32b32_ctr(void* restrict ks,
                                void* dst,
                                const void* src,
                                void* nc,
                                uint64_t nblocks);

int crypto_stream_rijndael256ctr_gil_xor(unsigned char* out,
                                         const unsigned char* in,
                                         unsigned long long inlen,
                                         const unsigned char* n,
                                         const unsigned char* k) {
  uint64_t ks[120] = {0};
  Rijndael_k32b32_expandkey(ks, k);
  uint64_t nc[2] = {0};
  memcpy(nc, n, 24);
  if (inlen >= 128) {
    uint64_t nblocks = inlen / 128;
    Rijndael_k32b32_ctr(ks, out, in, nc, nblocks);
    inlen -= (nblocks * 128);
  }
  if (inlen != 0) {
    uint64_t buf[16] = {0};
    memcpy(buf, in, inlen);
    Rijndael_k32b32_ctr(ks, buf, buf, nc, 1);
    memcpy(out, buf, inlen);
  }
  memset(nc, 0, 2 * 8);
  memset(ks, 0, 120 * 8);
  return 0;
}

int crypto_stream_rijndael256ctr_gil(unsigned char* out,
                                     unsigned long long outlen,
                                     const unsigned char* n,
                                     const unsigned char* k) {
  uint64_t ks[120] = {0};
  Rijndael_k32b32_expandkey(ks, k);
  uint64_t nc[2] = {0};
  memcpy(nc, n, 24);
  memset(out, 0, outlen);
  if (outlen >= 128) {
    uint64_t nblocks = outlen / 128;
    Rijndael_k32b32_ctr(ks, out, out, nc, nblocks);
    outlen -= (nblocks * 128);
  }
  if (outlen != 0) {
    uint64_t buf[16] = {0};
    memset(buf, 0, 128);
    memcpy(buf, out, outlen);
    Rijndael_k32b32_ctr(ks, buf, buf, nc, 1);
    memcpy(out, buf, outlen);
    memset(buf, 0, 128);
  }
  memset(nc, 0, 2 * 8);
  memset(ks, 0, 120 * 8);
  return 0;
}
