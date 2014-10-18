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

#define IN   %rsi
#define OUT  %rdi
#define LEN  %rdx
#define KEY  %rcx
#define NC   %r8
#define I    %rax
#define KS %rcx

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

.text

/* By 8 blocks, performance is linear.
 */
.align 5

.align 5
.globl _aes256_ctr4
_aes256_ctr4:
  VZEROUPPER

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO
  
  // The first call is hoisted.
  VPSHUFB     SHUF_2, KEY2, T0
  VAESENCLAST     RC,   T0, T0
  VPSLLD          $1,   RC, RC
  
  VPXOR    0(NC), KEY1, X0
  linearmix KEY1,   T0
/*
  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KEY), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
  VPADDD   __twotwo(%rip), Y1, Y3
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPSHUFB __ctrswap(%rip), Y3, Y3
  VPXOR Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  VPXOR Y3, Y7, Y3*/
  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KS), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
  VPADDD   __twotwo(%rip), Y1, Y3
  VPADDD   __twotwo(%rip), Y3, Y5
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPSHUFB __ctrswap(%rip), Y3, Y3
  VPSHUFB __ctrswap(%rip), Y5, Y5
  VPXOR Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  VPXOR Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  VPXOR Y5, Y7, Y5
  VEXTRACTI128 $1, Y5, X6

  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $7, %r9d
  BSWAP   %r9d
  XOR     %r11d, %r9d
  VPINSRD $3, %r9d, X0, X7

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  VPSHUFD      $0xff, KEY1, T0
  VAESENCLAST   ZERO,   T0, T0


  VAESENC   KEY2, X0, X0
  VAESENC   KEY2, X1, X1
  VAESENC   KEY2, X2, X2
  VAESENC   KEY2, X3, X3

  linearmix KEY2,   T0
  VAESENC  KEY1, X0, X0
  VAESENC  KEY1, X1, X1
  VAESENC  KEY1, X2, X2
  VAESENC  KEY1, X3, X3

  MOV $5, I
  .align 4
  L_ctr4:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix KEY1,   T0
    VAESENC   KEY2, X0, X0
    VAESENC   KEY2, X1, X1
    VAESENC   KEY2, X2, X2
    VAESENC   KEY2, X3, X3

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2,   T0
    VAESENC  KEY1, X0, X0
    VAESENC  KEY1, X1, X1
    VAESENC  KEY1, X2, X2
    VAESENC  KEY1, X3, X3
  DEC I
  JNZ L_ctr4

  VPSHUFB     SHUF_2, KEY2, T0
  VAESENCLAST     RC,   T0, T0
  VPSLLD          $1,   RC, RC

  linearmix KEY1,   T0
  VAESENC   KEY2, X0, X0
  VAESENC   KEY2, X1, X1
  VAESENC   KEY2, X2, X2
  VAESENC   KEY2, X3, X3

  // Round 14
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3

  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X1, 1*16(OUT)
  VPXOR 2*16(IN), X2, X2
  VMOVDQU X2, 2*16(OUT)
  CMPQ $64, LEN
  VMOVDQU X3, X0
  MOVQ $48, %rcx
  JNE L_last
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X3, 3*16(OUT)  

.align 4
L_done:
  // Zeroize registers.
  VZEROALL
  XOR KS, KS
  XOR KEY, KEY
  XOR %rax, %rax
  XOR %rcx, %rcx
  XOR LEN, LEN
  XOR NC, NC
  RET

L_last:
  SUBQ %rcx, LEN
  CMPQ $16, LEN
  VMOVDQU X3, X0
  JL L_mopup
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X3, 3*16(OUT)

L_mopup:
  VMOVQ X0, %rax
  CMPQ $8, LEN
  JL L_mopup_loop
  VPSHUFD $0xe, X0, X0    # X0[0:4] = {X0[2], X0[3], ... }

  XORQ (IN, %rcx), %rax
  MOVQ %rax, (OUT, %rcx)
  ADDQ $8, %rcx
  SUBQ $8, LEN
  JZ L_done

  VMOVQ X0, %rax

L_mopup_loop:
  XORB (IN, %rcx), %al
  MOVB %al, (OUT, %rcx)
  RORX $8, %rax, %rax
  INC %rcx
  DEC LEN
  JNZ L_mopup_loop

  JMP L_done
  

.globl _aes256_ctr8
_aes256_ctr8:
  VZEROUPPER

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU      KEY1,  0(KS)
  VMOVDQU      KEY2, 16(KS)
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0

  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KS), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
  VPADDD   __twotwo(%rip), Y1, Y3
  VPADDD   __twotwo(%rip), Y3, Y5
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPSHUFB __ctrswap(%rip), Y3, Y3
  VPSHUFB __ctrswap(%rip), Y5, Y5
  VPXOR Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  VPXOR Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  VPXOR Y5, Y7, Y5
  VEXTRACTI128 $1, Y5, X6

  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $7, %r9d
  BSWAP   %r9d
  XOR     %r11d, %r9d
  VPINSRD $3, %r9d, X0, X7

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, I
  .align 4
  L_ctr8:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix KEY1,   T0
    VAESENC   KEY2, X0, X0
    VAESENC   KEY2, X1, X1
    VAESENC   KEY2, X2, X2
    VAESENC   KEY2, X3, X3
    VAESENC   KEY2, X4, X4
    VAESENC   KEY2, X5, X5
    VAESENC   KEY2, X6, X6
    VAESENC   KEY2, X7, X7

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2,   T0
    VAESENC  KEY1, X0, X0
    VAESENC  KEY1, X1, X1
    VAESENC  KEY1, X2, X2
    VAESENC  KEY1, X3, X3
    VAESENC  KEY1, X4, X4
    VAESENC  KEY1, X5, X5
    VAESENC  KEY1, X6, X6
    VAESENC  KEY1, X7, X7
  
  ADDQ $32, KS
  DEC I
  JNZ L_ctr8

  VPSHUFB     SHUF_2, KEY2, T0
  VAESENCLAST     RC,   T0, T0
  VPSLLD          $1,   RC, RC

  linearmix KEY1,   T0
  VAESENC   KEY2, X0, X0
  VAESENC   KEY2, X1, X1
  VAESENC   KEY2, X2, X2
  VAESENC   KEY2, X3, X3
  VAESENC   KEY2, X4, X4
  VAESENC   KEY2, X5, X5
  VAESENC   KEY2, X6, X6
  VAESENC   KEY2, X7, X7

  // Round 14
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3
  VAESENCLAST      KEY1, X4, X4
  VAESENCLAST      KEY1, X5, X5
  VAESENCLAST      KEY1, X6, X6
  VAESENCLAST      KEY1, X7, X7

  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VPXOR 4*16(IN), X4, X4
  VPXOR 5*16(IN), X5, X5
  VPXOR 6*16(IN), X6, X6
  VPXOR 7*16(IN), X7, X7
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)
  VMOVDQU X4, 4*16(OUT)
  VMOVDQU X5, 5*16(OUT)
  VMOVDQU X6, 6*16(OUT)
  VMOVDQU X7, 7*16(OUT)
  JMP L_done



/** With key expansion:
.align 5
.globl _aes256_ctr4
_aes256_ctr4:
  VZEROUPPER

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU      KEY1,  0(KS)
  VMOVDQU      KEY2, 16(KS)
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0

  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KS), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
  VPADDD   __twotwo(%rip), Y1, Y3
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPSHUFB __ctrswap(%rip), Y3, Y3
  VPXOR Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  VPXOR Y3, Y7, Y3


  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  //VPXOR X5, KEY1, X5
  //VMOVDQU X5, 5*16(OUT)
  //ret

  MOV $6, I
  .align 4
  L_ctr4:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix KEY1,   T0
    VMOVDQU   KEY1, 16*2(KS)
    VAESENC   KEY2, X0, X0
    VAESENC   KEY2, X1, X1
    VAESENC   KEY2, X2, X2
    VAESENC   KEY2, X3, X3

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2,   T0
    VMOVDQU  KEY2, 16*3(KS)
    VAESENC  KEY1, X0, X0
    VAESENC  KEY1, X1, X1
    VAESENC  KEY1, X2, X2
    VAESENC  KEY1, X3, X3

  
  ADDQ $32, KS
  DEC I
  JNZ L_ctr4

    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix KEY1,   T0
    VMOVDQU   KEY1, 16*2(KS)
    VAESENC   KEY2, X0, X0
    VAESENC   KEY2, X1, X1
    VAESENC   KEY2, X2, X2
    VAESENC   KEY2, X3, X3


  // Round 14
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3


  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3

  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)

  // Zeroize registers.
  VZEROALL
  XOR KS, KS
  XOR KEY, KEY
  RET
*/
