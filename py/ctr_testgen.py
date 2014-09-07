"""Generate a Rijndael256-CTR testcase."""
from __future__ import division, print_function

from rijndael import Rijndael

import struct
from binascii import hexlify
import sys

QQQQ = struct.Struct('<QQQQ').pack

def ctr_test(n):
  k32 = [0x01, 0x11, 0x02, 0x22, 0x03, 0x33, 0x04, 0x44,
         0x55, 0x05, 0x66, 0x06, 0x77, 0x07, 0x88, 0x08,
         0x09, 0x99, 0x0a, 0xaa, 0x0b, 0xbb, 0x0c, 0xcc,
         0xdd, 0x0d, 0xee, 0x0e, 0xff, 0x0f, 0xf1, 0x1f]
  r = Rijndael(bytes(bytearray(k32)), blocklen=32)
  b = ''
  blocks = (n + 31) // 32
  for i in range(blocks):
    p = QQQQ(0, 0, 0, i)
    c = r.encrypt(p)
    b += hexlify(c)
  b = b[:n*2]
  s = ''
  for i in range(0, len(b), 32):
    if i != 0 and (i % 64) == 0:
      s += ' \n'
    elif i != 0 and (i % 32) == 0:
      s += ' '
    s += b[i:i+32]
  return s

if __name__ == '__main__':
  print(ctr_test(int(sys.argv[1])))
