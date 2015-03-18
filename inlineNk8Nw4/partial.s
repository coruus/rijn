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

#define OUT %rdi
#define IN  %rsi
#define KEY %rdx
#define LEN %rcx
#define KS  %r8
#define NC  %rsi

#define ROUND %rax

#define RQ %rax
#define RD %eax
#define RW %ax
#define RB %al

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
#define _RC __rc(%rip)
#define  SHUF_2 __shuf_2(%rip)
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
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
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


.macro linearmix key, new
  VPSLLDQ $4, \key, T1
  VPXOR   T1, \key, \key
  VPSLLDQ $4,   T1, T1
  VPXOR   T1, \key, \key
  VPSLLDQ $4,   T1, T1
  VPXOR   T1, \key, \key
  VPXOR   T0, \key, \key
.endm

// void aes256_ctr1_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr1_ks
_aes256_ctr1_ks:
  VZEROUPPER
L_aes256_ctr1_ks:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU      KEY1,  0(KS)
  VMOVDQU      KEY2, 16(KS)
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0


  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr1_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr1_ks

  // Round 14
  VAESENCLAST      KEY2, X0, X0

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)

  VPXOR   0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr2_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr2_ks
_aes256_ctr2_ks:
  VZEROUPPER
L_aes256_ctr2_ks:

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
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $1, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X1

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr2_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr2_ks

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)

  VPXOR   1*16(IN), X1, X1
  VMOVDQU X1, 1*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr3_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr3_ks
_aes256_ctr3_ks:
  VZEROUPPER
L_aes256_ctr3_ks:

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
  VPSHUFB __ctrswap(%rip), Y1, Y1
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr3_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr3_ks

  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)

  VPXOR   2*16(IN), X2, X2
  VMOVDQU X2, 2*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr4_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr4_ks
_aes256_ctr4_ks:
  VZEROUPPER
L_aes256_ctr4_ks:

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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $3, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X3

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr4_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr4_ks

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)

  VPXOR   3*16(IN), X3, X3
  VMOVDQU X3, 3*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr5_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr5_ks
_aes256_ctr5_ks:
  VZEROUPPER
L_aes256_ctr5_ks:

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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr5_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr5_ks

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VPXOR 4*16(IN), X4, X4
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)
  VMOVDQU X4, 4*16(OUT)

  VPXOR   4*16(IN), X4, X4
  VMOVDQU X4, 4*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr6_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr6_ks
_aes256_ctr6_ks:
  VZEROUPPER
L_aes256_ctr6_ks:

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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $5, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X5

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr6_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4
    VAESENC    KEY2, X5, X5

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
    VAESENC   KEY1, X5, X5
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr6_ks

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4
  VAESENCLAST      KEY2, X5, X5

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VPXOR 4*16(IN), X4, X4
  VPXOR 5*16(IN), X5, X5
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)
  VMOVDQU X4, 4*16(OUT)
  VMOVDQU X5, 5*16(OUT)

  VPXOR   5*16(IN), X5, X5
  VMOVDQU X5, 5*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr7_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr7_ks
_aes256_ctr7_ks:
  VZEROUPPER
L_aes256_ctr7_ks:

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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  
  VPXOR        Y5, Y7, Y5
  VEXTRACTI128 $1, Y5, X6

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr7_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4
    VAESENC    KEY2, X5, X5
    VAESENC    KEY2, X6, X6

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
    VAESENC   KEY1, X5, X5
    VAESENC   KEY1, X6, X6
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr7_ks

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4
  VAESENCLAST      KEY2, X5, X5
  VAESENCLAST      KEY2, X6, X6

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VPXOR 4*16(IN), X4, X4
  VPXOR 5*16(IN), X5, X5
  VPXOR 6*16(IN), X6, X6
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)
  VMOVDQU X4, 4*16(OUT)
  VMOVDQU X5, 5*16(OUT)
  VMOVDQU X6, 6*16(OUT)

  VPXOR   6*16(IN), X6, X6
  VMOVDQU X6, 6*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr8_ks(void* out, const void* in, const void* key, void* ks)
.align 5
.globl _aes256_ctr8_ks
_aes256_ctr8_ks:
  VZEROUPPER
L_aes256_ctr8_ks:

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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  
  VPXOR        Y5, Y7, Y5
  VEXTRACTI128 $1, Y5, X6
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $7, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X7

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr8_ks:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VMOVDQU    KEY1,  16*2(KS)
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4
    VAESENC    KEY2, X5, X5
    VAESENC    KEY2, X6, X6
    VAESENC    KEY2, X7, X7

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VMOVDQU   KEY2, 16*3(KS)
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
    VAESENC   KEY1, X5, X5
    VAESENC   KEY1, X6, X6
    VAESENC   KEY1, X7, X7
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr8_ks

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4
  VAESENCLAST      KEY2, X5, X5
  VAESENCLAST      KEY2, X6, X6
  VAESENCLAST      KEY2, X7, X7

  VPXOR 0*16(IN), X0, X0
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

  VPXOR   7*16(IN), X7, X7
  VMOVDQU X7, 7*16(OUT)

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr1(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr1
_aes256_ctr1:
  VZEROUPPER
L_aes256_ctr1:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0


  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr1:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr1

  // Round 14
  VAESENCLAST      KEY2, X0, X0

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VMOVDQU X0, 0*16(OUT)

  VMOVDQA X0, X0
  SUBQ $0*16, LEN
//  JS L_err
  ADDQ $0*16, (IN)
  ADDQ $0*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr2(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr2
_aes256_ctr2:
  VZEROUPPER
L_aes256_ctr2:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0

  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KS), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $1, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X1

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr2:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr2

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)

  VMOVDQA X1, X0
  SUBQ $1*16, LEN
//  JS L_err
  ADDQ $1*16, (IN)
  ADDQ $1*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr3(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr3
_aes256_ctr3:
  VZEROUPPER
L_aes256_ctr3:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0

  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KS), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
  VPSHUFB __ctrswap(%rip), Y1, Y1
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr3:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr3

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)

  VMOVDQA X2, X0
  SUBQ $2*16, LEN
//  JS L_err
  ADDQ $2*16, (IN)
  ADDQ $2*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr4(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr4
_aes256_ctr4:
  VZEROUPPER
L_aes256_ctr4:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0

  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KS), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
  VPADDD   __twotwo(%rip), Y1, Y3
  VPSHUFB __ctrswap(%rip), Y1, Y1
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $3, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X3

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr4:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr4

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)

  VMOVDQA X3, X0
  SUBQ $3*16, LEN
//  JS L_err
  ADDQ $3*16, (IN)
  ADDQ $3*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr5(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr5
_aes256_ctr5:
  VZEROUPPER
L_aes256_ctr5:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr5:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr5

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VPXOR 4*16(IN), X4, X4
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)
  VMOVDQU X4, 4*16(OUT)

  VMOVDQA X4, X0
  SUBQ $4*16, LEN
//  JS L_err
  ADDQ $4*16, (IN)
  ADDQ $4*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr6(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr6
_aes256_ctr6:
  VZEROUPPER
L_aes256_ctr6:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $5, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X5

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr6:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4
    VAESENC    KEY2, X5, X5

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
    VAESENC   KEY1, X5, X5
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr6

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4
  VAESENCLAST      KEY2, X5, X5

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VPXOR 4*16(IN), X4, X4
  VPXOR 5*16(IN), X5, X5
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)
  VMOVDQU X4, 4*16(OUT)
  VMOVDQU X5, 5*16(OUT)

  VMOVDQA X5, X0
  SUBQ $5*16, LEN
//  JS L_err
  ADDQ $5*16, (IN)
  ADDQ $5*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr7(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr7
_aes256_ctr7:
  VZEROUPPER
L_aes256_ctr7:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  
  VPXOR        Y5, Y7, Y5
  VEXTRACTI128 $1, Y5, X6

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr7:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4
    VAESENC    KEY2, X5, X5
    VAESENC    KEY2, X6, X6

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
    VAESENC   KEY1, X5, X5
    VAESENC   KEY1, X6, X6
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr7

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4
  VAESENCLAST      KEY2, X5, X5
  VAESENCLAST      KEY2, X6, X6

  VPXOR 0*16(IN), X0, X0
  VPXOR 0*16(IN), X0, X0
  VPXOR 1*16(IN), X1, X1
  VPXOR 2*16(IN), X2, X2
  VPXOR 3*16(IN), X3, X3
  VPXOR 4*16(IN), X4, X4
  VPXOR 5*16(IN), X5, X5
  VPXOR 6*16(IN), X6, X6
  VMOVDQU X0, 0*16(OUT)
  VMOVDQU X1, 1*16(OUT)
  VMOVDQU X2, 2*16(OUT)
  VMOVDQU X3, 3*16(OUT)
  VMOVDQU X4, 4*16(OUT)
  VMOVDQU X5, 5*16(OUT)
  VMOVDQU X6, 6*16(OUT)

  VMOVDQA X6, X0
  SUBQ $6*16, LEN
//  JS L_err
  ADDQ $6*16, (IN)
  ADDQ $6*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

// void aes256_ctr8(void* out, const void* in, const void* key)
.align 5
.globl _aes256_ctr8
_aes256_ctr8:
  VZEROUPPER
L_aes256_ctr8:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
  
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
  
  VPXOR        Y1, Y7, Y1
  VEXTRACTI128 $1, Y1, X2
  
  VPXOR        Y3, Y7, Y3
  VEXTRACTI128 $1, Y3, X4
  
  VPXOR        Y5, Y7, Y5
  VEXTRACTI128 $1, Y5, X6
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $7, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X7

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr8:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
    VAESENC    KEY2, X0, X0
    VAESENC    KEY2, X1, X1
    VAESENC    KEY2, X2, X2
    VAESENC    KEY2, X3, X3
    VAESENC    KEY2, X4, X4
    VAESENC    KEY2, X5, X5
    VAESENC    KEY2, X6, X6
    VAESENC    KEY2, X7, X7

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
    VAESENC   KEY1, X0, X0
    VAESENC   KEY1, X1, X1
    VAESENC   KEY1, X2, X2
    VAESENC   KEY1, X3, X3
    VAESENC   KEY1, X4, X4
    VAESENC   KEY1, X5, X5
    VAESENC   KEY1, X6, X6
    VAESENC   KEY1, X7, X7
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr8

  // Round 14
  VAESENCLAST      KEY2, X0, X0
  VAESENCLAST      KEY2, X1, X1
  VAESENCLAST      KEY2, X2, X2
  VAESENCLAST      KEY2, X3, X3
  VAESENCLAST      KEY2, X4, X4
  VAESENCLAST      KEY2, X5, X5
  VAESENCLAST      KEY2, X6, X6
  VAESENCLAST      KEY2, X7, X7

  VPXOR 0*16(IN), X0, X0
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

  VMOVDQA X7, X0
  SUBQ $7*16, LEN
//  JS L_err
  ADDQ $7*16, (IN)
  ADDQ $7*16, (OUT)
  JMP L_mopup

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET


L_mopup:
  CMP $16, LEN
    VPXOR   (IN), X0, X0
    VMOVDQU X0, (OUT)
    JMP Lmopup_done

  // 8 <= LEN <= 15:
  CMP $8, LEN
  JL Lmopup_lt8
  Lmopup_lte15:
    VPEXTRQ  $0, X0, RQ
    VPSRLDQ $64, X0, X0
    XORQ    (IN), RQ
    MOVQ    RQ, (OUT)
    ADDQ    $8, IN
    ADDQ    $8, OUT
    SUBQ    $8, LEN
  JZ      Lmopup_done

  Lmopup_lt8:
    // 0 <= LEN < 8:
    VPEXTRQ   $0, X0, RQ
  
    // 4 <= LEN < 8:
    CMP $4, LEN
    JL  Lmopup_lt4
      XOR (IN), RD
      MOV RD, (OUT)
      SHRQ $32, RQ
      ADDQ $4, IN
      ADDQ $4, OUT
      SUBQ $4, LEN
    JZ      Lmopup_done

    // 2 <= LEN < 4:
    Lmopup_lt4:
    CMP $2, LEN
    JL  Lmopup_lt2
      XORW (IN), RW
      MOVW RW, (OUT)
      SHRW $16, RW
      ADDQ $2, IN
      ADDQ $2, OUT
      SUBQ $2, LEN
    JZ Lmopup_done

    Lmopup_lt2:
      // LEN == 1
      XORB (IN), RB
      MOVB RB, (OUT)

Lmopup_done:
  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ  RQ,  RQ
  XORQ LEN, LEN
  RET
