/* Rijndael(Nw=8,Nk=8) key schedule
 *
 * Implementor: David Leon Gil
 *
 * (This file has been translated from the original YASM.)
 */

.data
.align 5
__Rijndael_k32_shuffle_mask:
  .byte 0xff, 0xff, 0xff, 0xff
  .byte 0x0, 0x1, 0x2, 0x3
  .byte 0x4, 0x5, 0x6, 0x7
  .byte 0x8, 0x9, 0xa, 0xb

.text
.align 4
_Rijndael_k32_expand_one:
  vpshufd            $-0x1, %xmm2, %xmm2     ## xmm2 = xmm2[3,3,3,3]
  vpshufb            %xmm5, %xmm1, %xmm4
  vpxor              %xmm4, %xmm1, %xmm1
  vpshufb            %xmm5, %xmm4, %xmm4
  vpxor              %xmm4, %xmm1, %xmm1
  vpshufb            %xmm5, %xmm4, %xmm4
  vpxor              %xmm4, %xmm1, %xmm1
  vpxor              %xmm2, %xmm1, %xmm1
  vmovdqu            %xmm1, 0x0(%rdi)
  vaeskeygenassist   $0x0,  %xmm1, %xmm4
  vpshufd            $-0x56,%xmm4, %xmm2    ## xmm2 = xmm4[2,2,2,2]
  vpshufb            %xmm5, %xmm3, %xmm4
  vpxor              %xmm4, %xmm3, %xmm3
  vpshufb            %xmm5, %xmm4, %xmm4
  vpxor              %xmm4, %xmm3, %xmm3
  vpshufb            %xmm5, %xmm4, %xmm4
  vpxor              %xmm4, %xmm3, %xmm3
  vpxor              %xmm2, %xmm3, %xmm3
  vmovdqu            %xmm3, 0x10(%rdi)
  addq               $0x20, %rdi
  retq

.align 4
.global _Rijndael_k32b32_expandkey
_Rijndael_k32b32_expandkey:
  vzeroall
  vmovdqu           0x00(%rsi), %xmm1
  vmovdqu           0x10(%rsi), %xmm3
  vmovdqu           %xmm1, 0x00(%rdi)
  vmovdqu           %xmm3, 0x10(%rdi)
  addq              $0x20, %rdi
  vmovdqa __Rijndael_k32_shuffle_mask(%rip), %xmm5
  vaeskeygenassist  $0x1, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x2, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x4, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x8, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x10, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x20, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x40, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $-0x80, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x1b, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x36, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x6c, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $-0x28, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $-0x55, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vaeskeygenassist  $0x4d, %xmm3, %xmm2
  callq _Rijndael_k32_expand_one
  vzeroall
  retq
