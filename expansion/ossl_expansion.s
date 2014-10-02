#
# ====================================================================
# Written by Andy Polyakov <appro@openssl.org> for the OpenSSL
# project. The module is, however, dual licensed under OpenSSL and
# CRYPTOGAMS licenses depending on where you obtain it. For further
# details see http://www.openssl.org/~appro/cryptogams/.
# ====================================================================
#

# This is based on submission by
#
#	Huang Ying <ying.huang@intel.com>
#	Vinodh Gopal <vinodh.gopal@intel.com>
#	Kahraman Akdemir
#
# Agressively optimized in respect to aeskeygenassist's critical path
# and is contained in %xmm0-5 to meet Win64 ABI requirement.
#

.text	

.globl	aesni_set_decrypt_key
.align	4
aesni_set_decrypt_key:
.byte	0x48,0x83,0xEC,0x08
	call	__aesni_set_encrypt_key
	shll	$4,%esi
	testl	%eax,%eax
	jnz	.Ldec_key_ret
	leaq	16(%rdx,%rsi,1),%rdi

	movups	(%rdx),%xmm0
	movups	(%rdi),%xmm1
	movups	%xmm0,(%rdi)
	movups	%xmm1,(%rdx)
	leaq	16(%rdx),%rdx
	leaq	-16(%rdi),%rdi

.Ldec_key_inverse:
	movups	(%rdx),%xmm0
	movups	(%rdi),%xmm1
.byte	102,15,56,219,192
.byte	102,15,56,219,201
	leaq	16(%rdx),%rdx
	leaq	-16(%rdi),%rdi
	movups	%xmm0,16(%rdi)
	movups	%xmm1,-16(%rdx)
	cmpq	%rdx,%rdi
	ja	.Ldec_key_inverse

	movups	(%rdx),%xmm0
.byte	102,15,56,219,192
	movups	%xmm0,(%rdi)
.Ldec_key_ret:
	addq	$8,%rsp
	.byte	0xf3,0xc3

.globl	_aesni_set_encrypt_key
.align	4
_aesni_set_encrypt_key:
__aesni_set_encrypt_key:
.byte	0x48,0x83,0xEC,0x08
	movq	$-1,%rax
	testq	%rdi,%rdi
	jz	.Lenc_key_ret
	testq	%rdx,%rdx
	jz	.Lenc_key_ret

	movups	(%rdi),%xmm0
	xorps	%xmm4,%xmm4
	leaq	16(%rdx),%rax
	cmpl	$256,%esi
	je	.L14rounds
	cmpl	$192,%esi
	je	.L12rounds
	cmpl	$128,%esi
	jne	.Lbad_keybits

.L10rounds:
	movl	$9,%esi
	movups	%xmm0,(%rdx)
.byte	102,15,58,223,200,1
	call	.Lkey_expansion_128_cold
.byte	102,15,58,223,200,2
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,4
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,8
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,16
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,32
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,64
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,128
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,27
	call	.Lkey_expansion_128
.byte	102,15,58,223,200,54
	call	.Lkey_expansion_128
	movups	%xmm0,(%rax)
	movl	%esi,80(%rax)
	xorl	%eax,%eax
	jmp	.Lenc_key_ret

.align	4
.L12rounds:
	movq	16(%rdi),%xmm2
	movl	$11,%esi
	movups	%xmm0,(%rdx)
.byte	102,15,58,223,202,1
	call	.Lkey_expansion_192a_cold
.byte	102,15,58,223,202,2
	call	.Lkey_expansion_192b
.byte	102,15,58,223,202,4
	call	.Lkey_expansion_192a
.byte	102,15,58,223,202,8
	call	.Lkey_expansion_192b
.byte	102,15,58,223,202,16
	call	.Lkey_expansion_192a
.byte	102,15,58,223,202,32
	call	.Lkey_expansion_192b
.byte	102,15,58,223,202,64
	call	.Lkey_expansion_192a
.byte	102,15,58,223,202,128
	call	.Lkey_expansion_192b
	movups	%xmm0,(%rax)
	movl	%esi,48(%rax)
	xorq	%rax,%rax
	jmp	.Lenc_key_ret

.align	4
.L14rounds:
	movups	16(%rdi),%xmm2
	movl	$13,%esi
	leaq	16(%rax),%rax
	movups	%xmm0,(%rdx)
	movups	%xmm2,16(%rdx)
.byte	102,15,58,223,202,1
	call	.Lkey_expansion_256a_cold
.byte	102,15,58,223,200,1
	call	.Lkey_expansion_256b
.byte	102,15,58,223,202,2
	call	.Lkey_expansion_256a
.byte	102,15,58,223,200,2
	call	.Lkey_expansion_256b
.byte	102,15,58,223,202,4
	call	.Lkey_expansion_256a
.byte	102,15,58,223,200,4
	call	.Lkey_expansion_256b
.byte	102,15,58,223,202,8
	call	.Lkey_expansion_256a
.byte	102,15,58,223,200,8
	call	.Lkey_expansion_256b
.byte	102,15,58,223,202,16
	call	.Lkey_expansion_256a
.byte	102,15,58,223,200,16
	call	.Lkey_expansion_256b
.byte	102,15,58,223,202,32
	call	.Lkey_expansion_256a
.byte	102,15,58,223,200,32
	call	.Lkey_expansion_256b
.byte	102,15,58,223,202,64
	call	.Lkey_expansion_256a
	movups	%xmm0,(%rax)
	movl	%esi,16(%rax)
	xorq	%rax,%rax
	jmp	.Lenc_key_ret

.align	4
.Lbad_keybits:
	movq	$-2,%rax
.Lenc_key_ret:
	addq	$8,%rsp
	.byte	0xf3,0xc3
.LSEH_end_set_encrypt_key:

.align	4
.Lkey_expansion_128:
	movups	%xmm0,(%rax)
	leaq	16(%rax),%rax
.Lkey_expansion_128_cold:
	shufps	$16,%xmm0,%xmm4
	xorps	%xmm4,%xmm0
	shufps	$140,%xmm0,%xmm4
	xorps	%xmm4,%xmm0
	shufps	$255,%xmm1,%xmm1
	xorps	%xmm1,%xmm0
	.byte	0xf3,0xc3

.align	4
.Lkey_expansion_192a:
	movups	%xmm0,(%rax)
	leaq	16(%rax),%rax
.Lkey_expansion_192a_cold:
	movaps	%xmm2,%xmm5
.Lkey_expansion_192b_warm:
	shufps	$16,%xmm0,%xmm4
	movdqa	%xmm2,%xmm3
	xorps	%xmm4,%xmm0
	shufps	$140,%xmm0,%xmm4
	pslldq	$4,%xmm3
	xorps	%xmm4,%xmm0
	pshufd	$85,%xmm1,%xmm1
	pxor	%xmm3,%xmm2
	pxor	%xmm1,%xmm0
	pshufd	$255,%xmm0,%xmm3
	pxor	%xmm3,%xmm2
	.byte	0xf3,0xc3

.align	4
.Lkey_expansion_192b:
	movaps	%xmm0,%xmm3
	shufps	$68,%xmm0,%xmm5
	movups	%xmm5,(%rax)
	shufps	$78,%xmm2,%xmm3
	movups	%xmm3,16(%rax)
	leaq	32(%rax),%rax
	jmp	.Lkey_expansion_192b_warm

.align	4
.Lkey_expansion_256a:
	movups	%xmm2,(%rax)
	leaq	16(%rax),%rax
.Lkey_expansion_256a_cold:
	shufps	$16,%xmm0,%xmm4
	xorps	%xmm4,%xmm0
	shufps	$140,%xmm0,%xmm4
	xorps	%xmm4,%xmm0
	shufps	$255,%xmm1,%xmm1
	xorps	%xmm1,%xmm0
	.byte	0xf3,0xc3

.align	4
.Lkey_expansion_256b:
	movups	%xmm0,(%rax)
	leaq	16(%rax),%rax

	shufps	$16,%xmm2,%xmm4
	xorps	%xmm4,%xmm2
	shufps	$140,%xmm2,%xmm4
	xorps	%xmm4,%xmm2
	shufps	$170,%xmm1,%xmm1
	xorps	%xmm1,%xmm2
	.byte	0xf3,0xc3


