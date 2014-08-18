rijn
====

A fairly unoptimized implementation of Rijndael with 256-bit blocksize and 256-bit keysize,
using AES-NI. Should work on Sandy/Ivy Bridge, only tested on Haswell thus far.

Performance:

    Rijndael256 (pblendvb)     3.8 rcpb
    Rijndael256                1.3 rcpb
    AES256                     0.6 rcpb

It is mostly untested; please don't use this (except for fun) at the moment.

## Optimization notes

Intel's AES-NI whitepaper suggests using `vpblendvb`. This requires 2 mu-ops to be dispatched to
port 5. Port 5 pressure much? Bitops have more ports available and higher throughput; so just
do a masked swap with xor. (Difference: factor of about 2.2x, even translating C intrinsics to
assembly.)

It could be optimized further on Haswell by operating on much larger blocks and using non-half-
crossing AVX2 ops, but there's little need.

## Thoughts

Rijndael-256 has a slender security margin; it would be preferable to add a round or two. This
is fairly cheap, and already considered by the Rijndael book.
