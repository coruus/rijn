.align 5
__01:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 1
__23:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 2
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 3
__45:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 4
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 5
__67:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 6
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 7






expand_key_prelude:
  //XORQ (LEN), %rdx
  # We need stack space.
  PUSH %rbx
  PUSH %rbp
  MOVQ %rsp, %rbp
  //ANDQ $-32, %rsp  # align
  SUBQ $368, %rsp  # alloca
  


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

  VBROADCASTI128 0(NC), Y0
  VBROADCASTI128 0(KEY), Y15
  VPSHUFB __ctrswap(%rip), Y0, Y0
  VPADDD   __23(%rip), Y0, Y2
  VPADDD   __45(%rip), Y0, Y4
  VPADDD   __67(%rip), Y0, Y6
  VPADDD   __01(%rip), Y0, Y0
  VMOVDQU Y0, 0*32(%rsp)
  VMOVDQU Y2, 1*32(%rsp)
  VMOVDQU Y4, 2*32(%rsp)
  VMOVDQU Y6, 3*32(%rsp)
  VPSHUFB __ctrswap(%rip), Y0, Y0
  VPSHUFB __ctrswap(%rip), Y2, Y2
  VPSHUFB __ctrswap(%rip), Y4, Y4
  VPSHUFB __ctrswap(%rip), Y6, Y6

  VPXOR Y0, Y15, Y0
  VPXOR Y2, Y15, Y2
  VPXOR Y4, Y15, Y4
  VPXOR Y6, Y15, Y6
  VMOVDQU Y0, 0*32(OUT)
  VMOVDQU Y2, 1*32(OUT)
  VMOVDQU Y4, 2*32(OUT)
  VMOVDQU Y6, 3*32(OUT)
  JMP cleanup_stack
  VEXTRACTI128 $1, Y0, X1
  VEXTRACTI128 $1, Y2, X3
  VEXTRACTI128 $1, Y4, X5
  VEXTRACTI128 $1, Y6, X7

  PREFETCHt0 (IN)
  PREFETCHw  (OUT)

  VPSHUFD      $0xff, KEY1, T0
  VAESENCLAST   ZERO,   T0, T0

expand_key:
  MOVQ %rsp, KS
  ADDQ $128, KS
  LEAQ 128(%rsp), KS
  enc8 KEY2

  VMOVDQU  X15, 0*16(KEY)
  VMOVDQU KEY2, 1*16(KS)
  linearmix KEY2,   T0
  enc8 KEY1

  MOV $5, I
  .align 4
  ex:
    VMOVDQU KEY1, 2*16(KS)
    expand1
    enc8 KEY2
    
    VMOVDQU KEY2, 3*16(KS)
    expand2
    enc8 KEY1
  ADDQ $32, KS
  DEC I
  JNZ ex

  expand1
  VMOVDQU KEY1, 2*16(KS)
  VAESENC   KEY2, X0, X0
  VAESENC   KEY2, X1, X1
  VAESENC   KEY2, X2, X2
  VAESENC   KEY2, X3, X3
  VAESENC   KEY2, X4, X4
  VAESENC   KEY2, X5, X5
  VAESENC   KEY2, X6, X6
  VAESENC   KEY2, X7, X7

  // Round 14
  VMOVDQU KEY2, 3*16(KS)
  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3
  VAESENCLAST      KEY1, X4, X4
  VAESENCLAST      KEY1, X5, X5
  VAESENCLAST      KEY1, X6, X6
  VAESENCLAST      KEY1, X7, X7

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
  VPXOR 7*16(IN), X7, X7
  VMOVDQU X7, 7*16(OUT)

  JMP cleanup_stack
  # offset == 128
  MOVQ $128, OFFSET
  SUBQ $128, LEN    # will never be zero here
  JZ cleanup_stack
  CMPQ $128, LEN
  JGE continue8
# TODO: dispatch to doneX

cleanup_stack:
  //MOVQ %rsp, %rdi
  //MOVQ $368, %rcx
  //REP STOSB
  MOVQ %rbp, %rsp
  POP %rbp
  POP %rbx
  ret

continue8:
  LEAQ 128(%rsp), KS
  VMOVDQA   _EIGHT, Y7
  VPADDD    0*32(%rsp), Y7, Y0
  VPADDD    1*32(%rsp), Y7, Y2
  VPADDD    2*32(%rsp), Y7, Y4
  VPADDD    3*32(%rsp), Y7, Y6
  VPSHUFB   _CTRSWAP, Y0, Y0
  VPSHUFB   _CTRSWAP, Y2, Y2
  VPSHUFB   _CTRSWAP, Y4, Y4
  VPSHUFB   _CTRSWAP, Y6, Y6
  VMOVDQU Y0, 0*32(%rsp)
  VMOVDQU Y2, 1*32(%rsp)
  VMOVDQU Y4, 2*32(%rsp)
  VMOVDQU Y6, 3*32(%rsp)
  VPXOR     Y15, Y0, Y0
  VPXOR     Y15, Y2, Y2
  VPXOR     Y15, Y4, Y4
  VPXOR     Y15, Y6, Y6
  VEXTRACTI128 $1, Y0, X1
  VEXTRACTI128 $1, Y2, X3
  VEXTRACTI128 $1, Y4, X5
  VEXTRACTI128 $1, Y6, X7

  MOV $6, I
  .align 4
  steady8:
    VMOVDQU   2*16(KS), KEY1
    VAESENC   KEY2, X0, X0
    VAESENC   KEY2, X1, X1
    VAESENC   KEY2, X2, X2
    VAESENC   KEY2, X3, X3
    VAESENC   KEY2, X4, X4
    VAESENC   KEY2, X5, X5
    VAESENC   KEY2, X6, X6
    VAESENC   KEY2, X7, X7
    
    VMOVDQU  3*16(KS), KEY2
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
  JNZ steady8

  VMOVDQU   2*16(KS), KEY2
  VAESENC   KEY2, X0, X0
  VAESENC   KEY2, X1, X1
  VAESENC   KEY2, X2, X2
  VAESENC   KEY2, X3, X3
  VAESENC   KEY2, X4, X4
  VAESENC   KEY2, X5, X5
  VAESENC   KEY2, X6, X6
  VAESENC   KEY2, X7, X7

  VAESENCLAST      KEY1, X0, X0
  VAESENCLAST      KEY1, X1, X1
  VAESENCLAST      KEY1, X2, X2
  VAESENCLAST      KEY1, X3, X3
  VAESENCLAST      KEY1, X4, X4
  VAESENCLAST      KEY1, X5, X5
  VAESENCLAST      KEY1, X6, X6
  VAESENCLAST      KEY1, X7, X7

  VPXOR 0*16(IN, OFFSET), X0, X0
  VMOVDQU X0, 0*16(OUT, OFFSET)
  VPXOR 1*16(IN, OFFSET), X1, X1
  VMOVDQU X1, 1*16(OUT, OFFSET)
  VPXOR 2*16(IN, OFFSET), X2, X2
  VMOVDQU X2, 2*16(OUT, OFFSET)
  VPXOR 3*16(IN, OFFSET), X3, X3
  VMOVDQU X3, 3*16(OUT, OFFSET)
  VPXOR 4*16(IN, OFFSET), X4, X4
  VMOVDQU X4, 4*16(OUT, OFFSET)
  VPXOR 5*16(IN, OFFSET), X5, X5
  VMOVDQU X5, 5*16(OUT, OFFSET)
  VPXOR 6*16(IN, OFFSET), X6, X6
  VMOVDQU X6, 6*16(OUT, OFFSET)
  VPXOR 7*16(IN, OFFSET), X6, X6
  VMOVDQU X6, 7*16(OUT, OFFSET)
  SUBQ $128, LEN
  JZ cleanup_stack
  ADDQ $128, OFFSET
  CMPQ $128, LEN
  JGE continue8
//  CMPQ $96, LEN
//  JG finish7
//  CMPQ $80, LEN
//  JG finish6
//  CMPQ $64, LEN
//  JG finish5
//  CMPQ $48, LEN
//  JG finish4
//  CMPQ $32, LEN
//  JG finish3
//  CMPQ $16, LEN
//  JG finish2
  # 0 < LEN <= 16

