package main

import (
	"encoding/binary"
	"encoding/hex"
	"fmt"

	"github.com/agl/pond/panda/rijndael"
)

func ctr(n []byte, c uint64) (nc [32]byte) {
	copy(nc[0:24], n[0:24])
	binary.LittleEndian.PutUint64(nc[16:], c)
	return
}

func main() {
	var k [32]byte
	for i := 0; i < 32; i++ {
		k[i] = 0 // byte(i)
	}
	var n [32]byte
	for i := 0; i < 24; i++ {
		n[i] = 0 // byte((255 - i))
	}
	fmt.Printf("k = %v\nn = %v\nE = ", hex.EncodeToString(k[:]), hex.EncodeToString(n[:]))
	c := rijndael.NewCipher(&k)

	var ks [32]byte
	for i := 0; i < 1; i++ {
		//nc := ctr(n, uint64(i))
		c.Encrypt(&ks, &n)
		fmt.Printf("%v", hex.EncodeToString(ks[:]))
	}
	fmt.Printf("\n")
}
