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







	.globl	_Rijndael_k8w4_expandkey
_Rijndael_k8w4_expandkey:
	vzeroupper

	vmovdqu	(%rcx), %xmm2
	vmovdqu	16(%rcx), %xmm3

	vmovdqu	__rc(%rip), %xmm4

	vmovdqu	%xmm2, (%rdx)
	vmovdqu	%xmm3, 16(%rdx)
	addq	$32, %rdx

	vpxor	(%rsi), %xmm2, %xmm5
	vpxor	16(%rsi), %xmm2, %xmm6
	vpxor	32(%rsi), %xmm2, %xmm7
	vpxor	48(%rsi), %xmm2, %xmm8
	vpxor	64(%rsi), %xmm2, %xmm9
	vpxor	80(%rsi), %xmm2, %xmm10
	vpxor	96(%rsi), %xmm2, %xmm11
	vpxor	112(%rsi), %xmm2, %xmm12


	vmovdqa	%xmm2, %xmm13
	vmovdqa	%xmm3, %xmm14
	vaesenclast	%xmm4, %xmm14, %xmm1
	vpshufb	__shuf_2(%rip), %xmm1, %xmm1

	vpslld	$1, %xmm4, %xmm4

	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpxor	%xmm13, %xmm1, %xmm13

	vmovdqu	%xmm13, (%rdx)

	vpxor	%xmm0, %xmm0, %xmm0
	vpshufb	__shuf_1(%rip), %xmm13, %xmm1
	vaesenclast	%xmm0, %xmm1, %xmm1

	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpxor	%xmm14, %xmm1, %xmm14

	vmovdqu	%xmm14, 16(%rdx)

	addq	$32, %rdx

	vaesenc	%xmm3, %xmm5, %xmm5
	vaesenc	%xmm3, %xmm6, %xmm6
	vaesenc	%xmm3, %xmm7, %xmm7
	vaesenc	%xmm3, %xmm8, %xmm8
	vaesenc	%xmm3, %xmm9, %xmm9
	vaesenc	%xmm3, %xmm10, %xmm10
	vaesenc	%xmm3, %xmm11, %xmm11
	vaesenc	%xmm3, %xmm12, %xmm12


	vmovdqa	%xmm13, %xmm2
	vmovdqa	%xmm14, %xmm3
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

	vmovdqu	%xmm2, (%rdx)

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

	vmovdqu	%xmm3, 16(%rdx)

	addq	$32, %rdx

	vaesenc	%xmm13, %xmm5, %xmm5
	vaesenc	%xmm13, %xmm6, %xmm6
	vaesenc	%xmm13, %xmm7, %xmm7
	vaesenc	%xmm13, %xmm8, %xmm8
	vaesenc	%xmm13, %xmm9, %xmm9
	vaesenc	%xmm13, %xmm10, %xmm10
	vaesenc	%xmm13, %xmm11, %xmm11
	vaesenc	%xmm13, %xmm12, %xmm12

	vaesenc	%xmm14, %xmm5, %xmm5
	vaesenc	%xmm14, %xmm6, %xmm6
	vaesenc	%xmm14, %xmm7, %xmm7
	vaesenc	%xmm14, %xmm8, %xmm8
	vaesenc	%xmm14, %xmm9, %xmm9
	vaesenc	%xmm14, %xmm10, %xmm10
	vaesenc	%xmm14, %xmm11, %xmm11
	vaesenc	%xmm14, %xmm12, %xmm12


	vmovdqa	%xmm2, %xmm13
	vmovdqa	%xmm3, %xmm14
	vaesenclast	%xmm4, %xmm14, %xmm1
	vpshufb	__shuf_2(%rip), %xmm1, %xmm1

	vpslld	$1, %xmm4, %xmm4

	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpxor	%xmm13, %xmm1, %xmm13

	vmovdqu	%xmm13, (%rdx)

	vpxor	%xmm0, %xmm0, %xmm0
	vpshufb	__shuf_1(%rip), %xmm13, %xmm1
	vaesenclast	%xmm0, %xmm1, %xmm1

	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpxor	%xmm14, %xmm1, %xmm14

	vmovdqu	%xmm14, 16(%rdx)

	addq	$32, %rdx

	vaesenc	%xmm2, %xmm5, %xmm5
	vaesenc	%xmm2, %xmm6, %xmm6
	vaesenc	%xmm2, %xmm7, %xmm7
	vaesenc	%xmm2, %xmm8, %xmm8
	vaesenc	%xmm2, %xmm9, %xmm9
	vaesenc	%xmm2, %xmm10, %xmm10
	vaesenc	%xmm2, %xmm11, %xmm11
	vaesenc	%xmm2, %xmm12, %xmm12

	vaesenc	%xmm3, %xmm5, %xmm5
	vaesenc	%xmm3, %xmm6, %xmm6
	vaesenc	%xmm3, %xmm7, %xmm7
	vaesenc	%xmm3, %xmm8, %xmm8
	vaesenc	%xmm3, %xmm9, %xmm9
	vaesenc	%xmm3, %xmm10, %xmm10
	vaesenc	%xmm3, %xmm11, %xmm11
	vaesenc	%xmm3, %xmm12, %xmm12


	vmovdqa	%xmm13, %xmm2
	vmovdqa	%xmm14, %xmm3
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

	vmovdqu	%xmm2, (%rdx)

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

	vmovdqu	%xmm3, 16(%rdx)

	addq	$32, %rdx

	vaesenc	%xmm13, %xmm5, %xmm5
	vaesenc	%xmm13, %xmm6, %xmm6
	vaesenc	%xmm13, %xmm7, %xmm7
	vaesenc	%xmm13, %xmm8, %xmm8
	vaesenc	%xmm13, %xmm9, %xmm9
	vaesenc	%xmm13, %xmm10, %xmm10
	vaesenc	%xmm13, %xmm11, %xmm11
	vaesenc	%xmm13, %xmm12, %xmm12

	vaesenc	%xmm14, %xmm5, %xmm5
	vaesenc	%xmm14, %xmm6, %xmm6
	vaesenc	%xmm14, %xmm7, %xmm7
	vaesenc	%xmm14, %xmm8, %xmm8
	vaesenc	%xmm14, %xmm9, %xmm9
	vaesenc	%xmm14, %xmm10, %xmm10
	vaesenc	%xmm14, %xmm11, %xmm11
	vaesenc	%xmm14, %xmm12, %xmm12


	vmovdqa	%xmm2, %xmm13
	vmovdqa	%xmm3, %xmm14
	vaesenclast	%xmm4, %xmm14, %xmm1
	vpshufb	__shuf_2(%rip), %xmm1, %xmm1

	vpslld	$1, %xmm4, %xmm4

	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpshufb	__shuf_l(%rip), %xmm13, %xmm0
	vpxor	%xmm13, %xmm0, %xmm13
	vpxor	%xmm13, %xmm1, %xmm13

	vmovdqu	%xmm13, (%rdx)

	vpxor	%xmm0, %xmm0, %xmm0
	vpshufb	__shuf_1(%rip), %xmm13, %xmm1
	vaesenclast	%xmm0, %xmm1, %xmm1

	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpshufb	__shuf_l(%rip), %xmm14, %xmm0
	vpxor	%xmm14, %xmm0, %xmm14
	vpxor	%xmm14, %xmm1, %xmm14

	vmovdqu	%xmm14, 16(%rdx)

	addq	$32, %rdx

	vaesenc	%xmm2, %xmm5, %xmm5
	vaesenc	%xmm2, %xmm6, %xmm6
	vaesenc	%xmm2, %xmm7, %xmm7
	vaesenc	%xmm2, %xmm8, %xmm8
	vaesenc	%xmm2, %xmm9, %xmm9
	vaesenc	%xmm2, %xmm10, %xmm10
	vaesenc	%xmm2, %xmm11, %xmm11
	vaesenc	%xmm2, %xmm12, %xmm12

	vaesenc	%xmm3, %xmm5, %xmm5
	vaesenc	%xmm3, %xmm6, %xmm6
	vaesenc	%xmm3, %xmm7, %xmm7
	vaesenc	%xmm3, %xmm8, %xmm8
	vaesenc	%xmm3, %xmm9, %xmm9
	vaesenc	%xmm3, %xmm10, %xmm10
	vaesenc	%xmm3, %xmm11, %xmm11
	vaesenc	%xmm3, %xmm12, %xmm12


	vmovdqa	%xmm13, %xmm2
	vmovdqa	%xmm14, %xmm3
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

	vmovdqu	%xmm2, (%rdx)

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

	vmovdqu	%xmm3, 16(%rdx)

	addq	$32, %rdx

	vaesenc	%xmm13, %xmm5, %xmm5
	vaesenc	%xmm13, %xmm6, %xmm6
	vaesenc	%xmm13, %xmm7, %xmm7
	vaesenc	%xmm13, %xmm8, %xmm8
	vaesenc	%xmm13, %xmm9, %xmm9
	vaesenc	%xmm13, %xmm10, %xmm10
	vaesenc	%xmm13, %xmm11, %xmm11
	vaesenc	%xmm13, %xmm12, %xmm12

	vaesenc	%xmm14, %xmm5, %xmm5
	vaesenc	%xmm14, %xmm6, %xmm6
	vaesenc	%xmm14, %xmm7, %xmm7
	vaesenc	%xmm14, %xmm8, %xmm8
	vaesenc	%xmm14, %xmm9, %xmm9
	vaesenc	%xmm14, %xmm10, %xmm10
	vaesenc	%xmm14, %xmm11, %xmm11
	vaesenc	%xmm14, %xmm12, %xmm12

	vaesenc	%xmm2, %xmm5, %xmm5
	vaesenc	%xmm2, %xmm6, %xmm6
	vaesenc	%xmm2, %xmm7, %xmm7
	vaesenc	%xmm2, %xmm8, %xmm8
	vaesenc	%xmm2, %xmm9, %xmm9
	vaesenc	%xmm2, %xmm10, %xmm10
	vaesenc	%xmm2, %xmm11, %xmm11
	vaesenc	%xmm2, %xmm12, %xmm12



	vaesenclast	%xmm4, %xmm3, %xmm1
	vpshufb	__shuf_2(%rip), %xmm1, %xmm1

	vaesenc	%xmm3, %xmm5, %xmm5
	vaesenc	%xmm3, %xmm6, %xmm6
	vaesenc	%xmm3, %xmm7, %xmm7
	vaesenc	%xmm3, %xmm8, %xmm8
	vaesenc	%xmm3, %xmm9, %xmm9
	vaesenc	%xmm3, %xmm10, %xmm10
	vaesenc	%xmm3, %xmm11, %xmm11
	vaesenc	%xmm3, %xmm12, %xmm12


	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpshufb	__shuf_l(%rip), %xmm2, %xmm0
	vpxor	%xmm2, %xmm0, %xmm2
	vpxor	%xmm2, %xmm1, %xmm2

	vmovdqu	%xmm2, (%rdx)

	vaesenclast	%xmm2, %xmm5, %xmm5
	vaesenclast	%xmm2, %xmm6, %xmm6
	vaesenclast	%xmm2, %xmm7, %xmm7
	vaesenclast	%xmm2, %xmm8, %xmm8
	vaesenclast	%xmm2, %xmm9, %xmm9
	vaesenclast	%xmm2, %xmm10, %xmm10
	vaesenclast	%xmm2, %xmm11, %xmm11
	vaesenclast	%xmm2, %xmm12, %xmm12


.LDONE:
	vmovdqu	%xmm5, (%rdi)
	vmovdqu	%xmm6, 16(%rdi)
	vmovdqu	%xmm7, 32(%rdi)
	vmovdqu	%xmm8, 48(%rdi)
	vmovdqu	%xmm9, 64(%rdi)
	vmovdqu	%xmm10, 80(%rdi)
	vmovdqu	%xmm11, 96(%rdi)
	vmovdqu	%xmm12, 112(%rdi)


	vzeroall
	retq


	.globl	_ecb
_ecb:



	vmovdqu	(%rdx), %xmm2
	vpxor	(%rsi), %xmm2, %xmm5
	vpxor	16(%rsi), %xmm2, %xmm6
	vpxor	32(%rsi), %xmm2, %xmm7
	vpxor	48(%rsi), %xmm2, %xmm8
	vpxor	64(%rsi), %xmm2, %xmm9
	vpxor	80(%rsi), %xmm2, %xmm10
	vpxor	96(%rsi), %xmm2, %xmm11
	vpxor	112(%rsi), %xmm2, %xmm12

	vaesenc	16(%rdx), %xmm5, %xmm5
	vaesenc	16(%rdx), %xmm6, %xmm6
	vaesenc	16(%rdx), %xmm7, %xmm7
	vaesenc	16(%rdx), %xmm8, %xmm8
	vaesenc	16(%rdx), %xmm9, %xmm9
	vaesenc	16(%rdx), %xmm10, %xmm10
	vaesenc	16(%rdx), %xmm11, %xmm11
	vaesenc	16(%rdx), %xmm12, %xmm12

	vaesenc	32(%rdx), %xmm5, %xmm5
	vaesenc	32(%rdx), %xmm6, %xmm6
	vaesenc	32(%rdx), %xmm7, %xmm7
	vaesenc	32(%rdx), %xmm8, %xmm8
	vaesenc	32(%rdx), %xmm9, %xmm9
	vaesenc	32(%rdx), %xmm10, %xmm10
	vaesenc	32(%rdx), %xmm11, %xmm11
	vaesenc	32(%rdx), %xmm12, %xmm12

	vaesenc	48(%rdx), %xmm5, %xmm5
	vaesenc	48(%rdx), %xmm6, %xmm6
	vaesenc	48(%rdx), %xmm7, %xmm7
	vaesenc	48(%rdx), %xmm8, %xmm8
	vaesenc	48(%rdx), %xmm9, %xmm9
	vaesenc	48(%rdx), %xmm10, %xmm10
	vaesenc	48(%rdx), %xmm11, %xmm11
	vaesenc	48(%rdx), %xmm12, %xmm12

	vaesenc	64(%rdx), %xmm5, %xmm5
	vaesenc	64(%rdx), %xmm6, %xmm6
	vaesenc	64(%rdx), %xmm7, %xmm7
	vaesenc	64(%rdx), %xmm8, %xmm8
	vaesenc	64(%rdx), %xmm9, %xmm9
	vaesenc	64(%rdx), %xmm10, %xmm10
	vaesenc	64(%rdx), %xmm11, %xmm11
	vaesenc	64(%rdx), %xmm12, %xmm12

	vaesenc	80(%rdx), %xmm5, %xmm5
	vaesenc	80(%rdx), %xmm6, %xmm6
	vaesenc	80(%rdx), %xmm7, %xmm7
	vaesenc	80(%rdx), %xmm8, %xmm8
	vaesenc	80(%rdx), %xmm9, %xmm9
	vaesenc	80(%rdx), %xmm10, %xmm10
	vaesenc	80(%rdx), %xmm11, %xmm11
	vaesenc	80(%rdx), %xmm12, %xmm12

	vaesenc	96(%rdx), %xmm5, %xmm5
	vaesenc	96(%rdx), %xmm6, %xmm6
	vaesenc	96(%rdx), %xmm7, %xmm7
	vaesenc	96(%rdx), %xmm8, %xmm8
	vaesenc	96(%rdx), %xmm9, %xmm9
	vaesenc	96(%rdx), %xmm10, %xmm10
	vaesenc	96(%rdx), %xmm11, %xmm11
	vaesenc	96(%rdx), %xmm12, %xmm12

	vaesenc	112(%rdx), %xmm5, %xmm5
	vaesenc	112(%rdx), %xmm6, %xmm6
	vaesenc	112(%rdx), %xmm7, %xmm7
	vaesenc	112(%rdx), %xmm8, %xmm8
	vaesenc	112(%rdx), %xmm9, %xmm9
	vaesenc	112(%rdx), %xmm10, %xmm10
	vaesenc	112(%rdx), %xmm11, %xmm11
	vaesenc	112(%rdx), %xmm12, %xmm12

	vaesenc	128(%rdx), %xmm5, %xmm5
	vaesenc	128(%rdx), %xmm6, %xmm6
	vaesenc	128(%rdx), %xmm7, %xmm7
	vaesenc	128(%rdx), %xmm8, %xmm8
	vaesenc	128(%rdx), %xmm9, %xmm9
	vaesenc	128(%rdx), %xmm10, %xmm10
	vaesenc	128(%rdx), %xmm11, %xmm11
	vaesenc	128(%rdx), %xmm12, %xmm12

	vaesenc	144(%rdx), %xmm5, %xmm5
	vaesenc	144(%rdx), %xmm6, %xmm6
	vaesenc	144(%rdx), %xmm7, %xmm7
	vaesenc	144(%rdx), %xmm8, %xmm8
	vaesenc	144(%rdx), %xmm9, %xmm9
	vaesenc	144(%rdx), %xmm10, %xmm10
	vaesenc	144(%rdx), %xmm11, %xmm11
	vaesenc	144(%rdx), %xmm12, %xmm12

	vaesenc	160(%rdx), %xmm5, %xmm5
	vaesenc	160(%rdx), %xmm6, %xmm6
	vaesenc	160(%rdx), %xmm7, %xmm7
	vaesenc	160(%rdx), %xmm8, %xmm8
	vaesenc	160(%rdx), %xmm9, %xmm9
	vaesenc	160(%rdx), %xmm10, %xmm10
	vaesenc	160(%rdx), %xmm11, %xmm11
	vaesenc	160(%rdx), %xmm12, %xmm12

	vaesenc	176(%rdx), %xmm5, %xmm5
	vaesenc	176(%rdx), %xmm6, %xmm6
	vaesenc	176(%rdx), %xmm7, %xmm7
	vaesenc	176(%rdx), %xmm8, %xmm8
	vaesenc	176(%rdx), %xmm9, %xmm9
	vaesenc	176(%rdx), %xmm10, %xmm10
	vaesenc	176(%rdx), %xmm11, %xmm11
	vaesenc	176(%rdx), %xmm12, %xmm12

	vaesenc	192(%rdx), %xmm5, %xmm5
	vaesenc	192(%rdx), %xmm6, %xmm6
	vaesenc	192(%rdx), %xmm7, %xmm7
	vaesenc	192(%rdx), %xmm8, %xmm8
	vaesenc	192(%rdx), %xmm9, %xmm9
	vaesenc	192(%rdx), %xmm10, %xmm10
	vaesenc	192(%rdx), %xmm11, %xmm11
	vaesenc	192(%rdx), %xmm12, %xmm12

	vaesenc	208(%rdx), %xmm5, %xmm5
	vaesenc	208(%rdx), %xmm6, %xmm6
	vaesenc	208(%rdx), %xmm7, %xmm7
	vaesenc	208(%rdx), %xmm8, %xmm8
	vaesenc	208(%rdx), %xmm9, %xmm9
	vaesenc	208(%rdx), %xmm10, %xmm10
	vaesenc	208(%rdx), %xmm11, %xmm11
	vaesenc	208(%rdx), %xmm12, %xmm12

	vaesenclast	224(%rdx), %xmm5, %xmm5
	vaesenclast	224(%rdx), %xmm6, %xmm6
	vaesenclast	224(%rdx), %xmm7, %xmm7
	vaesenclast	224(%rdx), %xmm8, %xmm8
	vaesenclast	224(%rdx), %xmm9, %xmm9
	vaesenclast	224(%rdx), %xmm10, %xmm10
	vaesenclast	224(%rdx), %xmm11, %xmm11
	vaesenclast	224(%rdx), %xmm12, %xmm12


	vmovdqu	%xmm5, (%rdi)
	vmovdqu	%xmm6, 16(%rdi)
	vmovdqu	%xmm7, 32(%rdi)
	vmovdqu	%xmm8, 48(%rdi)
	vmovdqu	%xmm9, 64(%rdi)
	vmovdqu	%xmm10, 80(%rdi)
	vmovdqu	%xmm11, 96(%rdi)
	vmovdqu	%xmm12, 112(%rdi)

	vzeroall
	retq
