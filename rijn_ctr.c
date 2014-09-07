#include "rijndael256ctr.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Many platforms define a memcpy or memset macro.
// We don't want this.
#undef memcpy
#undef memset

// Use __builtin_memcpy and __builtin_memset if available.
#ifdef __has_builtin
#if __has_builtin(__builtin_memcpy)
#define memcpy __builtin_memcpy
#endif // __has_builtin(__builtin_memcpy)
#if __has_builtin(__builtin_memset)
#define memset __builtin_memset
#endif
#endif

// This is included for SUPERCOP compatibility; please use a libc (and
// compiler) that supports memset_s.
#undef memset_s
#define memset_s(DST, DSTLEN, VAL, OPLEN) memset((DST), (DSTLEN), (VAL))

typedef uint64_t v16u8 __attribute__((__vector_size__(16*8)));

static const v16u8 increment = { 0, 0, 0, 4,
                                 0, 0, 0, 4,
                                 0, 0, 0, 4,
                                 0, 0, 0, 4 };

static inline void _full(const void* ks, void* out, const void* in, v16u8* nc, size_t nblocks) {
  v16u8* outv = (v16u8*)out;
  v16u8* inv = (v16u8*)in;
  while (nblocks != 0) {
    v16u8 buf = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };  
    Rijndael_k32b32_encrypt_x4(ks, &buf, nc);
    *outv = *inv ^ buf;
    outv++;
    inv++;
    nblocks--;
    *nc = *nc + increment;    
  }
}

static inline void _partial(const void* ks, void* out, const void* in, v16u8* nc, size_t inlen) {
  uint8_t* outb = (uint8_t*)out;
  uint8_t* inb = (uint8_t*)in;
  v16u8 buf = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  uint8_t* bufb = (uint8_t*)&buf;
  Rijndael_k32b32_encrypt_x4(ks, &buf, nc);
  for (size_t i = 0; i < inlen; i++) {
    outb[i] = inb[i] ^  bufb[i];
  }
}

void rijndael256_ctr(void* out,
                     const void* in,
                     size_t oplen,
                     const void* k,
                     const void* _n) {
  if (oplen == 0) {
    return;
  } 
  uint64_t* n = (uint64_t*)_n;

  // Setup four nonce+counter blocks.
  v16u8 nc = { n[0], n[1], n[2], 0,
               n[0], n[1], n[2], 1,
               n[0], n[1], n[2], 2,
               n[0], n[1], n[2], 3 };
  uint32_t ks[120] = {0};

  // Expand the key.
  Rijndael_k32b32_expandkey(ks, k);
  if (oplen >= 128) {
    _full(ks, out, in, &nc, oplen / 128);
  }
  uint64_t done = (oplen / 128) * 128;
  oplen -= done;
  if (oplen != 0) {
    _partial(ks, (uint8_t*)out + done, (uint8_t*)in + done, &nc, oplen);
  }
  memset_s(ks, 120*4, 0, 120*4);
  return; 
}
