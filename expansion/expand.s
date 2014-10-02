#define T1   %xmm0
#define T2   %xmm1
#define KEY1 %xmm2
#define KEY2 %xmm3
#define RC   %xmm4

#define KEY  %rsi
#define KS   %rdi

.data
.align 5
__rc:
  .byte 1, 0, 0, 0
  .byte 1, 0, 0, 0
  .byte 1, 0, 0, 0
  .byte 1, 0, 0, 0
.quad 0, 0

__shuf_1:
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
.quad 0, 0

__shuf_2:
  .byte 9, 6, 3, 12
  .byte 9, 6, 3, 12
  .byte 9, 6, 3, 12
  .byte 9, 6, 3, 12
.quad 0, 0

__shuf_l:
  .byte 0xff, 0xff, 0xff, 0xff
  .byte 0x0, 0x1, 0x2, 0x3     
  .byte 0x4, 0x5, 0x6, 0x7
  .byte 0x8, 0x9, 0xa, 0xb


#define SHUF_L __shuf_l(%rip)
#define SHUF_1 __shuf_1(%rip)
#define SHUF_2 __shuf_2(%rip)
#define _RC __rc(%rip)

.macro linearmix key, new
  VPSHUFB  SHUF_L, \key, T1
  VPXOR      \key,   T1, \key
  VPSHUFB  SHUF_L, \key, T1
  VPXOR      \key,   T1, \key
  VPSHUFB  SHUF_L, \key, T1
  VPXOR      \key,   T1, \key
  VPXOR      \key, \new, \key
.endm

.text
.L_DR:
//__Rijndael_k8w4_expandkey_doubleround:
  VPXOR           T2,   T2, T2
  VAESENCLAST     T2, KEY2, T2
  VPSHUFB     SHUF_2,   T2, T2
  VPXOR           RC,   T2, T2
  // Shift the round constant, to prepare for the next round
  VPSLLD          $1,   RC, RC
  
  linearmix KEY1,   T2
  VMOVDQU  KEY1,  0(KS)

  VPXOR           T1,   T1, T1
  VPSHUFB     SHUF_1, KEY1, T2
  VAESENCLAST     T1,   T2, T2

  linearmix KEY2,   T2
  VMOVDQU KEY2, 16(KS)

  ADDQ $32, KS
  RET

#define _DR __Rijndael_k8w4_expandkey_doubleround

.globl _Rijndael_k8w4_expandkey
_Rijndael_k8w4_expandkey:
  VZEROUPPER

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  // Load the initial value of the round constant
  VMOVDQU       _RC, RC
  // Copy k[0:8] to ks[0:8]
  VMOVDQU      KEY1,  0(KS)
  VMOVDQU      KEY2, 16(KS)
  ADD          $32, KS

  // Rounds 2..13
  CALL .L_DR
  CALL .L_DR
  CALL .L_DR
  CALL .L_DR
  CALL .L_DR
  CALL .L_DR

  // Round 14
  VPXOR           T2,   T2, T2
  VAESENCLAST     T2, KEY2, T2
  VPSHUFB     SHUF_2,   T2, T2
  VPXOR           RC,   T2, T2
  
  linearmix KEY1,   T2
  VMOVDQU   KEY1, 0(KS)
  // Zeroize registers.
  VZEROALL
  RET
