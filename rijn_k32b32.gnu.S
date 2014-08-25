/*
 * Rijndael with 256-bit blocksize and 256-bit keylength.
 *
 * (Translated from the original YASM by LLVM-MC.)
 *
 * Implementor: David Leon Gil
 * Inspired by:
 *   Shay Gueron and Vlad Krasnov
 *   Andy Poylakov
 * License: CC0, attribution kindly requested.
 *
 * An up-to-date version will be maintained at:
 *   https://github.com/coruus/rijn
 *
 * Notes:
 *   No secret data ever flows into a GPR; but memory locations
 *   of secret data are not cleaned from GPRs.
 *
 *   (Note: The counter is treated as secret.)
*/
.data

.align 7
__shuf:
  .byte 0x0, 0x1, 0x6, 0x7
  .byte 0x4, 0x5, 0xa, 0xb
  .byte 0x8, 0x9, 0xe, 0xf
  .byte 0xc, 0xd, 0x2, 0x3
__mask:
  .byte 0, 0xff, 0xff, 0xff
  .byte 0,    0, 0xff, 0xff
  .byte 0,    0, 0xff, 0xff
  .byte 0,    0,    0, 0xff
__one:   .byte 0,0,0,0,0,0,0,0
         .byte 1,0,0,0,0,0,0,0
__two:   .byte 0,0,0,0,0,0,0,0
         .byte 2,0,0,0,0,0,0,0
__three: .byte 0,0,0,0,0,0,0,0
         .byte 3,0,0,0,0,0,0,0
__four:  .byte 0,0,0,0,0,0,0,0
         .byte 4,0,0,0,0,0,0,0

.align 5
.text

.global _Rijndael_k32b32_ctr
_Rijndael_k32b32_ctr:
	vzeroall
	movq	%rdi, %r10
	movq	%rsi, %r11
.align 4
Rijndael_k32b32_ctr._start:
	movq	%r10, %rdi
	vmovdqu	0x00(%rdi), %xmm1
	vmovdqu	0x10(%rdi), %xmm0
	vmovdqu	0x00(%rcx), %xmm2
	vmovdqu	0x10(%rcx), %xmm11
	vpxor	%xmm1, %xmm2, %xmm2
	vmovdqa	%xmm11, %xmm3
	vpaddq	__one(%rip), %xmm11, %xmm5
	vpaddq	__two(%rip), %xmm11, %xmm7
	vpaddq	__three(%rip), %xmm11, %xmm9
	vmovdqa	%xmm2, %xmm4
	vmovdqa	%xmm2, %xmm6
	vmovdqa	%xmm2, %xmm8
	vpxor	%xmm0, %xmm3, %xmm3
	vpxor	%xmm0, %xmm5, %xmm5
	vpxor	%xmm0, %xmm7, %xmm7
	vpxor	%xmm0, %xmm9, %xmm9
	vpaddq	__four(%rip), %xmm11, %xmm11
	vmovdqu	%xmm11, 0x10(%rcx)
	movq	$0x1, %r9
.align 4
Rijndael_k32b32_ctr._rounds:
	addq	$0x20, %rdi
	vpxor	%xmm3, %xmm2, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm2, %xmm2
	vpxor	%xmm0, %xmm3, %xmm3
	vpshufb	__shuf(%rip), %xmm3, %xmm3
	vpshufb	__shuf(%rip), %xmm2, %xmm2
	vaesenc	0x10(%rdi), %xmm3, %xmm3
	vaesenc	0x00(%rdi), %xmm2, %xmm2
	vpxor	%xmm5, %xmm4, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm4, %xmm4
	vpxor	%xmm0, %xmm5, %xmm5
	vpshufb	__shuf(%rip), %xmm5, %xmm5
	vpshufb	__shuf(%rip), %xmm4, %xmm4
	vaesenc	0x10(%rdi), %xmm5, %xmm5
	vaesenc	0x00(%rdi), %xmm4, %xmm4
	vpxor	%xmm7, %xmm6, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm6, %xmm6
	vpxor	%xmm0, %xmm7, %xmm7
	vpshufb	__shuf(%rip), %xmm7, %xmm7
	vpshufb	__shuf(%rip), %xmm6, %xmm6
	vaesenc	0x10(%rdi), %xmm7, %xmm7
	vaesenc	0x00(%rdi), %xmm6, %xmm6
	vpxor	%xmm9, %xmm8, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm8, %xmm8
	vpxor	%xmm0, %xmm9, %xmm9
	vpshufb	__shuf(%rip), %xmm9, %xmm9
	vpshufb	__shuf(%rip), %xmm8, %xmm8
	vaesenc	0x10(%rdi), %xmm9, %xmm9
	vaesenc	0x00(%rdi), %xmm8, %xmm8
	incq	%r9
	cmpq	$0xe, %r9
	jne	Rijndael_k32b32_ctr._rounds
	vpxor	%xmm3, %xmm2, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm2, %xmm2
	vpxor	%xmm0, %xmm3, %xmm3
	vpshufb	__shuf(%rip), %xmm3, %xmm3
	vpshufb	__shuf(%rip), %xmm2, %xmm2
	vaesenclast	0x1d0(%r10), %xmm3, %xmm3
	vaesenclast	0x1c0(%r10), %xmm2, %xmm2
	vpxor	0x10(%rsi), %xmm3, %xmm3
	vpxor	0x00(%rsi), %xmm2, %xmm2
	vmovdqu	%xmm3, 0x10(%rsi)
	vmovdqu	%xmm2, 0x00(%rsi)
	vpxor	%xmm5, %xmm4, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm4, %xmm4
	vpxor	%xmm0, %xmm5, %xmm5
	vpshufb	__shuf(%rip), %xmm5, %xmm5
	vpshufb	__shuf(%rip), %xmm4, %xmm4
	vaesenclast	0x1d0(%r10), %xmm5, %xmm5
	vaesenclast	0x1c0(%r10), %xmm4, %xmm4
	vpxor	0x30(%rsi), %xmm5, %xmm5
	vpxor	0x20(%rsi), %xmm4, %xmm4
	vmovdqu	%xmm5, 0x30(%rsi)
	vmovdqu	%xmm4, 0x20(%rsi)
	vpxor	%xmm7, %xmm6, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm6, %xmm6
	vpxor	%xmm0, %xmm7, %xmm7
	vpshufb	__shuf(%rip), %xmm7, %xmm7
	vpshufb	__shuf(%rip), %xmm6, %xmm6
	vaesenclast	0x1d0(%r10), %xmm7, %xmm7
	vaesenclast	0x1c0(%r10), %xmm6, %xmm6
	vpxor	0x50(%rsi), %xmm7, %xmm7
	vpxor	0x40(%rsi), %xmm6, %xmm6
	vmovdqu	%xmm7, 0x50(%rsi)
	vmovdqu	%xmm6, 0x40(%rsi)
	vpxor	%xmm9, %xmm8, %xmm0
	vpand	__mask(%rip), %xmm0, %xmm0
	vpxor	%xmm0, %xmm8, %xmm8
	vpxor	%xmm0, %xmm9, %xmm9
	vpshufb	__shuf(%rip), %xmm9, %xmm9
	vpshufb	__shuf(%rip), %xmm8, %xmm8
	vaesenclast	0x1d0(%r10), %xmm9, %xmm9
	vaesenclast	0x1c0(%r10), %xmm8, %xmm8
	vpxor	0x70(%rsi), %xmm9, %xmm9
	vpxor	0x60(%rsi), %xmm8, %xmm8
	vmovdqu	%xmm9, 0x70(%rsi)
	vmovdqu	%xmm8, 0x60(%rsi)
	addq	$0x80, %rdx
	addq	$0x80, %rsi
	subq	$0x1, %r8
	jne	Rijndael_k32b32_ctr._start
	vzeroall
	retq
