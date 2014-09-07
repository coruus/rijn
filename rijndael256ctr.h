#ifndef _RIJNDAEL256CTR_H
#define _RIJNDAEL256CTR_H
#include <stdlib.h>

extern void Rijndael_k32b32_encrypt_x4(const void* ks, void* out, const void* in);
extern void Rijndael_k32b32_expandkey(void* ks, const void* key);

void rijndael256_ctr(void* out, const void* in, size_t oplen, const void* k, const void* _n);
#endif
