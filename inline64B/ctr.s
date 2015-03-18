#define dTMP %r11d
#define dCTR %r9d
#define dKW3 %eax

#define i0  %xmm10
#define i1  %xmm11
#define i2  %xmm12
#define i3  %xmm13
#define ONE %xmm14
#define IV  %xmm15

#define xk %xmm0
#define K2 %xmm1
#define x0 %xmm2
#define x1 %xmm3
#define x2 %xmm4
#define x3 %xmm5
#define x4 %xmm6
#define x5 %xmm7
#define x6 %xmm8
#define x7 %xmm9

#define OUT %r9   //%rdi
#define IN  %r10  //%rsi
#define NC  %r11  //%rcx
#define LEN %rdx
#define KS  %r8

#define STACKSIZE $128
#define buf(I)    I*16+1*128+256(%rsi)
#define ks(I)     I*16(KS)


.macro enc8 i, k
  vmovdqu ks(\i*16), \k
  vaesenc \k, X0, X0
  vaesenc \k, X1, X1
  vaesenc \k, X2, X2
  vaesenc \k, X3, X3
  vaesenc \k, X4, X4
  vaesenc \k, X5, X5
  vaesenc \k, X6, X6
  vaesenc \k, X7, X7
.endm

.macro enc7 i
  vmovdqu ks(\i*16), xk
  vaesenc xk, x0, x0
  vaesenc xk, x1, x1
  vaesenc xk, x2, x2
  vaesenc xk, x3, x3
  vaesenc xk, x4, x4
  vaesenc xk, x5, x5
  vaesenc xk, x6, x6
.endm

.macro addctr i
  add   $1, CTR
  mov   dCTR, dTMP
  bswap dTMP
  xor   dKW3, dTMP
  mov   dTMP, \i*16+12(%rsp)
.endm

.macro rmovb len, src, dst
  mov \len, %rcx
  mov \src, %rsi
  mov \dst, %rdi
  rep movs
.endm

.macro rstosb len, val, dst
  movq \len, %rcx
  movq \val, %rax
  movq \dst, %rdi
  rep stosb
.endm

.align 5

.globl _aes_ctr_ex
_aes_ctr_ex:
  test  $len, $len
  jz  .Lret

  push  %rbp
  movq %rsp, %rbp
  andq $-32, %rsp
  subq STACKSIZE, %rsp

  movq %rdi, OUT
  movq %rsi, IN
  movq %rcx, NC

  mov  3*4(IVP), CTR
  mov  3*4(KS), KW3

  sub  $128, (IN) 
  sub  $128, (OUT)

  vbroadcasti128     ks(0), %ymm0
  vbroadcasti128     (IVP), %ymm1
  vpxor %ymm1, %ymm0, %ymm0
  
  vmovdqa %ymm0, nc(0)
  vmovdqa %ymm0, nc(1)
  vmovdqa %ymm0, nc(2)
  vmovdqa %ymm0, nc(3)

  mov    CTR, TMP
  bswap  CTR  
  xor    K3, TMP
  mov    TMP, 0*16+12(%rsp)

  addctr 1
  addctr 2
  addctr 3
  addctr 4
  addctr 5
  addctr 6
  addctr 7

  .Loop_ctr:
    add  \$128, $inp
    add  \$128, $out
  
    vmovdqa  nc(0), x0
    vmovdqa  nc(1), x1
    vmovdqa  nc(2), x2
    vmovdqa  nc(3), x3
    vmovdqa  nc(4), x4
    vmovdqa  nc(5), x5
    vmovdqa  nc(6), x6
    vmovdqa  nc(7), x7
  
    aes8 1
    addctr 0
    aes8 2
    addctr 1
    aes8 3
    addctr 2
    aes8 4
    addctr 3
    aes8 5
    addctr 4
    aes8 6
    addctr 5
    aes8 7
    addctr 6
    aes8 8
    addctr 7
    aes8 9
    aes8 10
    aes8 11
    aes8 12
    aes8 13
  
    vmovdqu ks(14), K1
  
  .Lenclast:
    cmpq $128, LEN
    jl .Lnearlydone

    vpxor  in(0), K1, xk
    vaesenclast  xk, x0, x0
    vpxor  in(1), K1, xk
    vaesenclast  xk, x1, x1
    vpxor  in(2), K1, xk
    vaesenclast  xk, x2, x2
    vpxor  in(3), K1, xk
    vaesenclast  xk, x3, x3
    vpxor  in(4), K1, xk
    vaesenclast  xk, x4, x4
    vpxor  in(5), K1, xk
    vaesenclast  xk, x5, x5
    vpxor  in(6), K1, xk
    vaesenclast  xk, x6, x6
    vpxor  in(7), K1, xk
    vaesenclast  xk, x7, x7
    
    vmovdqa  x0, out(0)
    vmovdqa  x1, out(1)
    vmovdqa  x2, out(2)
    vmovdqa  x3, out(3)
    vmovdqa  x4, out(4)
    vmovdqa  x5, out(5)
    vmovdqa  x6, out(6)
    vmovdqa  x7, out(7)
  
    sub  $128, LEN
    jna .Loop_ctr

.Ldone:
  rstosb STACKSIZE, $0, %rsi
  xor dTMP, dTMP
  xor dCTR, dCTR
  xor dKW3, dKW3
  mov  %rbp, %rsp
  pop  %rbp
  vzeroall
.Lret:
  ret

.Lnearlydone:
    rmovb LEN, in(0), buf(0)
   
    vpxor  buf(0), K1, xk
    vaesenclast  xk, x0, x0
    vpxor  buf(1), K1, xk
    vaesenclast  xk, x1, x1
    vpxor  buf(2), K1, xk
    vaesenclast  xk, x2, x2
    vpxor  buf(3), K1, xk
    vaesenclast  xk, x3, x3
    vpxor  buf(4), K1, xk
    vaesenclast  xk, x4, x4
    vpxor  buf(5), K1, xk
    vaesenclast  xk, x5, x5
    vpxor  buf(6), K1, xk
    vaesenclast  xk, x6, x6
    vpxor  buf(7), K1, xk
    vaesenclast  xk, x7, x7
    
    vmovdqa  x0, buf(0)
    vmovdqa  x1, buf(1)
    vmovdqa  x2, buf(2)
    vmovdqa  x3, buf(3)
    vmovdqa  x4, buf(4)
    vmovdqa  x5, buf(5)
    vmovdqa  x6, buf(6)
    vmovdqa  x7, buf(7)
  
    rmovb LEN, buf(0), out(0)
    jmp .Ldone
