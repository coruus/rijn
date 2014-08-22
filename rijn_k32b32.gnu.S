.data

.align 7
__shuf:
  .byte 0x0, 0x1, 0x6, 0x7
  .byte 0x4, 0x5, 0xa, 0xb
  .byte 0x8, 0x9, 0xe, 0xf
  .byte 0xc, 0xd, 0x2, 0x3
//  .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__mask:
  .byte 0, 0xff, 0xff, 0xff
  .byte 0,    0, 0xff, 0xff
  .byte 0,    0, 0xff, 0xff
  .byte 0,    0,    0, 0xff
//  .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__one: /*  .byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0*/
        .byte 0,0,0,0,0,0,0,0
        .byte 1,0,0,0,0,0,0,0
__two: /*  .byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0*/
        .byte 0,0,0,0,0,0,0,0
        .byte 2,0,0,0,0,0,0,0
__three: /*.byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0*/
        .byte 0,0,0,0,0,0,0,0
        .byte 3,0,0,0,0,0,0,0
__four: /* .byte 0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0*/
        .byte 0,0,0,0,0,0,0,0
        .byte 4,0,0,0,0,0,0,0

.align 5
.text

.global _Rijndael_k32b32_ctr
_Rijndael_k32b32_ctr:
  vzeroall
  mov    %rdi,%r10
  mov    %rsi,%r11
  .align 4
  _Rijndael_k32b32_ctr._start:
    vmovdqu 0x00(%rdi),    %xmm1
    vmovdqu 0x10(%rdi),    %xmm0
    vmovdqu 0x00(%rdx),    %xmm4
    vmovdqu 0x10(%rdx),    %xmm2
    vpxor   %xmm1, %xmm4,  %xmm4
    vmovdqa %xmm2,         %xmm5
    vpaddq  __one  (%rip), %xmm2, %xmm7
    vpaddq  __two  (%rip), %xmm2, %xmm9
    vpaddq  __three(%rip), %xmm2, %xmm11
    vmovdqa %xmm4,         %xmm6
    vmovdqa %xmm4,         %xmm8
    vmovdqa %xmm4,         %xmm10
    vpxor   %xmm0, %xmm5,  %xmm5
    vpxor   %xmm0, %xmm7,  %xmm7
    vpxor   %xmm0, %xmm9,  %xmm9
    vpxor   %xmm0, %xmm11, %xmm11
    vpaddq  __four(%rip),  %xmm2, %xmm2
    vmovdqu %xmm2,         0x10(%rdx)

    mov    $0x1, %r8
    mov    %r10, %rdi
    .align 4
    _Rijndael_k32b32_ctr._rounds:
      add      $0x20, %rdi                 // ks += 32
      vpxor    %xmm5,        %xmm4,       %xmm0
      vpand    __mask(%rip), %xmm0,       %xmm0
      vpxor    %xmm0,        %xmm4,       %xmm4
      vpxor    %xmm0,        %xmm5,       %xmm5
      vpshufb  __shuf(%rip), %xmm5,       %xmm5
      vpshufb  __shuf(%rip), %xmm4,       %xmm4
      vaesenc  0x10(%rdi),   %xmm5,       %xmm5
      vaesenc  0x00(%rdi),   %xmm4,       %xmm4
      vpxor    %xmm7,        %xmm6,       %xmm0
      vpand    __mask(%rip), %xmm0,       %xmm0
      vpxor    %xmm0,        %xmm6,       %xmm6
      vpxor    %xmm0,        %xmm7,       %xmm7
      vpshufb  __shuf(%rip), %xmm7,       %xmm7
      vpshufb  __shuf(%rip), %xmm6,       %xmm6
      vaesenc  0x10(%rdi),   %xmm7,       %xmm7
      vaesenc  (%rdi),       %xmm6,       %xmm6
      vpxor    %xmm9,        %xmm8,       %xmm0
      vpand    __mask(%rip), %xmm0,       %xmm0
      vpxor    %xmm0,        %xmm8,       %xmm8
      vpxor    %xmm0,        %xmm9,       %xmm9
      vpshufb  __shuf(%rip), %xmm9,       %xmm9
      vpshufb  __shuf(%rip), %xmm8,       %xmm8
      vaesenc  0x10(%rdi),   %xmm9,       %xmm9
      vaesenc  (%rdi),       %xmm8,       %xmm8
      vpxor    %xmm11,       %xmm10,      %xmm0
      vpand    __mask(%rip), %xmm0,       %xmm0
      vpxor    %xmm0,        %xmm10,      %xmm10
      vpxor    %xmm0,        %xmm11,      %xmm11
      vpshufb  __shuf(%rip),%xmm11,%xmm11
      vpshufb  __shuf(%rip),%xmm10,%xmm10
      vaesenc  0x10(%rdi),%xmm11,%xmm11
      vaesenc  (%rdi),%xmm10,%xmm10
    inc    %r8
    cmp    $0xe,%r8
    jne    _Rijndael_k32b32_ctr._rounds

    vpxor  %xmm5,%xmm4,%xmm0
    vpand __mask(%rip),%xmm0,%xmm0
    vpxor  %xmm0,%xmm4,%xmm4
    vpxor  %xmm0,%xmm5,%xmm5
    vpshufb __shuf(%rip),%xmm5,%xmm5
    vpshufb __shuf(%rip),%xmm4,%xmm4
    vaesenclast 0x1d0(%r10),%xmm5,%xmm5
    vaesenclast 0x1c0(%r10),%xmm4,%xmm4
    vpxor  0x10(%rsi),%xmm5,%xmm5
    vpxor  (%rsi),%xmm4,%xmm4
    vmovdqu %xmm5,0x10(%rsi)
    vmovdqu %xmm4,(%rsi)
    vpxor  %xmm7,%xmm6,%xmm0
    vpand __mask(%rip),%xmm0,%xmm0
    vpxor  %xmm0,%xmm6,%xmm6
    vpxor  %xmm0,%xmm7,%xmm7
    vpshufb __shuf(%rip),%xmm7,%xmm7
    vpshufb __shuf(%rip),%xmm6,%xmm6
    vaesenclast 0x1d0(%r10),%xmm7,%xmm7
    vaesenclast 0x1c0(%r10),%xmm6,%xmm6
    vpxor  0x30(%rsi),%xmm7,%xmm7
    vpxor  0x20(%rsi),%xmm6,%xmm6
    vmovdqu %xmm7,0x30(%rsi)
    vmovdqu %xmm6,0x20(%rsi)
    vpxor  %xmm9,%xmm8,%xmm0
    vpand __mask(%rip),%xmm0,%xmm0
    vpxor  %xmm0,%xmm8,%xmm8
    vpxor  %xmm0,%xmm9,%xmm9
    vpshufb __shuf(%rip),%xmm9,%xmm9
    vpshufb __shuf(%rip),%xmm8,%xmm8
    vaesenclast 0x1d0(%r10),%xmm9,%xmm9
    vaesenclast 0x1c0(%r10),%xmm8,%xmm8
    vpxor       0x50(%rsi),%xmm9,%xmm9
    vpxor       0x40(%rsi),%xmm8,%xmm8
    vmovdqu     %xmm9,0x50(%rsi)
    vmovdqu %xmm8,0x40(%rsi)
    vpxor  %xmm11,%xmm10,%xmm0
    vpand __mask(%rip),%xmm0,%xmm0
    vpxor  %xmm0,%xmm10,%xmm10
    vpxor  %xmm0,%xmm11,%xmm11
    vpshufb __shuf(%rip),%xmm11,%xmm11
    vpshufb __shuf(%rip),%xmm10,%xmm10
    vaesenclast 0x1d0(%r10),%xmm11,%xmm11
    vaesenclast 0x1c0(%r10),%xmm10,%xmm10
    vpxor  0x70(%rsi),%xmm11,%xmm11
    vpxor  0x60(%rsi),%xmm10,%xmm10
    vmovdqu %xmm11,0x70(%rsi)
    vmovdqu %xmm10,0x60(%rsi)

  add    $0x80,%rsi
  sub    $0x1,%rcx
  jne    _Rijndael_k32b32_ctr._start
  vzeroall
  retq
