# Faster AES key expansion

Some code implementing faster key expansion for Rijndael(Nk=8,Nw=4),
otherwise known as AES-256.

Details in [expand.s](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/expand.s)

About 1.8x faster than OpenSSL on Haswell/Crystalwell. 

How? By avoiding AESKEYGENASSIST in favor of AESENCLAST+PSHUFB.

Crystal Well (i7-4850HQ), Turbo Boost disabled:

    OpenSSL:  195 cycles
    expand.s: 108 cycles

To test, run `./test_gnu.sh`. (The build script has only been tested on OSX, with a recent version of Clang's built-in assembler.)

[ossl_expansion.s](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/ossl_expansion.s): Extracted from the voluminous output of [aesni-x86_64.pl](https://github.com/openssl/openssl/blob/master/crypto/aes/asm/aesni-x86_64.pl)

[strip_ossl.patch](https://github.com/coruus/rijn/blob/rijnK8W4/expansion/strip_ossl.patch): A patch to strip the multi keylength selection code from the OpenSSL implementation; doesn't affect benchmarks.

## Other microarchitectures

Untested on Bridge (I'd expect a slightly smaller gain from this strategy for that microarchitecture). 

An SSSE3 version is available; I am uncertain whether this code will be faster on microarchs that don't support AVX. (The performance of the SSSE3 code on Haswell is, of course, identical to the performance of the AVX code.)

If you have an older platform available, benchmark numbers greatly appreciated.

## Other keylengths

I don't intend on porting this to other keylengths. But there is no reason that this strategy will not produce similar performance gains.

## Credits

Agner Fog's [instruction tables](http://agner.org/optimize/) makes this approach obvious, if you are the sort of person who really enjoys reading instruction tables.)
