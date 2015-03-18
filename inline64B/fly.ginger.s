/*% py:
loopi = '%rax'

/*

/*% for N in range(1, 9) */

L_otf`N`:
/*% for i in range(0, 7) */
  vaesenc `key1`, `x[i]`, `x[i]`
/*% endfor */
  linearmix `key2`, `t0`
/*% for i in range(0, 7) */
  vaesenc `key2`, `x[i]`, `x[i]`
/*% endfor */
  mov $5, `loopi`
  .align 4


     x[i]=vaesenc   (x[i], key1)  | i in 0..N-1
(key2,t0)=linearmix (key2)
     x[i]=vaesenc   (x[i], key2)  | i in 0..N-1
      rcx=imm8      5
     


