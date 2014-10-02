#!/usr/bin/env sh
cflags="-std=c11 -Wextra -O3 -march=native -msse"
clang -E expand_ssse3.s | llvm-mc > expanded_ssse3.s ; 
yasm -f macho64 intel-nss.s &&
clang $cflags mini.c expanded_ssse3.s ossl_expansion.s intel-nss.o -o mini.sse3.out && 
 sleep 0.5 && 
 ./mini.sse3.out && 
 ./mini.sse3.out | tail -6
