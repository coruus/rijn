; Rijndael with 256-bit blocksize and 256-bit keylength.
; 
; Implementor: David Leon Gil
; Inspired by:
;   Shay Gueron and Vlad Krasnov
;   Andy Poylakov
; License: CC0, attribution kindly requested.
;
; An up-to-date version will be maintained at:
;   https://github.com/coruus/rijndael-aesni
;
; Notes:
;   No secret data ever flows into a GPR; but memory locations
;   of secret data are not cleaned from GPRs. If this is a
;   concern, you should modify this code to zeroize those
;   registers.
;
[CPU intelnop]
[bits 64]

section .data

align 32


one:   dq 0, 1, 0, 0
two:   dq 0, 2, 0, 0
three: dq 0, 3, 0, 0
four:  dq 0, 4, 0, 0
five:  dq 0, 5, 0, 0
six:   dq 0, 6, 0, 0

section .text

; Calling convention.
%define arg1 rdi
%define arg2 rsi
%define arg3 rdx

; Registers used for the encryption state.
%define x0 xmm7
%define x1 xmm8
%define x2 xmm9
%define x3 xmm10
%define x4 xmm11
%define x5 xmm12
%define x6 xmm13
%define x7 xmm14
%define x8 xmm15

%define ks1 xmm0

%macro k32b16_roundx 3
  %define data1 %2
  %define data2 %3

  vaesenc   data2, data2, ks1
  vaesenc   data1, data1, ks1
%endmacro

; Macro to do the last round of AES256.
%macro k32b16_lastx 3
  %define outo (%1*32)
  %define data1 %2
  %define data2 %3

  vaesenclast data2, data2, ks1
  vaesenclast data1, data1, ks1

  movdqu [out+outo+16], data2
  movdqu [out+outo], data1
%endmacro

; Do 8 independent rouds of AES256.
%macro _k32b16_roundx8 1
  vmovdqu ks1, [ks]
  k32b16_roundx %1, x0, x1
  k32b16_roundx %1, x2, x3
  k32b16_roundx %1, x4, x5
  k32b16_roundx %1, x6, x7
%endmacro

; Rijndael_k32b16_encrypt_x8(
;     void* restrict ks,    // rdi
;     void* dst,            // rsi
;     const void* src       // rdx
; ): Encrypt 4 blocks.
align 32
global Rijndael_k32b16_encrypt_x8
Rijndael_k32b16_encrypt_x8:
  %define arg1 rdi
  %define arg2 rsi
  %define arg3 rdx
;  %define arg4 rcx
  
  %define ks  arg1
  %define out arg2  
  %define in  arg3
;  %define nblocks arg4
  ; Zero all vector unit registers.
  vzeroall

  mov r10, ks
  mov r11, out

;  align 16
;  ._start
  ; Load ks[0:8]
  vmovdqu ks1, [ks]        ; ks1 = ks[0:4]
  
  ; Round 0, xor with key:
  ;   x[0:4] ^= ks[0:4]
  ;   x[4:8] ^= ks[4:8]
  vpxor x0, ks1, [in+0]
  vpxor x1, ks1, [in+16]
  vpxor x2, ks1, [in+32]
  vpxor x3, ks1, [in+48]
  vpxor x4, ks1, [in+64]
  vpxor x5, ks1, [in+80]
  vpxor x6, ks1, [in+96]
  vpxor x7, ks1, [in+112]

  ; Loop to do rounds 1-13.
  mov r8, 1            ; r_i = 1
  mov ks, r10          ; ks_i = ks_start
  align 16
  ._rounds:
    add ks, 16         ; ks_i += 16       ; Advance scheduled keys.
    _k32b16_roundx8 0  ;                  ; Do the round.
    inc r8             ; i += 1           ; Increment the round counter.
    cmp r8, 14         ; if (i != 14)     ; And repeat, until we've gotten
    jne ._rounds       ;   goto ._rounds  ; to the 14th round.

  ; Do round 14, and store the encrypted blocks.
  k32b16_lastx  0, x0, x1
  k32b16_lastx  1, x2, x3
  k32b16_lastx  2, x4, x5
  k32b16_lastx  3, x6, x7

;  add out, 32*4
;  add in,  32*4
;  sub len, 32*4
;  jnz ._start

  ; Zero all registers.
  vzeroall

  ret


; Rijndael_k32b32_encrypt_x1(
;     void* restrict ks,    // rdi
;     void* dst,            // rsi
;     const void* src       // rdx
; ): Encrypt 1 block.
align 32
global Rijndael_k32b16_encrypt_x1
Rijndael_k32b16_encrypt_x1:

  
  %define ks  arg1
  %define out arg3  
  %define in  arg2
  vzeroall

  mov r10, ks
  mov r11, out
  mov rcx, 32*4

  %define ks1 xmm1
  %define ks2 xmm0

  ; Load ks[0:8]
  vmovdqu ks1, [ks]        ; ks1 = ks[0:4]
  vmovdqu ks2, [ks+16]     ; ks2 = ks[4:8]
  
  ; Round 0, xor with key:
  ;   x[0:4] ^= ks[0:4]
  ;   x[4:8] ^= ks[4:8]
  vpxor x0, ks1, [in+0]
  vpxor x1, ks2, [in+16]

  ; Loop to do rounds 1-13.
  mov r8, 1            ; r_i = 1
  mov ks, r10          ; ks_i = ks_start
  align 16
  ._rounds:
    add ks, 32         ; ks_i += 32       ; Advance scheduled keys.
    k32b16_roundx 0, x0, x1               ; Do the round.
    inc r8             ; i += 1           ; Increment the round counter.
    cmp r8, 14         ; if (i != 14)     ; And repeat, until we've gotten
    jne ._rounds       ;   goto ._rounds  ; to the 14th round.

  ; Do round 14, and store the encrypted blocks.
  k32b16_lastx  0, x0, x1

  vzeroall
  ret
