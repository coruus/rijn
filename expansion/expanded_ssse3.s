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


	retq

	.globl	_Rijndael_k8w4_expandkey
_Rijndael_k8w4_expandkey:
	movdqu	(%rsi), %xmm2
	movdqu	16(%rsi), %xmm3

	movdqu	__rc(%rip), %xmm4

	movdqu	%xmm2, (%rdi)
	movdqu	%xmm3, 16(%rdi)
	addq	$32, %rdi

	movq	$6, %rax
Loop_expand:
	movdqa	%xmm3, %xmm1
	aesenclast	%xmm4, %xmm1
	pshufb	__shuf_2(%rip), %xmm1

	pslld	$1, %xmm4

	movdqa	%xmm2, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm2

	movdqa	%xmm2, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm2

	movdqa	%xmm2, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm2

	pxor	%xmm1, %xmm2

	movdqu	%xmm2, (%rdi)

	pxor	%xmm0, %xmm0
	movdqa	%xmm2, %xmm1
	pshufd	$255, %xmm1, %xmm1      ## xmm1 = xmm1[3,3,3,3]
	aesenclast	%xmm0, %xmm1

	movdqa	%xmm3, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm3

	movdqa	%xmm3, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm3

	movdqa	%xmm3, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm3

	pxor	%xmm1, %xmm3

	movdqu	%xmm3, 16(%rdi)

	addq	$32, %rdi
	decq	%rax
	jne	Loop_expand

	aesenclast	%xmm4, %xmm3
	pshufb	__shuf_2(%rip), %xmm3

	movdqa	%xmm2, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm2

	movdqa	%xmm2, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm2

	movdqa	%xmm2, %xmm0
	pslldq	$4, %xmm0               ## xmm0 = zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11]
	pxor	%xmm0, %xmm2

	pxor	%xmm3, %xmm2

	movdqu	%xmm2, (%rdi)

	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3
	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm4, %xmm4
	xorq	%rsi, %rsi
	xorq	%rdi, %rdi
	retq
