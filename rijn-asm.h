#ifndef RIJNDAEL256_ASM_H_
#define RIJNDAEL256_ASM_H_
#include <stdint.h>
// Key expansion functions.
extern void Rijndael_k32b16_expandkey(void* ks, const void* key);
extern void Rijndael_k32b32_expandkey(void* ks, const void* key);

// Low-level encryption functions for ECB mode.
extern void Rijndael_k32b32_encrypt_x1(
    const void* restrict ks, void* dst, const void* src);
extern void Rijndael_k32b32_encrypt_x4(
    const void* restrict ks, void* dst, const void* src);
extern void Rijndael_k32b16_encrypt_x8(
    const void* restrict ks, void* dst, const void* src);

// Low-level encryption functions for CTR mode.
extern void Rijndael_k32b32_encrypt_ctr(
    void* restrict ks, void* dst, const void* src, void* nc, uint64_t nblocks);
#endif
