# Faster AES key expansion

Some code implementing faster key expansion for Rijndael(Nk=8,Nw=4),
otherwise known as AES-256.

Details in [expand.s](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/expand.s)

About 1.8x faster than OpenSSL on Intel Well. Untested on Intel Bridge (I'd expect a slightly smaller gain from this strategy for that microarchitecture). Uses AVX128 instructions (port to SSE forthcoming).

How? By avoiding AESKEYGENASSIST in favor of AESENCLAST+PSHUFB.

Crystal Well (i7-4850HQ), Turbo Boost disabled:

    OpenSSL:  195 cycles
    expand.s: 108 cycles

[ossl_expansion.s](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/ossl_expansion.s): Extracted from the voluminous output of [aesni-x86_64.pl](https://github.com/openssl/openssl/blob/master/crypto/aes/asm/aesni-x86_64.pl)

To test, run `./test_gnu.sh`. (The build script has only been tested on OSX, with a recent version of Clang's built-in assembler.)
