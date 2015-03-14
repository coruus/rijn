# 1 "expand.s"
# 1 "<built-in>" 1
# 1 "expand.s" 2
# 18 "expand.s"
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







.macro linearmix key, new
  VPSHUFB __shuf_l(%rip), \key, %xmm2
  VPXOR \key, %xmm2, \key
  VPSHUFB __shuf_l(%rip), \key, %xmm2
  VPXOR \key, %xmm2, \key
  VPSHUFB __shuf_l(%rip), \key, %xmm2
  VPXOR \key, %xmm2, \key
  VPXOR \key, \new, \key
.endm

.text
.L_DR:

  VAESENCLAST %xmm4, %xmm3, %xmm1
  VPSHUFB __shuf_2(%rip), %xmm1, %xmm1

  VPSLLD $1, %xmm4, %xmm4

  linearmix %xmm0, %xmm1
  VMOVDQU %xmm0, 0(%rdi)

  VPXOR %xmm2, %xmm2, %xmm2
  VPSHUFB __shuf_1(%rip), %xmm0, %xmm1
  VAESENCLAST %xmm2, %xmm1, %xmm1

  linearmix %xmm3, %xmm1
  VMOVDQU %xmm3, 16(%rdi)

  ADDQ $32, %rdi
  RET

.globl _Rijndael_k8w4_expandkey
_Rijndael_k8w4_expandkey:
  VZEROUPPER

  VMOVDQU 0(%rsi), %xmm0
  VMOVDQU 16(%rsi), %xmm3

  VMOVDQU __rc(%rip), %xmm4

  VMOVDQU %xmm0, 0(%rdi)
  VMOVDQU %xmm3, 16(%rdi)
  ADD $32, %rdi


  CALL .L_DR
  CALL .L_DR
  CALL .L_DR
  CALL .L_DR
  CALL .L_DR
  CALL .L_DR


  VAESENCLAST %xmm4, %xmm3, %xmm1
  VPSHUFB __shuf_2(%rip), %xmm1, %xmm1

  linearmix %xmm0, %xmm1
  VMOVDQU %xmm0, 0(%rdi)

  VZEROALL
  XOR %rdi, %rdi
  XOR %rsi, %rsi
  RET
