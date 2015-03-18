#!/usr/bin/env sh
cflags="-std=c11 -Wextra -O3 -march=native -mavx"
clang -E expand.s | llvm-mc > expanded.s ; 
clang $cflags mini.c expanded.s libcrypto.a -o mini.out && 
 sleep 0.5 && 
 ./mini.out 
 #&& 
 #./mini.out | tail -6
