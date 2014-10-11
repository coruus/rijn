#ifndef _RIJNDAEL256CTR_H
#define _RIJNDAEL256CTR_H
#include <stdlib.h>

extern void Rijndael_k32b32_encrypt_x4(const void* ks, void* out, const void* in);
extern void Rijndael_k32b32_expandkey(void* ks, const void* key);

int rijndael256_ctr_stream(uint8_t* out, uint64_t oplen, const void* _n, const void* k); 
int rijndael256_ctr_xor(uint8_t* out, const uint8_t* in, size_t oplen, const void* _n, const void* k);
#endif
