# 1 "inline.s"
# 1 "<built-in>" 1
# 1 "inline.s" 2
# 45 "inline.s"
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
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 2, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 2, 0, 0, 0




.macro linearmix key, new
  VPSLLDQ $4, \key, %xmm1
  VPXOR %xmm1, \key, \key
  VPSLLDQ $4, %xmm1, %xmm1
  VPXOR %xmm1, \key, \key
  VPSLLDQ $4, %xmm1, %xmm1
  VPXOR %xmm1, \key, \key
  VPXOR %xmm0, \key, \key
.endm

.text



.align 5

.align 5
.globl _aes256_ctr4
_aes256_ctr4:
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
# 139 "inline.s"
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

  VAESENC %xmm3, %xmm6, %xmm6
  VAESENC %xmm3, %xmm7, %xmm7
  VAESENC %xmm3, %xmm8, %xmm8
  VAESENC %xmm3, %xmm9, %xmm9

  linearmix %xmm3, %xmm0
  VAESENC %xmm2, %xmm6, %xmm6
  VAESENC %xmm2, %xmm7, %xmm7
  VAESENC %xmm2, %xmm8, %xmm8
  VAESENC %xmm2, %xmm9, %xmm9

  MOV $5, %rax
  .align 4
  L_ctr4:
    VPSHUFB __shuf_2(%rip), %xmm3, %xmm0
    VAESENCLAST %xmm4, %xmm0, %xmm0
    VPSLLD $1, %xmm4, %xmm4

    linearmix %xmm2, %xmm0
    VAESENC %xmm3, %xmm6, %xmm6
    VAESENC %xmm3, %xmm7, %xmm7
    VAESENC %xmm3, %xmm8, %xmm8
    VAESENC %xmm3, %xmm9, %xmm9

    VPSHUFD $0xff, %xmm2, %xmm0
    VAESENCLAST %xmm5, %xmm0, %xmm0

    linearmix %xmm3, %xmm0
    VAESENC %xmm2, %xmm6, %xmm6
    VAESENC %xmm2, %xmm7, %xmm7
    VAESENC %xmm2, %xmm8, %xmm8
    VAESENC %xmm2, %xmm9, %xmm9
  DEC %rax
  JNZ L_ctr4

  VPSHUFB __shuf_2(%rip), %xmm3, %xmm0
  VAESENCLAST %xmm4, %xmm0, %xmm0
  VPSLLD $1, %xmm4, %xmm4

  linearmix %xmm2, %xmm0
  VAESENC %xmm3, %xmm6, %xmm6
  VAESENC %xmm3, %xmm7, %xmm7
  VAESENC %xmm3, %xmm8, %xmm8
  VAESENC %xmm3, %xmm9, %xmm9


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
  CMPQ $64, %rdx
  VMOVDQU %xmm9, %xmm6
  MOVQ $48, %rcx
  JNE L_last
  VPXOR 3*16(%rsi), %xmm9, %xmm9
  VMOVDQU %xmm9, 3*16(%rdi)

.align 4
L_done:

  VZEROALL
  XOR %rcx, %rcx
  XOR %rcx, %rcx
  XOR %rax, %rax
  XOR %rcx, %rcx
  XOR %rdx, %rdx
  XOR %r8, %r8
  RET

L_last:
  SUBQ %rcx, %rdx
  CMPQ $16, %rdx
  VMOVDQU %xmm9, %xmm6
  JL L_mopup
  VPXOR 3*16(%rsi), %xmm9, %xmm9
  VMOVDQU %xmm9, 3*16(%rdi)

L_mopup:
  VMOVQ %xmm6, %rax
  CMPQ $8, %rdx
  JL L_mopup_loop
  VPSHUFD $0xe, %xmm6, %xmm6 # %xmm6[0:4] = {%xmm6[2], %xmm6[3], ... }

  XORQ (%rsi, %rcx), %rax
  MOVQ %rax, (%rdi, %rcx)
  ADDQ $8, %rcx
  SUBQ $8, %rdx
  JZ L_done

  VMOVQ %xmm6, %rax

L_mopup_loop:
  XORB (%rsi, %rcx), %al
  MOVB %al, (%rdi, %rcx)
  RORX $8, %rax, %rax
  INC %rcx
  DEC %rdx
  JNZ L_mopup_loop

  JMP L_done


.globl _aes256_ctr8
_aes256_ctr8:
  VZEROUPPER

  VMOVDQU 0(%rcx), %xmm2
  VMOVDQU 16(%rcx), %xmm3

  VMOVDQU %xmm2, 0(%rcx)
  VMOVDQU %xmm3, 16(%rcx)

  VMOVDQU __rc(%rip), %xmm4

  VPXOR %xmm5, %xmm5, %xmm5

  VPXOR 0(%r8), %xmm2, %xmm6

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

  MOV $6, %rax
  .align 4
  L_ctr8:
    VPSHUFB __shuf_2(%rip), %xmm3, %xmm0
    VAESENCLAST %xmm4, %xmm0, %xmm0
    VPSLLD $1, %xmm4, %xmm4

    linearmix %xmm2, %xmm0
    VAESENC %xmm3, %xmm6, %xmm6
    VAESENC %xmm3, %xmm7, %xmm7
    VAESENC %xmm3, %xmm8, %xmm8
    VAESENC %xmm3, %xmm9, %xmm9
    VAESENC %xmm3, %xmm10, %xmm10
    VAESENC %xmm3, %xmm11, %xmm11
    VAESENC %xmm3, %xmm12, %xmm12
    VAESENC %xmm3, %xmm13, %xmm13

    VPSHUFD $0xff, %xmm2, %xmm0
    VAESENCLAST %xmm5, %xmm0, %xmm0

    linearmix %xmm3, %xmm0
    VAESENC %xmm2, %xmm6, %xmm6
    VAESENC %xmm2, %xmm7, %xmm7
    VAESENC %xmm2, %xmm8, %xmm8
    VAESENC %xmm2, %xmm9, %xmm9
    VAESENC %xmm2, %xmm10, %xmm10
    VAESENC %xmm2, %xmm11, %xmm11
    VAESENC %xmm2, %xmm12, %xmm12
    VAESENC %xmm2, %xmm13, %xmm13

  ADDQ $32, %rcx
  DEC %rax
  JNZ L_ctr8

  VPSHUFB __shuf_2(%rip), %xmm3, %xmm0
  VAESENCLAST %xmm4, %xmm0, %xmm0
  VPSLLD $1, %xmm4, %xmm4

  linearmix %xmm2, %xmm0
  VAESENC %xmm3, %xmm6, %xmm6
  VAESENC %xmm3, %xmm7, %xmm7
  VAESENC %xmm3, %xmm8, %xmm8
  VAESENC %xmm3, %xmm9, %xmm9
  VAESENC %xmm3, %xmm10, %xmm10
  VAESENC %xmm3, %xmm11, %xmm11
  VAESENC %xmm3, %xmm12, %xmm12
  VAESENC %xmm3, %xmm13, %xmm13


  VAESENCLAST %xmm2, %xmm6, %xmm6
  VAESENCLAST %xmm2, %xmm7, %xmm7
  VAESENCLAST %xmm2, %xmm8, %xmm8
  VAESENCLAST %xmm2, %xmm9, %xmm9
  VAESENCLAST %xmm2, %xmm10, %xmm10
  VAESENCLAST %xmm2, %xmm11, %xmm11
  VAESENCLAST %xmm2, %xmm12, %xmm12
  VAESENCLAST %xmm2, %xmm13, %xmm13

  VPXOR 0*16(%rsi), %xmm6, %xmm6
  VPXOR 1*16(%rsi), %xmm7, %xmm7
  VPXOR 2*16(%rsi), %xmm8, %xmm8
  VPXOR 3*16(%rsi), %xmm9, %xmm9
  VPXOR 4*16(%rsi), %xmm10, %xmm10
  VPXOR 5*16(%rsi), %xmm11, %xmm11
  VPXOR 6*16(%rsi), %xmm12, %xmm12
  VPXOR 7*16(%rsi), %xmm13, %xmm13
  VMOVDQU %xmm6, 0*16(%rdi)
  VMOVDQU %xmm7, 1*16(%rdi)
  VMOVDQU %xmm8, 2*16(%rdi)
  VMOVDQU %xmm9, 3*16(%rdi)
  VMOVDQU %xmm10, 4*16(%rdi)
  VMOVDQU %xmm11, 5*16(%rdi)
  VMOVDQU %xmm12, 6*16(%rdi)
  VMOVDQU %xmm13, 7*16(%rdi)
  JMP L_done
