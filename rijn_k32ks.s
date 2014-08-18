; Key expansion for Rijndael with 32B keysize.
; 
; Credit to:   Intel's AES-NI whitepaper by Shay Gueron,
;              and Intel's AES-NI library.
; Extended by: David Leon Gil (32B blocksize)
; 
; License: CC0
; 
; TODO: Is it possible to do this faster on Haswell?
; (Likely yes, at least for expanding at least 8 keys at the same time.)
; 
[cpu intelnop]
[bits 64]

section .data
align 32

_Rijndael_k32_shuffle_mask:
;  dd 0ffffffffh
;  dd 03020100h
;  dd 07060504h
;  dd 0B0A0908h
  db 0xff, 0xff, 0xff, 0xff  ; Set the first word to zeros.
  db 0x0, 0x1, 0x2, 0x3      ; And shift left by 32 bits.
  db 0x4, 0x5, 0x6, 0x7
  db 0x8, 0x9, 0xa, 0xb
  dq 0, 0

section .text

%define key1 xmm1
%define key2 xmm3
%define shuffle_mask xmm5

%define arg1 rdi
%define arg2 rsi

%define ks  arg1
%define key arg2

; Helper to compute 8 u32s (32B) of the key
; Preconditions:
;   shuffle_mask: (_Rijndael_k32_shuffle_mask)[xmm]
;   key1:         (key[0:16])[xmm]
;   key2:         (key[16:32])[xmm]
;   ks:           *ks[gpr]
align 32
_Rijndael_k32_expand_one:

  vpshufd xmm2, xmm2, 011111111b

  vpshufb xmm4, key1, shuffle_mask  ; xmm4 = shuf(key1, shuffle_mask)
  vpxor   key1, key1, xmm4          ; key1 ^= xmm4
  vpshufb xmm4, xmm4, shuffle_mask  ; xmm4 = shuf(xmm4, shuffle_mask)
  vpxor   key1, key1, xmm4          ; key1 ^= xmm4
  vpshufb xmm4, xmm4, shuffle_mask  ; xmm4 = shuf(xmm4, shuffle_mask)
  vpxor   key1, key1, xmm4          ; key1 ^= xmm4
  vpxor   key1, key1, xmm2          ; key1 ^= xmm2

  vmovdqu [ks+0 ], key1 
  
  vaeskeygenassist xmm4, key1, 0
  vpshufd xmm2, xmm4, 010101010b

  vpshufb xmm4, key2, shuffle_mask
  vpxor   key2, key2, xmm4
  vpshufb xmm4, xmm4, shuffle_mask
  vpxor   key2, key2, xmm4
  vpshufb xmm4, xmm4, shuffle_mask
  vpxor   key2, key2, xmm4
  vpxor   key2, key2, xmm2

  vmovdqu [ks+16], key2
  add ks, 32

  ret

%macro k32_expand 1
  vaeskeygenassist xmm2, key2, %1
  call _Rijndael_k32_expand_one
%endmacro

%macro loadk32 0
  ; Load a 32B key and save it to the first 32B of the key-schedule.
  vmovdqu key1, [key+0 ]
  vmovdqu key2, [key+16]
  vmovdqu [ks+0 ], key1
  vmovdqu [ks+16], key2
  add ks, 32
%endmacro

align 32
global Rijndael_k32b16_expandkey 
Rijndael_k32b16_expandkey:
  vzeroall

  loadk32

  ; Load the shuffle mask used by key_expansion
  vmovdqa shuffle_mask, [_Rijndael_k32_shuffle_mask wrt rip]

  k32_expand 0x01
  k32_expand 0x02
  k32_expand 0x04
  k32_expand 0x08
  k32_expand 0x10
  k32_expand 0x20
  vaeskeygenassist xmm2, key2, 0x40

  vpshufd xmm2, xmm2, 011111111b

  vpshufb xmm4, key1, shuffle_mask  ; xmm4 = shuf(key1, shuffle_mask)
  vpxor   key1, key1, xmm4          ; key1 ^= xmm4
  vpshufb xmm4, xmm4, shuffle_mask  ; xmm4 = shuf(xmm4, shuffle_mask)
  vpxor   key1, key1, xmm4          ; key1 ^= xmm4
  vpshufb xmm4, xmm4, shuffle_mask  ; xmm4 = shuf(xmm4, shuffle_mask)
  vpxor   key1, key1, xmm4          ; key1 ^= xmm4
  vpxor   key1, key1, xmm2          ; key1 ^= xmm2

  vmovdqu [rdi], key1

  vzeroall
  ret 


align 32
global Rijndael_k32b32_expandkey
Rijndael_k32b32_expandkey:
  vzeroall

  loadk32

  vmovdqa shuffle_mask, [_Rijndael_k32_shuffle_mask wrt rip]

  k32_expand 0x01
  k32_expand 0x02
  k32_expand 0x04
  k32_expand 0x08
  k32_expand 0x10
  k32_expand 0x20
  k32_expand 0x40
  k32_expand 0x80
  k32_expand 0x1b
  k32_expand 0x36
  k32_expand 0x6c
  k32_expand 0xd8
  k32_expand 0xab
  k32_expand 0x4d

  vzeroall
  ret 


; Expand a 32-byte key to a 256-byte key schedule.
align 32
global Rijndael_k32_ks256
Rijndael_k32_ks256:
  vzeroall

  loadk32

  vmovdqa shuffle_mask, [_Rijndael_k32_shuffle_mask wrt rip]

  k32_expand 0x01
  k32_expand 0x02
  k32_expand 0x04
  k32_expand 0x08
  k32_expand 0x10
  k32_expand 0x20
  k32_expand 0x40
  k32_expand 0x80
  k32_expand 0x1b
  k32_expand 0x36
  k32_expand 0x6c
  k32_expand 0xd8
  k32_expand 0xab
  k32_expand 0x4d
  k32_expand 0x9a ; todo verify
;  k32_expand 0x2f ; todo verify

  vzeroall
  ret
