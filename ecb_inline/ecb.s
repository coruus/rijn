

.macro BLOCK K
  VAESENC \K, x0, x0
  VAESENC \K, x1, x1
  VAESENC \K, x2, x2
  VAESENC \K, x3, x3
  VAESENC \K, x4, x4
  VAESENC \K, x5, x5
  VAESENC \K, x6, x6
  VAESENC \K, x7, x7
.endmacro


  VMOVDQU  0*16(KS), xK1
  VPXOR    0*16(IN), xK1, x0
  VPXOR    1*16(IN), xK1, x1
  VPXOR    2*16(IN), xK1, x2
  VPXOR    3*16(IN), xK1, x3
  VPXOR    4*16(IN), xK1, x4
  VPXOR    5*16(IN), xK1, x5
  VPXOR    6*16(IN), xK1, x6
  VPXOR    7*16(IN), xK1, x7

  BLOCK 1*16(KS)
  BLOCK 2*16(KS)
  BLOCK 3*16(KS)
  BLOCK 4*16(KS)
  BLOCK 5*16(KS)
  BLOCK 6*16(KS)
  BLOCK 7*16(KS)
  BLOCK 8*16(KS)
  BLOCK 9*16(KS)
  BLOCK 10*16(KS)
  BLOCK 11*16(KS)
  BLOCK 12*16(KS)
  BLOCK 13*16(KS)
  BLOCK 14*16(KS)


