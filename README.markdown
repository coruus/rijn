rijn
====

A fairly unoptimized implementation of Rijndael with 256-bit blocksize and 256-bit keysize.

It is, nonetheless, about 2.2x faster than Intel's suggested implementation in their AES-NI
whitepaper; even when that implementation is translated to assembly.

(It could be optimized further on Haswell by operating on much larger blocks and using non-
crossing AVX2 ops, but this is rather complex.)

(A brief note: Shay Gueron's whitepaper suggests implementing the shuffle between the two
halves of the 32-byte state using vpblendvb. This is not a good idea; vpblendvb dispatches
two muops to port 5, which is already a bottleneck. I imagine that he was anticipating future
improvements to the architecture that haven't yet happened.)

But, big picture: What's the cost of getting a 256-bit blocksize? (And thus a 24-byte nonce and
64-bit counter for CTR mode.) Equivalent to about 2 calls to the underlying block cipher; but
with the need to keyschedule only once.
