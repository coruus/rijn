.macro enc8 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
    VAESENC   \key, X5, X5
    VAESENC   \key, X6, X6
    VAESENC   \key, X7, X7
.endm

.macro enc7 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
    VAESENC   \key, X5, X5
    VAESENC   \key, X6, X6
.endm

.macro enc6 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
    VAESENC   \key, X5, X5
.endm

.macro enc5 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
    VAESENC   \key, X4, X4
.endm

.macro enc4 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
    VAESENC   \key, X3, X3
.endm

.macro enc3 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
    VAESENC   \key, X2, X2
.endm

.macro enc2 key
    VAESENC   \key, X0, X0
    VAESENC   \key, X1, X1
.endm

.macro last8 key
  VAESENCLAST      \key, X0, X0
  VAESENCLAST      \key, X1, X1
  VAESENCLAST      \key, X2, X2
  VAESENCLAST      \key, X3, X3
  VAESENCLAST      \key, X4, X4
  VAESENCLAST      \key, X5, X5
  VAESENCLAST      \key, X6, X6
  VAESENCLAST      \key, X7, X7
.endm
