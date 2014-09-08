rijn
====

A fairly unoptimized implementation of Rijndael with 32-byte key and 32-byte
blocksize.

NB: This code is presently under development. Please do not use it for anything
other than testing.

## Credits

Adam Langley's Go implementation of Rijndael256 inspired me to write this; its
clarity was invaluable in understanding how Rijndael instances worked.

Jeet Sukumaran's Python implementation was used to generate testcases.

## Performance

Measurements taken on a Crystal Well i7-4850HQ with Turbo Boost disabled.

CTR-on-ECB C/assembler for SUPERCOP, including key-expansion:

    1350 bytes:  .74 GB/s (2.1 cpb)
    8192 bytes: 1.01 GB/s (1.5 cpb)

ECB mode, AES-256 versus Rijndael-256, not including key-expansion, for
1350 byte messages:
    
    16B blocksize: 1.1 GB/s (2.14 cpb)
    32B blocksize: 2.4 GB/s (0.97 cpb)

The relative throughput is thus ~ 0.44.

(As a reference value -- not a comparison -- `bssl speed` gives 1.7 GB/s for
AES-256-GCM on this system.)

## Notes

2.2x faster than Shay Gueron's suggested implementation in his [AESNI whitepaper][iaesni]
for Intel. (The whitepaper uses PBLENDVB, which dispatches 2 muops to p5. But p5
is already a bottleneck for the AESNI instructions.)

Room to do better on Haswell: Operate on larger blocks, then use AVX2 ops
to perform 32-byte-specific blends/shuffles.

Big picture: Double the blocksize for about the cost of 2 calls to the underlying
block cipher. This is better than any generic construction with a decent security
proof.


[iaesni]: https://software.intel.com/en-us/articles/intel-advanced-encryption-standard-aes-instructions-set "Shay Gueron. Intel Advanced Encryption Standard (AES New Instruction Set"
