; LICENSE:
; This submission to NSS is to be made available under the terms of the
; Mozilla Public License, v. 2.0. You can obtain one at http:
; //mozilla.org/MPL/2.0/.
;###############################################################################
; Copyright(c) 2014, Intel Corp.
; Developers and authors:
; Shay Gueron and Vlad Krasnov
; Intel Corporation, Israel Development Centre, Haifa, Israel
; Please send feedback directly to crypto.feedback.alias@intel.com

; Converted from the original MASM by David Leon Gil; patches licensed CC0.

[CPU intelnop]
[bits 64]

[section .data]
[align 32]
  mask:    dd  0c0f0e0dh,  0c0f0e0dh,  0c0f0e0dh,  0c0f0e0dh
  mask192: dd 004070605h, 004070605h, 004070605h, 004070605h
  mask256: dd 00c0f0e0dh, 00c0f0e0dh, 00c0f0e0dh, 00c0f0e0dh
  con1:    dd 1,1,1,1
  con2:    dd 1bh,1bh,1bh,1bh

[align 32]
[section .text]
[global _intel_aes_encrypt_init_256]
_intel_aes_encrypt_init_256:
  %define KEY rsi
  %define KS  rdi
  vzeroupper

  vmovdqu  xmm1, [16*0 + KEY]
  vmovdqu  xmm3, [16*1 + KEY]

  vmovdqu  [16*0 + KS], xmm1
  vmovdqu  [16*1 + KS], xmm3

  vmovdqu  xmm0, [con1    wrt rip]
  vmovdqu  xmm5, [mask256 wrt rip]

  pxor    xmm6, xmm6

  %define ITR rcx
  mov ITR, 6

  Lenc_256_ks_loop:
    vpshufb      xmm2, xmm3, xmm5
    vaesenclast  xmm2, xmm2, xmm0
    vpslld   xmm0, xmm0, 1
    vpslldq  xmm4, xmm1, 4
    vpxor    xmm1, xmm1, xmm4
    vpslldq  xmm4, xmm4, 4
    vpxor    xmm1, xmm1, xmm4
    vpslldq  xmm4, xmm4, 4
    vpxor    xmm1, xmm1, xmm4
    vpxor    xmm1, xmm1, xmm2
    vmovdqu  [16*2 + KS], xmm1

    vpshufd  xmm2, xmm1, 0ffh
    vaesenclast  xmm2, xmm2, xmm6
    vpslldq  xmm4, xmm3, 4
    vpxor    xmm3, xmm3, xmm4
    vpslldq  xmm4, xmm4, 4
    vpxor    xmm3, xmm3, xmm4
    vpslldq  xmm4, xmm4, 4
    vpxor    xmm3, xmm3, xmm4
    vpxor    xmm3, xmm3, xmm2
    vmovdqu  [16*3 + KS], xmm3

    ;lea KS, [32 + KS]
    add KS, 32
    dec ITR
    jnz Lenc_256_ks_loop

  vpshufb      xmm2, xmm3, xmm5
  vaesenclast  xmm2, xmm2, xmm0
  vpslldq  xmm4, xmm1, 4
  vpxor    xmm1, xmm4
  vpslldq  xmm4, xmm4, 4
  vpxor    xmm1, xmm4
  vpslldq  xmm4, xmm4, 4
  vpxor    xmm1, xmm1, xmm4
  vpxor    xmm1, xmm1, xmm2
  vmovdqu  [16*2 + KS], xmm1

  vzeroall
  xor KS, KS
  xor KEY, KEY

  ret
