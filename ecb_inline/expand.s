/* AVX2: AES-256 key expansion.
 *
 * Implementor: David Leon Gil
 * License:     Apache2 
 * Inspired by: Shay Gueron's classic AES-NI whitepaper.
 * Ack:         Agner Fog's instruction tables.
 */

#define xT1   %xmm0
#define xT2   %xmm1
#define xK1   %xmm2
#define xK2   %xmm3
#define RC    %xmm4
#define x0    %xmm5
#define x1    %xmm6
#define x2    %xmm7
#define x3    %xmm8
#define x4    %xmm9
#define x5    %xmm10
#define x6    %xmm11
#define x7    %xmm12
#define xK3   %xmm13
#define xK4   %xmm14

//#define KEY  %rsi
//#define KS   %rdi
#define OUT  %rdi
#define IN   %rsi
#define KS   %rdx
#define KEY  %rcx

.data
.align 5
__rc:
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 1, 0, 0
  .byte 0, 0, 0, 0
.quad 0, 0

__shuf_1:
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
.quad 0, 0

# InvShiftColumns
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
  VPSHUFB  SHUF_L, \key, xT1
  VPXOR      \key,   xT1, \key
  VPSHUFB  SHUF_L, \key, xT1
  VPXOR      \key,   xT1, \key
  VPSHUFB  SHUF_L, \key, xT1
  VPXOR      \key,   xT1, \key
  VPXOR      \key, \new, \key
.endm

#define DR DRm


.text

.macro BLOCK K
  VAESENC \K, x0, x0
  VAESENC \K, x1, x1
  VAESENC \K, x2, x2
  VAESENC \K, x3, x3
  VAESENC \K, x4, x4
  VAESENC \K, x5, x5
  VAESENC \K, x6, x6
  VAESENC \K, x7, x7
.endmacro

.macro BLOCKLAST K
  VAESENCLAST \K, x0, x0
  VAESENCLAST \K, x1, x1
  VAESENCLAST \K, x2, x2
  VAESENCLAST \K, x3, x3
  VAESENCLAST \K, x4, x4
  VAESENCLAST \K, x5, x5
  VAESENCLAST \K, x6, x6
  VAESENCLAST \K, x7, x7
.endmacro

.macro DRm inK1, inK2, K1, K2
//__Rijndael_k8w4_expandkey_doubleround:
  VMOVDQA \inK1, \K1
  VMOVDQA \inK2, \K2
  VAESENCLAST     RC,  \K2, xT2
  VPSHUFB     SHUF_2,   xT2, xT2
  // Shift the round constant, to prepare for the next round
  VPSLLD          $1,   RC, RC
  
  linearmix \K1,   xT2
  VMOVDQU   \K1,  0(KS)

  VPXOR           xT1,   xT1, xT1
  VPSHUFB       SHUF_1,  \K1, xT2
  VAESENCLAST     xT1,   xT2, xT2

  linearmix \K2,  xT2
  VMOVDQU   \K2, 16(KS)

  ADDQ $32, KS
.endmacro

.globl _Rijndael_k8w4_expandkey
_Rijndael_k8w4_expandkey:
  VZEROUPPER

  VMOVDQU    0(KEY), xK1
  VMOVDQU   16(KEY), xK2
  // Load the initial value of the round constant
  VMOVDQU       _RC, RC
  // Copy k[0:8] to ks[0:8]
  VMOVDQU      xK1,  0(KS)
  VMOVDQU      xK2, 16(KS)
  ADD          $32, KS
  
  VPXOR  0*16(IN), xK1, x0
  VPXOR  1*16(IN), xK1, x1
  VPXOR  2*16(IN), xK1, x2
  VPXOR  3*16(IN), xK1, x3
  VPXOR  4*16(IN), xK1, x4
  VPXOR  5*16(IN), xK1, x5
  VPXOR  6*16(IN), xK1, x6
  VPXOR  7*16(IN), xK1, x7

  DRm xK1, xK2, xK3, xK4
  BLOCK xK2  // 1
  DRm xK3, xK4, xK1, xK2
  BLOCK xK3  // 2
  BLOCK xK4  // 3
  DRm xK1, xK2, xK3, xK4
  BLOCK xK1  // 4
  BLOCK xK2  // 5
  DRm xK3, xK4, xK1, xK2
  BLOCK xK3  // 6
  BLOCK xK4  // 7
  DRm xK1, xK2, xK3, xK4
  BLOCK xK1  // 8
  BLOCK xK2  // 9
  DRm xK3, xK4, xK1, xK2
  BLOCK xK3  // 10
  BLOCK xK4  // 11
  BLOCK xK1  // 12

  // Round 14
  VAESENCLAST     RC,  xK2, xT2
  VPSHUFB     SHUF_2,  xT2, xT2
  
  BLOCK xK2  // 13
  
  linearmix xK1,   xT2
  VMOVDQU   xK1, 0(KS)

  BLOCKLAST xK1  // 14

.LDONE:
  VMOVDQU   x0, 0*16(OUT)
  VMOVDQU   x1, 1*16(OUT)
  VMOVDQU   x2, 2*16(OUT)
  VMOVDQU   x3, 3*16(OUT)
  VMOVDQU   x4, 4*16(OUT)
  VMOVDQU   x5, 5*16(OUT)
  VMOVDQU   x6, 6*16(OUT)
  VMOVDQU   x7, 7*16(OUT)

  // Zeroize registers.
  VZEROALL
  RET


.globl _ecb
_ecb:
  #define OUT %rdi
  #define IN %rsi
  #define KS %rdx
  VMOVDQU  0*16(KS), xK1
  VPXOR    0*16(IN), xK1, x0
  VPXOR    1*16(IN), xK1, x1
  VPXOR    2*16(IN), xK1, x2
  VPXOR    3*16(IN), xK1, x3
  VPXOR    4*16(IN), xK1, x4
  VPXOR    5*16(IN), xK1, x5
  VPXOR    6*16(IN), xK1, x6
  VPXOR    7*16(IN), xK1, x7

  BLOCK 1*16(KS)
  BLOCK 2*16(KS)
  BLOCK 3*16(KS)
  BLOCK 4*16(KS)
  BLOCK 5*16(KS)
  BLOCK 6*16(KS)
  BLOCK 7*16(KS)
  BLOCK 8*16(KS)
  BLOCK 9*16(KS)
  BLOCK 10*16(KS)
  BLOCK 11*16(KS)
  BLOCK 12*16(KS)
  BLOCK 13*16(KS)
  BLOCKLAST 14*16(KS)

  VMOVDQU   x0, 0*16(OUT)
  VMOVDQU   x1, 1*16(OUT)
  VMOVDQU   x2, 2*16(OUT)
  VMOVDQU   x3, 3*16(OUT)
  VMOVDQU   x4, 4*16(OUT)
  VMOVDQU   x5, 5*16(OUT)
  VMOVDQU   x6, 6*16(OUT)
  VMOVDQU   x7, 7*16(OUT)

  VZEROALL
  RET
