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

/*% for name, save_schedule in [('_ks', True), ('', False)] */
/*% for N in range(1, 9) */
/*% if not save_schedule */
// void aes256_ctr`N`(void* out, const void* in, const void* key)
/*% else */
// void aes256_ctr`N`_ks(void* out, const void* in, const void* key, void* ks)
/*% endif */
.align 5
.globl _aes256_ctr`N``name`
_aes256_ctr`N``name`:
  VZEROUPPER
L_aes256_ctr`N``name`:

  VMOVDQU    0(KEY), KEY1
  VMOVDQU   16(KEY), KEY2
/*% if save_schedule */  
  VMOVDQU      KEY1,  0(KS)
  VMOVDQU      KEY2, 16(KS)
/*% endif */  
  VMOVDQU       _RC, RC

  VPXOR ZERO, ZERO, ZERO

  VPXOR    0(NC), KEY1, X0

/*% if N > 1 */
  VBROADCASTI128 0(NC), Y1
  VBROADCASTI128 0(KS), Y7
  VPSHUFB __ctrswap(%rip), Y1, Y1
  VPADDD   __onetwo(%rip), Y1, Y1
/*% endif */
/*% if N > 3 */
  VPADDD   __twotwo(%rip), Y1, Y3
/*% endif */
/*% if N > 5 */
  VPADDD   __twotwo(%rip), Y3, Y5
/*% endif */
/*% for i in range(1, N-1, 2) */
  VPSHUFB __ctrswap(%rip), Y`i`, Y`i`
/*% endfor */
/*% for i in range(1, N-1, 2) */  
  VPXOR        Y`i`, Y7, Y`i`
  VEXTRACTI128 $1, Y`i`, X`i+1`
/*% endfor */
/*% if (N % 2) == 0 */
  MOV   12(KEY), %r11d
  MOVBE 12(NC ), %r9d
  ADD        $`N-1`, %r9d
  BSWAP        %r9d
  XOR         %r11d, %r9d
  VPINSRD $3,  %r9d,   X0, X`N-1`
/*% endif */

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  MOV $6, ROUND
  .align 4
  Lctr`N``name`:
    VPSHUFB     SHUF_2, KEY2, T0
    VAESENCLAST     RC,   T0, T0
    VPSLLD          $1,   RC, RC

    linearmix  KEY1,  T0
/*% if save_schedule */
    VMOVDQU    KEY1,  16*2(KS)
/*% endif */
/*% for i in range(N) */
    VAESENC    KEY2, X`i`, X`i`
/*% endfor */

    VPSHUFD      $0xff, KEY1, T0
    VAESENCLAST   ZERO,   T0, T0

    linearmix KEY2, T0
/*% if save_schedule */
    VMOVDQU   KEY2, 16*3(KS)
/*% endif */
/*% for i in range(N) */
    VAESENC   KEY1, X`i`, X`i`
/*% endfor */
  
  ADDQ $32, KS
  DEC ROUND
  JNZ Lctr`N``name`

  // Round 14
/*% for i in range(N) */
  VAESENCLAST      KEY2, X`i`, X`i`
/*% endfor */

  VPXOR 0*16(IN), X0, X0
/*% for i in range(N) */
  VPXOR `i`*16(IN), X`i`, X`i`
/*% endfor */
/*% for i in range(N) */
  VMOVDQU X`i`, `i`*16(OUT)
/*% endfor */

/*% if save_schedule */
  VPXOR   `N-1`*16(IN), X`N-1`, X`N-1`
  VMOVDQU X`N-1`, `N-1`*16(OUT)
/*% else */
  VMOVDQA X`N-1`, X0
  SUBQ $`(N-1)`*16, LEN
//  JS L_err
  ADDQ $`(N-1)`*16, (IN)
  ADDQ $`(N-1)`*16, (OUT)
  JMP L_mopup
/*% endif */

  // Zeroize registers.
  VZEROALL
  XORQ  KS,  KS
  XORQ KEY, KEY
  XORQ  IN,  IN
  XORQ OUT, OUT
  XORQ LEN, LEN
  RET

/*% endfor */
/*% endfor */

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
