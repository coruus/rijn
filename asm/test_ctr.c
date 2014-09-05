#include "rijn-asm.h"

#include <stdint.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

//Rijndael_k32b32_encrypt_ctr
//Rijndael_k32b32_expandkey

void hexprint(uint8_t* b, size_t n) {
  for (size_t i = 0; i < n; i++) {
    printf("%02x", b[i]);
  }
}

int main(void) {
  uint8_t k[32] = {0};
  for (int i = 0; i < 32; i++) {
    k[i] = 0; // (uint8_t)i;
  }
  uint8_t nc[32] = {0};
  for (int i = 0; i < 24; i++) {
    nc[i] = 0; //(uint8_t)(255 - i);
  }
  printf("k = ");
  hexprint(k, 32);
  printf("\nn = ");
  hexprint(nc, 24);
  uint32_t ks[120] = {0};
  Rijndael_k32b32_expandkey(ks, k);
  uint8_t* E = valloc(1024*32);
  if (E == NULL) {
    abort();
  }
  memset(E, 0, 1024*32);
  Rijndael_b32_ecb(ks, E, nc);
//  Rijndael_k32b32_encrypt_x1(ks, E, nc);
//  Rijndael_k32b32_ctr(ks, E, E, nc, 1);
  printf("\nE = ");
  hexprint(E, 32);//1024*32);
  printf("\nnc= ");
  hexprint(nc, 32);
  free(E);
}
