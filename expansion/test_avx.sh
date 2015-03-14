#!/usr/bin/env sh
cflags="-std=c11 -Wextra -O3 -march=native -mavx"
#clang -E expand.s | llvm-mc > expanded.s 
yasm -r cpp -e expand.s > expanded.s
yasm -f macho64 intel-nss.s
#yasm -f macho64 -p gas -r gas expanded.s
clang -c expanded.s
clang $cflags mini.c expanded.o libcrypto.a intel-nss.o -o mini.out && 
 sleep 0.5 && 
 ./mini.out && 
 ./mini.out | tail -6
