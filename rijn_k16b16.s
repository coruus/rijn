[CPU intelnop]
[bits 64]

section .data
align 32
_rijnk16_shuffle_mask:
;dq 0x0c0f0e0d,0x0c0f0e0d,0x0c0f0e0d,0x0c0f0e0d
  db 0xd, 0xe, 0xf, 0xc
  db 0xd, 0xe, 0xf, 0xc
  db 0xd, 0xe, 0xf, 0xc
  db 0xd, 0xe, 0xf, 0xc

align 32
_rijnk16_rcon:
  dq 0x01, 0x01, 0x01, 0x01
  dq 0x02, 0x02, 0x02, 0x02
  dq 0x04, 0x04, 0x04, 0x04
  dq 0x08, 0x08, 0x08, 0x08
  dq 0x10, 0x10, 0x10, 0x10
  dq 0x20, 0x20, 0x20, 0x20
  dq 0x40, 0x40, 0x40, 0x40
  dq 0x80, 0x80, 0x80, 0x80
  dq 0x1b, 0x1b, 0x1b, 0x1b
  dq 0x36, 0x36, 0x36, 0x36


%define shufmask [rel _rijnk16_shuffle_mask]
%define rcon _rijnk16_rcon

section .text

align 32
global Rijndael_k16b16_encrypt_k64b64
Rijndael_k16b16_encrypt_k64b64:
  vzeroall
  %define key rdx
  %define out rdi
  %define in rsi
  %define rconi r10

  vmovdqu xmm0, [key]
  vmovdqu xmm2, [key+16]
  vmovdqu xmm4, [key+32]
  vmovdqu xmm6, [key+48]

  vpxor   xmm12, xmm0, [in+0 ]
  vpxor   xmm13, xmm2, [in+16]
  vpxor   xmm14, xmm4, [in+32]
  vpxor   xmm15, xmm6, [in+48]

  %macro round 5
    %define t1 %1
    %define t3 %2
    %define t2 %3
    %define block %4
    %define i %5
    vpshufb t2, t1, shufmask
    vaesenclast t2, t2, [rcon + i*16 wrt rip]
    
    vpslldq t3, t1, 4
    vpxor   t1, t1, t3
    vpslldq t3, t3, 4
    vpxor   t1, t1, t3
    vpslldq t3, t3, 4
    vpxor   t1, t1, t3
    vpxor   t1, t1, t2
    vaesenc block, block, t1
  %endmacro

  %macro roundx 1
    round xmm0, xmm1, xmm8,  xmm12, %1
    round xmm2, xmm3, xmm9,  xmm13, %1
    round xmm4, xmm5, xmm10, xmm14, %1
    round xmm6, xmm7, xmm11, xmm15, %1  
  %endmacro

  roundx 0
  roundx 1
  roundx 2
  roundx 3
  roundx 4
  roundx 5
  roundx 6
  roundx 7
  roundx 8

  %macro final 5
    %define t1 %1
    %define t3 %2
    %define t2 %3
    %define block %4
    %define i %5
    vpshufb t2, t1, shufmask
    vaesenclast t2, t2, [rcon + i*16 wrt rip]
    
    vpslldq t3, t1, 4
    vpxor   t1, t1, t3
    vpslldq t3, t3, 4
    vpxor   t1, t1, t3
    vpslldq t3, t3, 4
    vpxor   t1, t1, t3
    vpxor   t1, t1, t2
    vaesenclast block, block, t1
  %endmacro

  final xmm0, xmm1, xmm3, xmm12, 9
  final xmm2, xmm3, xmm9, xmm13, 9
  final xmm4, xmm5, xmm10, xmm14, 9
  final xmm6, xmm7, xmm11, xmm15, 9

  vmovdqu [out+0 ], xmm12
  vmovdqu [out+16], xmm13
  vmovdqu [out+32], xmm14
  vmovdqu [out+48], xmm15
  vzeroall
  ret
