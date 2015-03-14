/* SSSE3: AES-256 key expansion 
 *
 * Implementor: David Leon Gil
 * License:     Apache2 
 * Inspired by: Shay Gueron's classic AES-NI whitepaper.
 * Ack:         Agner Fog's instruction tables.
 */

#define T1   %xmm0
#define T2   %xmm1
#define KEY1 %xmm2
#define KEY2 %xmm3
#define RC   %xmm4

#define KEY  %rsi
#define KS   %rdi

.data
.align 5
__rc:
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 1, 0, 0
  .byte 0, 0, 0, 0
.quad 0, 0

__shuf_1:
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
  .byte 12, 13, 14, 15
.quad 0, 0

# InvShiftColumns
__shuf_2:
  .byte 9, 6, 3, 12
  .byte 9, 6, 3, 12
  .byte 9, 6, 3, 12
  .byte 9, 6, 3, 12
.quad 0, 0

__shuf_l:
  .byte 0xff, 0xff, 0xff, 0xff
  .byte 0x0, 0x1, 0x2, 0x3     
  .byte 0x4, 0x5, 0x6, 0x7
  .byte 0x8, 0x9, 0xa, 0xb


#define SHUF_L __shuf_l(%rip)
#define SHUF_1 __shuf_1(%rip)
#define SHUF_2 __shuf_2(%rip)
#define _RC __rc(%rip)

.macro linearmix key, new
  MOVDQA     \key, T1
  PSLLDQ   $4, T1
  PXOR         T1, \key

  MOVDQA     \key, T1
  PSLLDQ   $4, T1
  PXOR         T1, \key

  MOVDQA     \key, T1
  PSLLDQ   $4, T1
  PXOR         T1, \key

  PXOR      \new, \key
.endm

.text
.L_DR:
//__Rijndael_k8w4_expandkey_doubleround:

  RET

.globl _Rijndael_k8w4_expandkey
_Rijndael_k8w4_expandkey:
  MOVDQU    0(KEY), KEY1
  MOVDQU   16(KEY), KEY2
  // Load the initial value of the round constant
  MOVDQU       _RC, RC
  // Copy k[0:8] to ks[0:8]
  MOVDQU      KEY1,  0(KS)
  MOVDQU      KEY2, 16(KS)
  ADD          $32, KS

  MOV $6, %rax
  Loop_expand:
    MOVDQA        KEY2, T2
    AESENCLAST      RC, T2
    PSHUFB      SHUF_2, T2
    // Shift the round constant, to prepare for the next round
    PSLLD           $1, RC
    
    linearmix KEY1,   T2
    MOVDQU  KEY1,  0(KS)
  
    PXOR           T1, T1
    MOVDQA       KEY1, T2
    PSHUFD     $255, T2, T2
    AESENCLAST     T1, T2
  
    linearmix KEY2,   T2
    MOVDQU    KEY2, 16(KS)
  
    ADDQ $32, KS
    DEC %rax
    JNZ Loop_expand

  AESENCLAST     RC, KEY2
  PSHUFB     SHUF_2, KEY2
  
  linearmix KEY1, KEY2
  MOVDQU    KEY1, 0(KS)
  // Zeroize registers.
  PXOR KEY1, KEY1
  PXOR KEY2, KEY2
  PXOR T1, T1
  PXOR T2, T2
  PXOR RC, RC
  XOR KEY, KEY
  XOR  KS, KS
  RET
