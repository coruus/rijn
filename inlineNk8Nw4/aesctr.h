#ifndef _AESCTR_H
#define _AESCTR_H
#include <stdint.h>

void aes256_ctr1_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr2_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr3_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr4_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr5_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr6_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr7_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr8_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
void aes256_ctr1(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
void aes256_ctr2(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
void aes256_ctr3(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
void aes256_ctr4(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
void aes256_ctr5(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
void aes256_ctr6(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
void aes256_ctr7(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
void aes256_ctr8(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
#endif
