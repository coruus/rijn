clang -E inline.s > inline.processed.s &&
clang -c inline.processed.s &&
clang -O3 -march=native -mavx2 -mbmi2 inline_test.c inline.processed.o -o inline_test.out libcrypto.a -fsanitize=address -fsanitize=undefined
./inline_test.out &&
clang -O3 -march=native -mavx2 -mbmi2 inline_test.c inline.processed.o -DTIMEIT -o inline_time.out libcrypto.a 
#./inline_time.out
