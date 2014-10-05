	.section	__TEXT,__text,regular,pure_instructions




	.section	__DATA,__data
	.align	5
__rc:
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	1
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.quad	0
	.quad	0

__shuf_1:
	.byte	12
	.byte	13
	.byte	14
	.byte	15
	.byte	12
	.byte	13
	.byte	14
	.byte	15
	.byte	12
	.byte	13
	.byte	14
	.byte	15
	.byte	12
	.byte	13
	.byte	14
	.byte	15
	.quad	0
	.quad	0



__shuf_2:
	.byte	9
	.byte	6
	.byte	3
	.byte	12
	.byte	9
	.byte	6
	.byte	3
	.byte	12
	.byte	9
	.byte	6
	.byte	3
	.byte	12
	.byte	9
	.byte	6
	.byte	3
	.byte	12
	.quad	0
	.quad	0

__shuf_l:
	.byte	255
	.byte	255
	.byte	255
	.byte	255
	.byte	0
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	7
	.byte	8
	.byte	9
	.byte	10
	.byte	11









	.section	__TEXT,__text,regular,pure_instructions
.L_DR:

	vaesenclast	%xmm4, %xmm3, %xmm1
	vpshufb	__shuf_2(%rip), %xmm1, %xmm1

	vpslld	$1, %xmm4, %xmm4

	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpxor	%xmm2, %xmm1, %xmm2

	vmovdqu	%xmm2, (%rdi)

	vpxor	%xmm0, %xmm0, %xmm0
	vpshufb	__shuf_1(%rip), %xmm2, %xmm1
	vaesenclast	%xmm0, %xmm1, %xmm1

	vpshufb	__shuf_l(%rip), %xmm3, %xmm0
	vpxor	%xmm3, %xmm0, %xmm3
	vpshufb	__shuf_l(%rip), %xmm3, %xmm0
	vpxor	%xmm3, %xmm0, %xmm3
	vpshufb	__shuf_l(%rip), %xmm3, %xmm0
	vpxor	%xmm3, %xmm0, %xmm3
	vpxor	%xmm3, %xmm1, %xmm3

	vmovdqu	%xmm3, 16(%rdi)

	addq	$32, %rdi
	retq

	.globl	_Rijndael_k8w4_expandkey
_Rijndael_k8w4_expandkey:
	vzeroupper

	vmovdqu	(%rsi), %xmm2
	vmovdqu	16(%rsi), %xmm3

	vmovdqu	__rc(%rip), %xmm4

	vmovdqu	%xmm2, (%rdi)
	vmovdqu	%xmm3, 16(%rdi)
	addq	$32, %rdi


	callq	.L_DR
	callq	.L_DR
	callq	.L_DR
	callq	.L_DR
	callq	.L_DR
	callq	.L_DR


	vaesenclast	%xmm4, %xmm3, %xmm1
	vpshufb	__shuf_2(%rip), %xmm1, %xmm1

	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpxor	%xmm2, %xmm1, %xmm2

	vmovdqu	%xmm2, (%rdi)

	vzeroall
	xorq	%rdi, %rdi
	xorq	%rsi, %rsi
	retq
