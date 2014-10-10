# On-the-fly key expansion for AES-256

(This is a preview, since I've mentioned this to a few people now.)

Shay Gueron suggests expanding AES keys on-the-fly in his AES-NI whitepaper.
So far as I know, no library implements this strategy.

It can, in theory, produce better than linear performance. This code isn't
there yet. (In particular, some key expansion muops would need to be
dispatched in the same clock cycle as port 5 muops.)

However: Consider, e.g., encrypting 64B messages with AES-256-CTR. OpenSSL
expands the key and, only then, generates the keystream. If you interleave
key expansion and keystream generation:

    OpenSSL with aeskeygenassist: 292 cycles
    Interleaved with aesenclast:  154 cycles

Or 1.9x faster. (See the expansion subdirectory for details of how AESENCLAST
key expansion works.)

This technique can obviously be expanded to messages of arbitrary length using,
for short messages:

- Short messages: 8 cases of on-the-fly expansion
- Long messages: 8-case prelude, long-message case,
  and an 8-case postlude.

Some code can be shared. The loops generally don't benefit that much from being
fully unrolled.
