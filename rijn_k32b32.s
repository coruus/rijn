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

_rijndael256_mask:
  db 0x0, 0x1, 0x6, 0x7
  db 0x4, 0x5, 0xa, 0xb
  db 0x8, 0x9, 0xe, 0xf
  db 0xc, 0xd, 0x2, 0x3
  dq 0, 0

_sel2:
  db 0, 0xff, 0xff, 0xff
  db 0,    0, 0xff, 0xff
  db 0,    0, 0xff, 0xff
  db 0,    0,    0, 0xff
  dq 0, 0

_sel1:
  db 0xff, 0,    0,    0
  db 0xff, 0xff, 0,    0
  db 0xff, 0xff, 0,    0
  db 0xff, 0xff, 0xff, 0
  dq 0, 0

;_indexarray:
;  db  0,  1,  2,  3
;  db  4,  5,  6,  7
;  db  8,  9, 10, 11
;  db 12, 13, 14, 15
;
;  db 16, 17, 18, 19
;  db 20, 21, 22, 23
;  db 24, 25, 26, 27
;  db 28, 29, 30, 31

__one:   dq  0, 1
__two:   dq  0, 2
__three: dq  0, 3
__four:  dq  0, 4

%define one   [rel __one]
%define two   [rel __two]
%define three [rel __three]
%define four  [rel __four]


section .text

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

; The two temporary registers needed for bitops
%define temp1 xmm1
%define temp2 xmm3
; The three masks.
%define rijndael256_mask xmm2
%define sel1 xmm4
%define sel2 xmm5
%define xcn  xmm6

%macro blockblend_ 0
  ; Swap bytes between the halves of the state.
  ; Pseudocode:
  ;   data1 = (data1 &  sel1) | (data2 &~ sel1)
  ;   data2 = (data1 &~ sel1) | (data2 &  sel1)
  ; Doing this as a masked merge results in a (very slightly) lower
  ; timing variance. (There are many equivalent ways of doing this;
  ; not all have been tried.)
  vpxor temp1, data1, data2   ; temp1 = data1 ^ data2
  vpand temp2, temp1, sel1    ; temp2 = temp1 & sel1
  vpand temp1, temp1, sel2    ; temp1 = temp1 & sel2
  vpxor data2, data1, temp2   ; data2 = data1 ^ temp2
  vpxor data1, data1, temp1   ; data1 = data1 ^ temp1

  ; Rotate column 2 of each half of the state.
  vpshufb   data2, data2, rijndael256_mask
  vpshufb   data1, data1, rijndael256_mask
%endmacro

%macro blockblend_off 0
%endmacro

%define blockblend blockblend_

; Do a single round; parameter 1 is the offset into the
; key schedule. It should be 0 unless this macro is used
; to unroll the code. (Which is a bad idea.)
%macro k32b32_roundx 3
  %define ks_offset (%1*32)
  %define data1 %2
  %define data2 %3

  blockblend
  vaesenc   data2, data2, [ks + ks_offset+16]
  vaesenc   data1, data1, [ks + ks_offset]
%endmacro

; Macro to do the last round of Rijndael256.
%macro k32b32_lastx 3
  %define outo (%1*32)
  %define data1 %2
  %define data2 %3
  %define kso (14 * 32)

  blockblend

  vaesenclast data2, data2, [r10+kso+16]
  vaesenclast data1, data1, [r10+kso]

  movdqu [out+outo+16], data2
  movdqu [out+outo], data1
%endmacro

; Do 4 independent rouds of Rijndael256.
%macro _k32b32_roundx4 1
  k32b32_roundx %1, x0, x1
  k32b32_roundx %1, x2, x3
  k32b32_roundx %1, x4, x5
  k32b32_roundx %1, x6, x7
%endmacro


; Rijndael_k32b32_encrypt_x4(
;     void* restrict ks,    // rdi
;     void* dst,            // rsi
;     const void* src       // rdx
; ): Encrypt 4 blocks.
align 32
global Rijndael_k32b32_encrypt_x4
Rijndael_k32b32_encrypt_x4:
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

  %define ks1 xmm1
  %define ks2 xmm0

;  align 16
;  ._start
  ; Load ks[0:8]
  vmovdqu ks1, [ks]        ; ks1 = ks[0:4]
  vmovdqu ks2, [ks+16]     ; ks2 = ks[4:8]
  
  ; Round 0, xor with key:
  ;   x[0:4] ^= ks[0:4]
  ;   x[4:8] ^= ks[4:8]
  vpxor x0, ks1, [in+0]
  vpxor x1, ks2, [in+16]
  vpxor x2, ks1, [in+32]
  vpxor x3, ks2, [in+48]
  vpxor x4, ks1, [in+64]
  vpxor x5, ks2, [in+80]
  vpxor x6, ks1, [in+96]
  vpxor x7, ks2, [in+112]

  ; Load the selection and shuffle masks:
  ; (This clobbers round 0's ks1 and ks2.)
  vmovdqa sel1, [_sel1 wrt rip]
  vmovdqa sel2, [_sel2 wrt rip]
  vmovdqa rijndael256_mask, [_rijndael256_mask wrt rip]

  ; Loop to do rounds 1-13.
  mov r8, 1            ; r_i = 1
  mov ks, r10          ; ks_i = ks_start
  align 16
  ._rounds:
    add ks, 32         ; ks_i += 32       ; Advance scheduled keys.
    _k32b32_roundx4 0  ;                  ; Do the round.
    inc r8             ; i += 1           ; Increment the round counter.
    cmp r8, 14         ; if (i != 14)     ; And repeat, until we've gotten
    jne ._rounds       ;   goto ._rounds  ; to the 14th round.

  ; Do round 14, and store the encrypted blocks.
  k32b32_lastx  0, x0, x1
  k32b32_lastx  1, x2, x3
  k32b32_lastx  2, x4, x5
  k32b32_lastx  3, x6, x7

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
global Rijndael_k32b32_encrypt_x1
Rijndael_k32b32_encrypt_x1:
  %define arg1 rdi
  %define arg2 rsi
  %define arg3 rdx
  
  %define ks  arg1
  %define out arg3  
  %define in  arg2
  ; Zero all vector registers. Critical for performance.
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

  ; Load the selection and shuffle masks. (This clobbers round 0's ks1 and ks2.)
  vmovdqa sel1, [_sel1 wrt rip]
  vmovdqa sel2, [_sel2 wrt rip]
  vmovdqa rijndael256_mask, [_rijndael256_mask wrt rip]

  ; Loop to do rounds 1-13.
  mov r8, 1            ; r_i = 1
  mov ks, r10          ; ks_i = ks_start
  align 16
  ._rounds:
    add ks, 32         ; ks_i += 32       ; Advance scheduled keys.
    k32b32_roundx 0, x0, x1               ; Do the round.
    inc r8             ; i += 1           ; Increment the round counter.
    cmp r8, 14         ; if (i != 14)     ; And repeat, until we've gotten
    jne ._rounds       ;   goto ._rounds  ; to the 14th round.

  ; Do round 14, and store the encrypted blocks.
  k32b32_lastx  0, x0, x1

  ; Zero all vector registers.
  vzeroall
  ret


; Rijndael_k32b32_ctr(
;     void* restrict ks,    // rdi
;     void* dst,            // rsi
;     const void* src       // rdx
;     void* nc              // rcx
; ): Encrypt 4 blocks.
align 32
global Rijndael_k32b32_ctr
Rijndael_k32b32_ctr:
  %define arg1 rdi
  %define arg2 rsi
  %define arg3 rdx
  %define arg4 rcx
  
  %define ks  arg1
  %define out arg2  
  %define in  arg3
  %define nc  arg4
  ; Zero all vector unit registers.
  vzeroall

  mov r10, ks
  mov r11, out

  %define ks1 xmm1
  %define ks2 xmm0

;  align 16
;  ._start
  ; Load ks[0:8]
  vmovdqu ks1, [ks]        ; ks1 = ks[0:4]
  vmovdqu ks2, [ks+16]     ; ks2 = ks[4:8]
 
  vmovdqu x0, [nc+0 ]
  vmovdqu x1, [nc+1 ]
  vmovdqa xcn, x1
  
  vmovdqa x2, x0
  vmovdqa x4, x0
  vmovdqa x6, x0

  vpaddq   x3, x1, one
  vpaddq   x5, x1, two
  vpaddq   x7, x1, three
  vpaddq   xcn, x1, four
  vmovdqu  [nc+1], xcn

  ; Round 0, xor with key:
  ;   x[0:4] ^= ks[0:4]
  ;   x[4:8] ^= ks[4:8]
  vpxor x0, ks1, x0
  vpxor x1, ks2, x1
  vpxor x2, ks1, x2 
  vpxor x3, ks2, x3
  vpxor x4, ks1, x4
  vpxor x5, ks2, x5
  vpxor x6, ks1, x6
  vpxor x7, ks2, x7 

  ; Load the selection and shuffle masks:
  ; (This clobbers round 0's ks1 and ks2.)
  vmovdqa sel1, [_sel1 wrt rip]
  vmovdqa sel2, [_sel2 wrt rip]
  vmovdqa rijndael256_mask, [_rijndael256_mask wrt rip]

  ; Loop to do rounds 1-13.
  mov r8, 1            ; r_i = 1
  mov ks, r10          ; ks_i = ks_start
  align 16
  ._rounds:
    add ks, 32         ; ks_i += 32       ; Advance scheduled keys.
    _k32b32_roundx4 0  ;                  ; Do the round.
    inc r8             ; i += 1           ; Increment the round counter.
    cmp r8, 14         ; if (i != 14)     ; And repeat, until we've gotten
    jne ._rounds       ;   goto ._rounds  ; to the 14th round.

  ; Do round 14, and store the encrypted blocks.
  k32b32_lastx  0, x0, x1
  k32b32_lastx  1, x2, x3
  k32b32_lastx  2, x4, x5
  k32b32_lastx  3, x6, x7

;  add out, 32*4
;  add in,  32*4
;  sub len, 32*4
;  jnz ._start

  ; Zero all registers.
  vzeroall

  ret
