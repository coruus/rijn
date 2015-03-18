/* AVX: AES-256 key expansion.
 *
 * Implementor:  David Leon Gil
 * License:      CC0, acknowledgement kindly requested.
 * Inspired by:  Shay Gueron's classic AES-NI whitepaper.
 * Preempted by: Shay Gueron and Vlad Krasnov's MASM implementation for
 *               NSS. (Rev'd version uses a trick from there.)
 * Ack:          Agner Fog's essential instruction tables. Why doesn't
 *               Intel do this work?
 */

#define T0   %xmm0
#define T1   %xmm1
#define KEY1 %xmm2
#define KEY2 %xmm3
#define RC   %xmm4
#define ZERO %xmm5
#define X0 %xmm6
#define X1 %xmm7
#define X2 %xmm8
#define X3 %xmm9
#define X4 %xmm10
#define X5 %xmm11
#define X6 %xmm12
#define X7 %xmm13
#define X8 %xmm14
#define Y0 %ymm6
#define Y1 %ymm7
#define Y2 %ymm8
#define Y3 %ymm9
#define Y4 %ymm10
#define Y5 %ymm11
#define Y6 %ymm12
#define Y7 %ymm13
#define Y8 %ymm14

#define KEY  %rsi
#define KS   %rdi

.data
.align 5
__rc:
  .byte 1, 0, 0, 0
  .byte 1, 0, 0, 0
  .byte 1, 0, 0, 0
  .byte 1, 0, 0, 0

__shuf_2:
  .byte 13, 14, 15, 12
  .byte 13, 14, 15, 12
  .byte 13, 14, 15, 12
  .byte 13, 14, 15, 12
 
__ctrswap:
  .byte  0,  1,  2,  3
  .byte  4,  5,  6,  7
  .byte  8,  9, 10, 11
  .byte 15, 14, 13, 12
  .byte  0,  1,  2,  3
  .byte  4,  5,  6,  7
  .byte  8,  9, 10, 11
  .byte 15, 14, 13, 12

__zeroone:
__zero:
  .quad 0
  .quad 0
__onetwo:
__one:
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 1, 0, 0, 0
__twotwo:
__two:
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 2, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 2, 0, 0, 0

#define SHUF_2 __shuf_2(%rip)
#define _RC    __rc(%rip)

.macro linearmix key, new
  VPSLLDQ $4, \key, T1
  VPXOR T1, \key, \key
  VPSLLDQ $4, T1, T1
  VPXOR T1, \key, \key
  VPSLLDQ $4, T1, T1
  VPXOR T1, \key, \key
  VPXOR T0, \key, \key
.endm

.macro do const
  MOV \const, %rax
  VMOVQ %rax, RC
  PSHUFD $0, RC, RC
  VPSHUFB     SHUF_2, KEY2, T0
  VAESENCLAST RC,   T0, T0

  linearmix KEY1,   T0
  VMOVDQU   KEY1,  16*2(KS)

  VPSHUFD      $0xff, KEY1, T0
  VAESENCLAST   ZERO,   T0, T0

  linearmix KEY2,   T0
  VMOVDQU KEY2, 16*3(KS)
  ADDQ $32, KS
.endmacro

.text

.align 5
.globl _Rijndael_k32b32_expandkey
_Rijndael_k32b32_expandkey:
  VZEROUPPER

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU      KEY1,  0(KS)
  VMOVDQU      KEY2, 16(KS)
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO
/*
  MOV $7, %rcx
  .align 4
  L_expandkey:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix KEY1,   T0
    VMOVDQU   KEY1,  16*2(KS)

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2,   T0
    VMOVDQU KEY2, 16*3(KS)
  ADDQ $32, KS
  DEC %rcx
  JNZ L_expandkey*/

  do $0x01
  do $0x02
  do $0x04
  do $0x08
  do $0x10
  do $0x20
  do $0x40
  do $0x80
  
  do $0x1b
  do $0x36
  do $0x6c
  do $0xd8
  do $0xab
  do $0x4d

  // Zeroize registers.
  VZEROALL
  XOR KS, KS
  XOR KEY, KEY
  RET
