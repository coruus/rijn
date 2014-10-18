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
#define X15 %xmm15
#define Y0 %ymm6
#define Y1 %ymm7
#define Y2 %ymm8
#define Y3 %ymm9
#define Y4 %ymm10
#define Y5 %ymm11
#define Y6 %ymm12
#define Y7 %ymm13
#define Y8 %ymm14
#define Y15 %ymm15

#define IN   %rsi
#define OUT  %rdi
#define LEN  %rdx
#define KEY  %rcx
#define NC   %r8
#define I    %rax
#define KS %rcx
#define OFFSET %rbx

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

.align 5
__ctrswap:
  .byte  0,  1,  2,  3
  .byte  4,  5,  6,  7
  .byte  8,  9, 10, 11
  .byte 15, 14, 13, 12
  .byte  0,  1,  2,  3
  .byte  4,  5,  6,  7
  .byte  8,  9, 10, 11
  .byte 15, 14, 13, 12
#define _CTRSWAP __ctrswap(%rip)

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
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 2, 0, 0, 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 2, 0, 0, 0
__eight:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 8, 0, 0, 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 8, 0, 0, 0
#define _EIGHT __eight(%rip)
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

.macro xorlast xx, block, cc, ll
  VMOVDQU \xx, X0
  MOVQ $\cc, %rcx
  CMPQ $\ll, LEN
  JL last
  VPXOR \block*16(IN), X7, X7
  VMOVDQU \xx, \block*16(OUT)
  done
.endm

.macro expand1
  VPSHUFB     SHUF_2, KEY2, T0
  VAESENCLAST     RC,   T0, T0
  VPSLLD          $$1,   RC, RC
  linearmix KEY1,   T0
.endm 

.macro expand2
  VPSHUFD      $$0xff, KEY1, T0
  VAESENCLAST   ZERO,   T0, T0
  linearmix KEY2,   T0
.endm

.macro done
  VZEROALL
  XOR KS, KS
  XOR KEY, KEY
  XOR %rax, %rax
  XOR %rcx, %rcx
  XOR LEN, LEN
  XOR NC, NC
  RET
.endm

.macro enc8 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
    VAESENC   \key, X5, X5
    VAESENC   \key, X6, X6
    VAESENC   \key, X7, X7
.endm

.macro enc7 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
    VAESENC   \key, X5, X5
    VAESENC   \key, X6, X6
.endm

.macro enc6 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
    VAESENC   \key, X5, X5
.endm

.macro enc5 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
.endm

.macro enc4 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
.endm

.macro enc3 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
.endm

.macro enc2 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
.endm

.macro last8 key
  VAESENCLAST      \key, X0, X0
  VAESENCLAST      \key, X1, X1
  VAESENCLAST      \key, X2, X2
  VAESENCLAST      \key, X3, X3
  VAESENCLAST      \key, X4, X4
  VAESENCLAST      \key, X5, X5
  VAESENCLAST      \key, X6, X6
  VAESENCLAST      \key, X7, X7
.endm


.text

/* By 8 blocks, performance is linear.
 */
.align 5

.align 5
.globl _aes256_ctr4
_aes256_ctr4:
  CMPQ $0, LEN
  JZ ret
  VZEROUPPER
//  CMPQ $128, LEN
  //JG expand_key_prelude


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

  CMPQ $16, LEN
  JLE fly1
  CMPQ $32, LEN
  JLE fly2
  CMPQ $48, LEN
  JLE fly3
  CMPQ $64, LEN
  JLE fly4
  CMPQ $80, LEN
  JLE fly5
  CMPQ $96, LEN
  JLE fly6
  CMPQ $112, LEN
  JLE fly7
  CMPQ $128, LEN
  JLE fly8

fly4:
  enc4 KEY2
  linearmix KEY2,   T0
  enc4 KEY1

  MOV $5, I
  .align 4
  ctr4:
    expand1
    enc4 KEY2
    expand2
    enc4 KEY1
  DEC I
  JNZ ctr4

  expand1
  enc4 KEY2
  
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

  xorlast X3, 3, 48, 64

.align 4
done:
  // Zeroize registers.
  VZEROALL
  XOR KS, KS
  XOR KEY, KEY
  XOR %rax, %rax
  XOR %rcx, %rcx
  XOR LEN, LEN
  XOR NC, NC
ret:
  RET

last:
  SUBQ %rcx, LEN
  CMPQ $16, LEN
  JL mopup
  VPXOR (IN, %rcx), X0, X0
  VMOVDQU X0, (OUT, %rcx)

mopup:
  VMOVQ X0, %rax
  CMPQ $8, LEN
  JL mopup_loop
  VPSHUFD $0xe, X0, X0    # X0[0:4] = {X0[2], X0[3], ... }

  XORQ (IN, %rcx), %rax
  MOVQ %rax, (OUT, %rcx)
  ADDQ $8, %rcx
  SUBQ $8, LEN
  JZ done

  VMOVQ X0, %rax

mopup_loop:
  XORB (IN, %rcx), %al
  MOVB %al, (OUT, %rcx)
  RORX $8, %rax, %rax
  INC %rcx
  DEC LEN
  JNZ mopup_loop

  done
  
fly8:
  enc8 KEY2
  linearmix KEY2,   T0
  enc8 KEY1

  MOV $5, I
  .align 4
  ctr8:
    expand1
    enc8 KEY2 
    expand2
    enc8 KEY1

  DEC I
  JNZ ctr8

  expand1
  enc8 KEY2 
  
  last8 KEY1

  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X1, 1*16(OUT)
  VPXOR 2*16(IN), X2, X2
  VMOVDQU X2, 2*16(OUT)
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X3, 3*16(OUT)
  VPXOR 4*16(IN), X4, X4
  VMOVDQU X4, 4*16(OUT)
  VPXOR 5*16(IN), X5, X5
  VMOVDQU X5, 5*16(OUT)
  VPXOR 6*16(IN), X6, X6
  VMOVDQU X6, 6*16(OUT)

  xorlast X7, 7, 112, 128

fly5:
  enc5 KEY2
  
  linearmix KEY2,   T0
  enc5 KEY1
  
  MOV $5, I
  .align 4
  ctr5:
    expand1
    enc5 KEY2 
    expand2
    enc5 KEY1
  
  DEC I
  JNZ ctr5

  expand1
  enc5 KEY2
  
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3
  VAESENCLAST      KEY1, X4, X4

  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X1, 1*16(OUT)
  VPXOR 2*16(IN), X2, X2
  VMOVDQU X2, 2*16(OUT)
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X3, 3*16(OUT)

  xorlast X4, 4, 64, 80

fly6:
  enc6 KEY2
  
  linearmix KEY2,   T0
  enc6 KEY1

  MOV $5, I
  .align 4
  ctr6:
    expand1
    enc6 KEY2
    expand2
    enc6 KEY1  
  DEC I
  JNZ ctr6

  expand1
  enc6 KEY2
  
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3
  VAESENCLAST      KEY1, X4, X4
  VAESENCLAST      KEY1, X5, X5

  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X1, 1*16(OUT)
  VPXOR 2*16(IN), X2, X2
  VMOVDQU X2, 2*16(OUT)
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X3, 3*16(OUT)
  VPXOR 4*16(IN), X4, X4
  VMOVDQU X4, 4*16(OUT)

  xorlast X5, 5, 80, 96

fly7:
  enc7 KEY2
  
  linearmix KEY2,   T0
  enc7 KEY1
  MOV $5, I
  .align 4
  ctr7:
    expand1
    enc7 KEY2
    expand2
    enc7 KEY1  
  DEC I
  JNZ ctr7

  expand1
  enc7 KEY2

  
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3
  VAESENCLAST      KEY1, X4, X4
  VAESENCLAST      KEY1, X5, X5
  VAESENCLAST      KEY1, X6, X6

  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X1, 1*16(OUT)
  VPXOR 2*16(IN), X2, X2
  VMOVDQU X2, 2*16(OUT)
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X3, 3*16(OUT)
  VPXOR 4*16(IN), X4, X4
  VMOVDQU X4, 4*16(OUT)
  VPXOR 5*16(IN), X5, X5
  VMOVDQU X5, 5*16(OUT)

  xorlast X6, 6, 96, 112

fly3:
  enc3      KEY2
  linearmix KEY2,   T0
  enc3      KEY1

  MOV $5, I
  .align 4
  ctr3:
    expand1
    enc3 KEY2
    expand2
    enc3 KEY1
  DEC I
  JNZ ctr3

  expand1
  enc3      KEY2
  
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2

  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X1, 1*16(OUT)

  xorlast X2, 2, 32, 48


fly2:
  enc2      KEY2
  linearmix KEY2,   T0
  enc2      KEY1

  MOV $5, I
  .align 4
  ctr2:
    expand1
    enc2     KEY2
    expand2
    enc2     KEY1
  DEC I
  JNZ ctr2

  expand1
  enc2  KEY2

  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1

  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)

  xorlast X1, 1, 16, 32


fly1:
  VAESENC   KEY2, X0, X0
  linearmix KEY2,   T0
  VAESENC  KEY1, X0, X0

  MOV $5, I
  .align 4
  ctr1:
    expand1
    VAESENC   KEY2, X0, X0
    expand2
    VAESENC  KEY1, X0, X0
  DEC I
  JNZ ctr1

  expand1
  VAESENC      KEY2, X0, X0
  VAESENCLAST  KEY1, X0, X0

  xorlast X0, 0, 0, 16
