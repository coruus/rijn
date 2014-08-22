#include "crypto_stream.h"
#include <stddef.h>
#include <stdint.h>

extern void Rijndael_k32b32_expandkey(void* ks, const void* key);
extern void Rijndael_k32b32_encrypt_ctr(
    void* restrict ks, void* dst, const void* src, void* nc, uint64_t nblocks);

int crypto_stream_xor(unsigned char *out, const unsigned char *in, unsigned long long inlen, const unsigned char *n, const unsigned char *k) {
	uint64_t ks[120] = {0};
	Rijndael_k32b32_expandkey(ks, k);
	uint64_t nc[2] = {0};
	memcpy(nc, n, 24);
	if (inlen >= 128) {
		uint64_t nblocks = inlen / 128;
		Rijndael_k32b32_encrypt_ctr(ks, out, in, nc, nblocks);
		inlen -= (nblocks * 128);
	}
	if (inlen > 0) {
		uint64_t buf[16] = {0};
		memcpy(buf, in, inlen);
		Rijndael_k32b32_encrypt_ctr(ks, buf, buf, nc, 1);
		memcpy(out, buf, inlen);
	}
	memset(ks, 0, 120);
	return 0;
}

int crypto_stream(unsigned char *out, unsigned long long outlen, const unsigned char *n, const unsigned char *k) {
	uint64_t ks[120] = {0};
	Rijndael_k32b32_expandkey(ks, k);
	uint64_t nc[2] = {0};
	memcpy(nc, n, 24);
	memset(out, 0, outlen);
	if (inlen >= 128) {
		uint64_t nblocks = inlen / 128;
		Rijndael_k32b32_encrypt_ctr(ks, out, out, nc, nblocks);
		inlen -= (nblocks * 128);
	}
	if (inlen > 0) {
		uint64_t buf[16] = {0};
		memcpy(buf, in, inlen);
		Rijndael_k32b32_encrypt_ctr(ks, buf, buf, nc, 1);
		memcpy(out, buf, inlen);
	}
	memset(ks, 0, 120);
	return 0;
}
