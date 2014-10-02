# Faster AES key expansion

Some code implementing faster key expansion for Rijndael(Nk=8,Nw=4),
otherwise known as AES-256.

About 1.7x faster than OpenSSL on \*Well. Untested on \*Bridge; gain
probably a little smaller.

How? By avoiding AESKEYGENASSIST in favor of AESENCLAST+PSHUFB.

Crystal Well (i7-4850HQ), Turbo Boost disabled:

    OpenSSL:  195 cycles
    expand.s: 113 cycles

ossl_expansion.s: Extracted from the voluminous output of https://github.com/openssl/openssl/blob/master/crypto/aes/asm/aesni-x86_64.pl
