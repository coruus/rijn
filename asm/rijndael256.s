[cpu intelnop]
[bits 64]

align 32
section .data

_Rijndael_b32_shuffle_mask:
dd 0x03020d0c, 0x0f0e0908, 0x0b0a0504, 0x07060100

_Rijndael_b32_blend_mask:
  db 0, 0xff, 0xff, 0xff
  db 0,    0, 0xff, 0xff
  db 0,    0, 0xff, 0xff
  db 0,    0,    0, 0xff

%define rijndael256_mask  [rel _Rijndael_b32_shuffle_mask]
%define sel2 [ rel _Rijndael_b32_blend_mask]
%define ks(x) [rdi+(x*16)]
%define in(x) [rdx+(x*16)]
%define out(x) [rsi+(x*16)]

%macro blockblend 0
  vpxor temp1, data1, data2    ; temp1 = data1 ^ data2
  vpand temp1, temp1, sel2     ; temp1 &= mask
  vpxor data1, data1, temp1    ; data1 ^= temp1
  vpxor data2, data2, temp1    ; data2 ^= temp1

  ; Rotate column 2 of each half of the state.
  vpshufb   data2, data2, rijndael256_mask
  vpshufb   data1, data1, rijndael256_mask
%endmacro


%define data1 xmm4
%define data2 xmm5
%define temp1 xmm6
%define temp2 xmm7

align 32
section .text

global Rijndael_b32_ecb
Rijndael_b32_ecb

  vmovdqu data1, in(0)
  vmovdqu data2, in(1)

  vpxor data1, data1, ks(0)
  vpxor data2, data2, ks(1)

  align 16
  mov r8, 13
  .rounds:
    blockblend
    vaesenc temp1, temp1, ks(0)
    vaesenc temp2, temp2, ks(1)
    add rdi, 32
    dec r8
    jnz .rounds
  blockblend
  vaesenclast temp1, temp1, ks(0)
  vaesenclast temp2, temp2, ks(1)

  vmovdqu out(0), temp1
  vmovdqu out(1), temp2
