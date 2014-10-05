# Faster AES key expansion

Some code implementing faster key expansion for Rijndael(Nk=8,Nw=4),
otherwise known as AES-256.

Details in [expand.s](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/expand.s)

About 1.8x faster than OpenSSL on Haswell/Crystalwell. Updated to add:
About 10 cycles slower that Shay Gueron and Vlad Krasnov's implementation
for Windows in NSS.

How? By avoiding AESKEYGENASSIST in favor of AESENCLAST+PSHUFB.

## Details

After writing expand.s, I discovered that his and Vlad Krasnov's implementation of [key expansion for NSS on Windows does][nss_masm], in fact, uses just this approach. Plus another clever trick involving shifting. (The implementation for [Unix systems][nss_gas] in NSS uses AESKEYGENASSIST, oddly enough.)

Crystal Well (i7-4850HQ), Turbo Boost disabled:

    OpenSSL:     195 cycles
    expand.s:    108 cycles
    intel-nss.s:  97 cycles

To test, run `./test_avx.sh`. (The build script has only been tested on OSX, with a recent version of Clang's built-in assembler and yasm.)

[ossl_expansion.s](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/ossl_expansion.s): Extracted from the voluminous output of [aesni-x86_64.pl](https://github.com/openssl/openssl/blob/master/crypto/aes/asm/aesni-x86_64.pl)

[strip_ossl.patch](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/strip_ossl.patch): A patch to strip the multi keylength selection code from the OpenSSL implementation; doesn't affect benchmarks.

## Credits

Agner Fog's [instruction tables][agner] makes the benefits of this approach obvious, if you are the sort of person who really enjoys reading instruction tables.

Shay Gueron gives an example in his [AES-NI whitepaper][aesniwp] of doing inline AES key-expansion using AESENCLAST for the 128-bit case.

[nss_gas]: http://hg.mozilla.org/projects/nss/file/044f3e56c4d1/lib/freebl/intel-aes.s#l1580
[nss_masm]: http://hg.mozilla.org/projects/nss/file/044f3e56c4d1/lib/freebl/intel-aes-x64-masm.asm#l435
[agner]: http://agner.org/optimize/
[aesniwp]: https://software.intel.com/en-us/articles/intel-advanced-encryption-standard-aes-instructions-set "Intel® Advanced Encryption Standard (AES) Instructions Set - Rev 3.01"
