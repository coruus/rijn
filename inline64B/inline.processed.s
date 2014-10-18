# 1 "inline.s"
# 1 "<built-in>" 1
# 1 "inline.s" 2
# 48 "inline.s"
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
  .byte 0, 1, 2, 3
  .byte 4, 5, 6, 7
  .byte 8, 9, 10, 11
  .byte 15, 14, 13, 12
  .byte 0, 1, 2, 3
  .byte 4, 5, 6, 7
  .byte 8, 9, 10, 11
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
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 2, 0, 0, 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 2, 0, 0, 0
__eight:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 8, 0, 0, 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 8, 0, 0, 0




.macro linearmix key, new
  VPSLLDQ $4, \key, %xmm1
  VPXOR %xmm1, \key, \key
  VPSLLDQ $4, %xmm1, %xmm1
  VPXOR %xmm1, \key, \key
  VPSLLDQ $4, %xmm1, %xmm1
  VPXOR %xmm1, \key, \key
  VPXOR %xmm0, \key, \key
.endm

.macro xorlast xx, block, cc, ll
  VMOVDQU \xx, %xmm6
  MOVQ $\cc, %rcx
  CMPQ $\ll, %rdx
  JL last
  VPXOR \block*16(%rsi), %xmm13, %xmm13
  VMOVDQU \xx, \block*16(%rdi)
  done
.endm

.macro expand1
  VPSHUFB __shuf_2(%rip), %xmm3, %xmm0
  VAESENCLAST %xmm4, %xmm0, %xmm0
  VPSLLD $$1, %xmm4, %xmm4
  linearmix %xmm2, %xmm0
.endm

.macro expand2
  VPSHUFD $$0xff, %xmm2, %xmm0
  VAESENCLAST %xmm5, %xmm0, %xmm0
  linearmix %xmm3, %xmm0
.endm

.macro done
  VZEROALL
  XOR %rcx, %rcx
  XOR %rcx, %rcx
  XOR %rax, %rax
  XOR %rcx, %rcx
  XOR %rdx, %rdx
  XOR %r8, %r8
  RET
.endm

.macro enc8 key
    VAESENC \key, %xmm6, %xmm6
    VAESENC \key, %xmm7, %xmm7
    VAESENC \key, %xmm8, %xmm8
    VAESENC \key, %xmm9, %xmm9
    VAESENC \key, %xmm10, %xmm10
    VAESENC \key, %xmm11, %xmm11
    VAESENC \key, %xmm12, %xmm12
    VAESENC \key, %xmm13, %xmm13
.endm

.macro enc7 key
    VAESENC \key, %xmm6, %xmm6
    VAESENC \key, %xmm7, %xmm7
    VAESENC \key, %xmm8, %xmm8
    VAESENC \key, %xmm9, %xmm9
    VAESENC \key, %xmm10, %xmm10
    VAESENC \key, %xmm11, %xmm11
    VAESENC \key, %xmm12, %xmm12
.endm

.macro enc6 key
    VAESENC \key, %xmm6, %xmm6
    VAESENC \key, %xmm7, %xmm7
    VAESENC \key, %xmm8, %xmm8
    VAESENC \key, %xmm9, %xmm9
    VAESENC \key, %xmm10, %xmm10
    VAESENC \key, %xmm11, %xmm11
.endm

.macro enc5 key
    VAESENC \key, %xmm6, %xmm6
    VAESENC \key, %xmm7, %xmm7
    VAESENC \key, %xmm8, %xmm8
    VAESENC \key, %xmm9, %xmm9
    VAESENC \key, %xmm10, %xmm10
.endm

.macro enc4 key
    VAESENC \key, %xmm6, %xmm6
    VAESENC \key, %xmm7, %xmm7
    VAESENC \key, %xmm8, %xmm8
    VAESENC \key, %xmm9, %xmm9
.endm

.macro enc3 key
    VAESENC \key, %xmm6, %xmm6
    VAESENC \key, %xmm7, %xmm7
    VAESENC \key, %xmm8, %xmm8
.endm

.macro enc2 key
    VAESENC \key, %xmm6, %xmm6
    VAESENC \key, %xmm7, %xmm7
.endm

.macro last8 key
  VAESENCLAST \key, %xmm6, %xmm6
  VAESENCLAST \key, %xmm7, %xmm7
  VAESENCLAST \key, %xmm8, %xmm8
  VAESENCLAST \key, %xmm9, %xmm9
  VAESENCLAST \key, %xmm10, %xmm10
  VAESENCLAST \key, %xmm11, %xmm11
  VAESENCLAST \key, %xmm12, %xmm12
  VAESENCLAST \key, %xmm13, %xmm13
.endm


.text



.align 5

.align 5
.globl _aes256_ctr4
_aes256_ctr4:
  CMPQ $0, %rdx
  JZ ret
  VZEROUPPER




  VMOVDQU 0(%rcx), %xmm2
  VMOVDQU 16(%rcx), %xmm3

  VMOVDQU __rc(%rip), %xmm4

  VPXOR %xmm5, %xmm5, %xmm5


  VPSHUFB __shuf_2(%rip), %xmm3, %xmm0
  VAESENCLAST %xmm4, %xmm0, %xmm0
  VPSLLD $1, %xmm4, %xmm4

  VPXOR 0(%r8), %xmm2, %xmm6
  linearmix %xmm2, %xmm0

  VBROADCASTI128 0(%r8), %ymm7
  VBROADCASTI128 0(%rcx), %ymm13
  VPSHUFB __ctrswap(%rip), %ymm7, %ymm7
  VPADDD __onetwo(%rip), %ymm7, %ymm7
  VPADDD __twotwo(%rip), %ymm7, %ymm9
  VPADDD __twotwo(%rip), %ymm9, %ymm11
  VPSHUFB __ctrswap(%rip), %ymm7, %ymm7
  VPSHUFB __ctrswap(%rip), %ymm9, %ymm9
  VPSHUFB __ctrswap(%rip), %ymm11, %ymm11
  VPXOR %ymm7, %ymm13, %ymm7
  VEXTRACTI128 $1, %ymm7, %xmm8
  VPXOR %ymm9, %ymm13, %ymm9
  VEXTRACTI128 $1, %ymm9, %xmm10
  VPXOR %ymm11, %ymm13, %ymm11
  VEXTRACTI128 $1, %ymm11, %xmm12

  MOV 12(%rcx), %r11d
  MOVBE 12(%r8 ), %r9d
  ADD $7, %r9d
  BSWAP %r9d
  XOR %r11d, %r9d
  VPINSRD $3, %r9d, %xmm6, %xmm13

  PREFETCHt0 (%rsi)
  PREFETCHw (%rdi)

  VPSHUFD $0xff, %xmm2, %xmm0
  VAESENCLAST %xmm5, %xmm0, %xmm0

  CMPQ $16, %rdx
  JLE fly1
  CMPQ $32, %rdx
  JLE fly2
  CMPQ $48, %rdx
  JLE fly3
  CMPQ $64, %rdx
  JLE fly4
  CMPQ $80, %rdx
  JLE fly5
  CMPQ $96, %rdx
  JLE fly6
  CMPQ $112, %rdx
  JLE fly7
  CMPQ $128, %rdx
  JLE fly8

fly4:
  enc4 %xmm3
  linearmix %xmm3, %xmm0
  enc4 %xmm2

  MOV $5, %rax
  .align 4
  ctr4:
    expand1
    enc4 %xmm3
    expand2
    enc4 %xmm2
  DEC %rax
  JNZ ctr4

  expand1
  enc4 %xmm3

  VAESENCLAST %xmm2, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm7, %xmm7
  VAESENCLAST %xmm2, %xmm8, %xmm8
  VAESENCLAST %xmm2, %xmm9, %xmm9

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VMOVDQU %xmm6, 0*16(%rdi)
  VPXOR 1*16(%rsi), %xmm7, %xmm7
  VMOVDQU %xmm7, 1*16(%rdi)
  VPXOR 2*16(%rsi), %xmm8, %xmm8
  VMOVDQU %xmm8, 2*16(%rdi)

  xorlast %xmm9, 3, 48, 64

.align 4
done:

  VZEROALL
  XOR %rcx, %rcx
  XOR %rcx, %rcx
  XOR %rax, %rax
  XOR %rcx, %rcx
  XOR %rdx, %rdx
  XOR %r8, %r8
ret:
  RET

last:
  SUBQ %rcx, %rdx
  CMPQ $16, %rdx
  JL mopup
  VPXOR (%rsi, %rcx), %xmm6, %xmm6
  VMOVDQU %xmm6, (%rdi, %rcx)

mopup:
  VMOVQ %xmm6, %rax
  CMPQ $8, %rdx
  JL mopup_loop
  VPSHUFD $0xe, %xmm6, %xmm6 # %xmm6[0:4] = {%xmm6[2], %xmm6[3], ... }

  XORQ (%rsi, %rcx), %rax
  MOVQ %rax, (%rdi, %rcx)
  ADDQ $8, %rcx
  SUBQ $8, %rdx
  JZ done

  VMOVQ %xmm6, %rax

mopup_loop:
  XORB (%rsi, %rcx), %al
  MOVB %al, (%rdi, %rcx)
  RORX $8, %rax, %rax
  INC %rcx
  DEC %rdx
  JNZ mopup_loop

  done

fly8:
  enc8 %xmm3
  linearmix %xmm3, %xmm0
  enc8 %xmm2

  MOV $5, %rax
  .align 4
  ctr8:
    expand1
    enc8 %xmm3
    expand2
    enc8 %xmm2

  DEC %rax
  JNZ ctr8

  expand1
  enc8 %xmm3

  last8 %xmm2

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VMOVDQU %xmm6, 0*16(%rdi)
  VPXOR 1*16(%rsi), %xmm7, %xmm7
  VMOVDQU %xmm7, 1*16(%rdi)
  VPXOR 2*16(%rsi), %xmm8, %xmm8
  VMOVDQU %xmm8, 2*16(%rdi)
  VPXOR 3*16(%rsi), %xmm9, %xmm9
  VMOVDQU %xmm9, 3*16(%rdi)
  VPXOR 4*16(%rsi), %xmm10, %xmm10
  VMOVDQU %xmm10, 4*16(%rdi)
  VPXOR 5*16(%rsi), %xmm11, %xmm11
  VMOVDQU %xmm11, 5*16(%rdi)
  VPXOR 6*16(%rsi), %xmm12, %xmm12
  VMOVDQU %xmm12, 6*16(%rdi)

  xorlast %xmm13, 7, 112, 128

fly5:
  enc5 %xmm3

  linearmix %xmm3, %xmm0
  enc5 %xmm2

  MOV $5, %rax
  .align 4
  ctr5:
    expand1
    enc5 %xmm3
    expand2
    enc5 %xmm2

  DEC %rax
  JNZ ctr5

  expand1
  enc5 %xmm3

  VAESENCLAST %xmm2, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm7, %xmm7
  VAESENCLAST %xmm2, %xmm8, %xmm8
  VAESENCLAST %xmm2, %xmm9, %xmm9
  VAESENCLAST %xmm2, %xmm10, %xmm10

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VMOVDQU %xmm6, 0*16(%rdi)
  VPXOR 1*16(%rsi), %xmm7, %xmm7
  VMOVDQU %xmm7, 1*16(%rdi)
  VPXOR 2*16(%rsi), %xmm8, %xmm8
  VMOVDQU %xmm8, 2*16(%rdi)
  VPXOR 3*16(%rsi), %xmm9, %xmm9
  VMOVDQU %xmm9, 3*16(%rdi)

  xorlast %xmm10, 4, 64, 80

fly6:
  enc6 %xmm3

  linearmix %xmm3, %xmm0
  enc6 %xmm2

  MOV $5, %rax
  .align 4
  ctr6:
    expand1
    enc6 %xmm3
    expand2
    enc6 %xmm2
  DEC %rax
  JNZ ctr6

  expand1
  enc6 %xmm3

  VAESENCLAST %xmm2, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm7, %xmm7
  VAESENCLAST %xmm2, %xmm8, %xmm8
  VAESENCLAST %xmm2, %xmm9, %xmm9
  VAESENCLAST %xmm2, %xmm10, %xmm10
  VAESENCLAST %xmm2, %xmm11, %xmm11

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VMOVDQU %xmm6, 0*16(%rdi)
  VPXOR 1*16(%rsi), %xmm7, %xmm7
  VMOVDQU %xmm7, 1*16(%rdi)
  VPXOR 2*16(%rsi), %xmm8, %xmm8
  VMOVDQU %xmm8, 2*16(%rdi)
  VPXOR 3*16(%rsi), %xmm9, %xmm9
  VMOVDQU %xmm9, 3*16(%rdi)
  VPXOR 4*16(%rsi), %xmm10, %xmm10
  VMOVDQU %xmm10, 4*16(%rdi)

  xorlast %xmm11, 5, 80, 96

fly7:
  enc7 %xmm3

  linearmix %xmm3, %xmm0
  enc7 %xmm2
  MOV $5, %rax
  .align 4
  ctr7:
    expand1
    enc7 %xmm3
    expand2
    enc7 %xmm2
  DEC %rax
  JNZ ctr7

  expand1
  enc7 %xmm3


  VAESENCLAST %xmm2, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm7, %xmm7
  VAESENCLAST %xmm2, %xmm8, %xmm8
  VAESENCLAST %xmm2, %xmm9, %xmm9
  VAESENCLAST %xmm2, %xmm10, %xmm10
  VAESENCLAST %xmm2, %xmm11, %xmm11
  VAESENCLAST %xmm2, %xmm12, %xmm12

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VMOVDQU %xmm6, 0*16(%rdi)
  VPXOR 1*16(%rsi), %xmm7, %xmm7
  VMOVDQU %xmm7, 1*16(%rdi)
  VPXOR 2*16(%rsi), %xmm8, %xmm8
  VMOVDQU %xmm8, 2*16(%rdi)
  VPXOR 3*16(%rsi), %xmm9, %xmm9
  VMOVDQU %xmm9, 3*16(%rdi)
  VPXOR 4*16(%rsi), %xmm10, %xmm10
  VMOVDQU %xmm10, 4*16(%rdi)
  VPXOR 5*16(%rsi), %xmm11, %xmm11
  VMOVDQU %xmm11, 5*16(%rdi)

  xorlast %xmm12, 6, 96, 112

fly3:
  enc3 %xmm3
  linearmix %xmm3, %xmm0
  enc3 %xmm2

  MOV $5, %rax
  .align 4
  ctr3:
    expand1
    enc3 %xmm3
    expand2
    enc3 %xmm2
  DEC %rax
  JNZ ctr3

  expand1
  enc3 %xmm3

  VAESENCLAST %xmm2, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm7, %xmm7
  VAESENCLAST %xmm2, %xmm8, %xmm8

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VMOVDQU %xmm6, 0*16(%rdi)
  VPXOR 1*16(%rsi), %xmm7, %xmm7
  VMOVDQU %xmm7, 1*16(%rdi)

  xorlast %xmm8, 2, 32, 48


fly2:
  enc2 %xmm3
  linearmix %xmm3, %xmm0
  enc2 %xmm2

  MOV $5, %rax
  .align 4
  ctr2:
    expand1
    enc2 %xmm3
    expand2
    enc2 %xmm2
  DEC %rax
  JNZ ctr2

  expand1
  enc2 %xmm3

  VAESENCLAST %xmm2, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm7, %xmm7

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VMOVDQU %xmm6, 0*16(%rdi)

  xorlast %xmm7, 1, 16, 32


fly1:
  VAESENC %xmm3, %xmm6, %xmm6
  linearmix %xmm3, %xmm0
  VAESENC %xmm2, %xmm6, %xmm6

  MOV $5, %rax
  .align 4
  ctr1:
    expand1
    VAESENC %xmm3, %xmm6, %xmm6
    expand2
    VAESENC %xmm2, %xmm6, %xmm6
  DEC %rax
  JNZ ctr1

  expand1
  VAESENC %xmm3, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm6, %xmm6

  xorlast %xmm6, 0, 0, 16
