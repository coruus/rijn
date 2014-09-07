"""Rijndael for all block-sizes and key-lengths.

Original code ported from the Java reference code by Bram Cohen, April 2001,
with the following statement:

  This code is public domain, unless someone makes an intellectual property
  claim against the reference code, in which case it can be made public
  domain by deleting all the comments and renaming all the variables.

From https:////gist.github.com//jeetsukumaran//1291836.

Code edited by David Leon Gil. Patches licensed CC0.
"""
# pylint: disable=C0103
from __future__ import division, print_function

import copy
import unittest

class Rijndael(object):

  """
  A pure Python implementation of rijndael with a decent interface.

  To create an instance:

    r = Rijndael(key, blocklen = 16)

  Preconditions:
    len(key) in [16, 24, 32]
    blocklen in [16, 24, 32]

  To use::

    ciphertext = r.encrypt(plaintext)
    plaintext = r.decrypt(ciphertext)

  If any strings are of the wrong length a ValueError is thrown
  """

  @classmethod
  def create(cls):
    """Create class infrastructure."""
    if hasattr(cls, "RIJNDAEL_CREATED"):
      return

    # [keysize][blocklen]
    cls.num_rounds = {16: {16: 10, 24: 12, 32: 14},
                      24: {16: 12, 24: 12, 32: 14},
                      32: {16: 14, 24: 14, 32: 14}}

    cls.shifts = [[[0, 0], [1, 3], [2, 2], [3, 1]],
                  [[0, 0], [1, 5], [2, 4], [3, 3]],
                  [[0, 0], [1, 7], [3, 5], [4, 4]]]

    A = [[1, 1, 1, 1, 1, 0, 0, 0],
         [0, 1, 1, 1, 1, 1, 0, 0],
         [0, 0, 1, 1, 1, 1, 1, 0],
         [0, 0, 0, 1, 1, 1, 1, 1],
         [1, 0, 0, 0, 1, 1, 1, 1],
         [1, 1, 0, 0, 0, 1, 1, 1],
         [1, 1, 1, 0, 0, 0, 1, 1],
         [1, 1, 1, 1, 0, 0, 0, 1]]

    # produce log and alog tables, needed for multiplying in the
    # field GF(2^m) (generator = 3)
    alog = [1]
    for i in xrange(255):
      j = (alog[-1] << 1) ^ alog[-1]
      if j & 0x100 != 0:
        j ^= 0x11B
      alog.append(j)

    log = [0] * 256
    for i in xrange(1, 255):
      log[alog[i]] = i

    # multiply two elements of GF(2^m)
    def mul(a, b):
      """Multiply two elements of GF(2^m)."""
      if a == 0 or b == 0:
        return 0
      return alog[(log[a & 0xFF] + log[b & 0xFF]) % 255]

    # substitution box based on F^{-1}(x)
    box = [[0] * 8 for i in xrange(256)]
    box[1][7] = 1
    for i in xrange(2, 256):
      j = alog[255 - log[i]]
      for t in xrange(8):
        box[i][t] = (j >> (7 - t)) & 0x01

    B = [0, 1, 1, 0, 0, 0, 1, 1]

    # affine transform:  box[i] <- B + A*box[i]
    cox = [[0] * 8 for i in xrange(256)]
    for i in xrange(256):
      for t in xrange(8):
        cox[i][t] = B[t]
        for j in xrange(8):
          cox[i][t] ^= A[t][j] * box[i][j]

    # cls.S-boxes and inverse cls.S-boxes
    cls.S = [0] * 256
    cls.Si = [0] * 256
    for i in xrange(256):
      cls.S[i] = cox[i][0] << 7
      for t in xrange(1, 8):
        cls.S[i] ^= cox[i][t] << (7 - t)
      cls.Si[cls.S[i] & 0xFF] = i

    # T-boxes
    G = [[2, 1, 1, 3],
         [3, 2, 1, 1],
         [1, 3, 2, 1],
         [1, 1, 3, 2]]

    AA = [[0] * 8 for i in xrange(4)]

    for i in xrange(4):
      for j in xrange(4):
        AA[i][j] = G[i][j]
        AA[i][i + 4] = 1

    for i in xrange(4):
      pivot = AA[i][i]
      if pivot == 0:
        t = i + 1
        while AA[t][i] == 0 and t < 4:
          t += 1
          assert t != 4, 'G matrix must be invertible'
          for j in xrange(8):
            AA[i][j], AA[t][j] = AA[t][j], AA[i][j]
          pivot = AA[i][i]
      for j in xrange(8):
        if AA[i][j] != 0:
          AA[i][j] = alog[(255 + log[AA[i][j] & 0xFF]
                           - log[pivot & 0xFF]) % 255]
      for t in xrange(4):
        if i != t:
          for j in xrange(i + 1, 8):
            AA[t][j] ^= mul(AA[i][j], AA[t][i])
          AA[t][i] = 0

    iG = [[0] * 4 for i in xrange(4)]

    for i in xrange(4):
      for j in xrange(4):
        iG[i][j] = AA[i][j + 4]

    def mul4(a, bs):
      if a == 0:
        return 0
      r = 0
      for b in bs:
        r <<= 8
        if b != 0:
          r = r | mul(a, b)
      return r

    cls.T1 = []
    cls.T2 = []
    cls.T3 = []
    cls.T4 = []
    cls.T5 = []
    cls.T6 = []
    cls.T7 = []
    cls.T8 = []
    cls.U1 = []
    cls.U2 = []
    cls.U3 = []
    cls.U4 = []

    for t in xrange(256):
      s = cls.S[t]
      cls.T1.append(mul4(s, G[0]))
      cls.T2.append(mul4(s, G[1]))
      cls.T3.append(mul4(s, G[2]))
      cls.T4.append(mul4(s, G[3]))

      s = cls.Si[t]
      cls.T5.append(mul4(s, iG[0]))
      cls.T6.append(mul4(s, iG[1]))
      cls.T7.append(mul4(s, iG[2]))
      cls.T8.append(mul4(s, iG[3]))

      cls.U1.append(mul4(t, iG[0]))
      cls.U2.append(mul4(t, iG[1]))
      cls.U3.append(mul4(t, iG[2]))
      cls.U4.append(mul4(t, iG[3]))

    # Round constants.
    cls.rcon = [1]
    r = 1
    for t in xrange(1, 30):
      r = mul(2, r)
      cls.rcon.append(r)

    cls.RIJNDAEL_CREATED = True

  def __init__(self, key, blocklen=16):
    """Create instance infrastructure."""
    self.create()

    if blocklen != 16 and blocklen != 24 and blocklen != 32:
      raise ValueError('Invalid block size: ' + str(blocklen))
    if len(key) != 16 and len(key) != 24 and len(key) != 32:
      raise ValueError('Invalid key size: ' + str(len(key)))
    self.keylen = len(key)
    self.blocklen = blocklen

    ROUNDS = Rijndael.num_rounds[len(key)][blocklen]
    BC = blocklen // 4
    # Encryption round keys.
    Ke = [[0] * BC for i in xrange(ROUNDS + 1)]
    # Decryption round keys.
    Kd = [[0] * BC for i in xrange(ROUNDS + 1)]
    ROUND_KEY_COUNT = (ROUNDS + 1) * BC
    KC = len(key) // 4

    # Copy user material bytes into temporary ints
    tk = []
    for i in xrange(0, KC):
      tk.append((ord(key[i * 4]) << 24) | (ord(key[i * 4 + 1]) << 16) |
            (ord(key[i * 4 + 2]) << 8) | ord(key[i * 4 + 3]))

    # Copy values into round key arrays.
    t = 0
    j = 0
    while j < KC and t < ROUND_KEY_COUNT:
      Ke[t // BC][t % BC] = tk[j]
      Kd[ROUNDS - (t // BC)][t % BC] = tk[j]
      j += 1
      t += 1
    tt = 0
    rconpointer = 0
    while t < ROUND_KEY_COUNT:
      # Extrapolate using phi (the round key evolution function)
      tt = tk[KC - 1]
      tk[0] ^= ((Rijndael.S[(tt >> 16) & 0xFF] & 0xFF) << 24 ^
                (Rijndael.S[(tt >>  8) & 0xFF] & 0xFF) << 16 ^
                (Rijndael.S[(tt)       & 0xFF] & 0xFF) <<  8 ^
                (Rijndael.S[(tt >> 24) & 0xFF] & 0xFF)       ^
                (Rijndael.rcon[rconpointer] & 0xFF)    << 24)
      rconpointer += 1
      if KC != 8:
        for i in xrange(1, KC):
          tk[i] ^= tk[i - 1]
      else:
        for i in xrange(1, KC // 2):
          tk[i] ^= tk[i - 1]
        tt = tk[KC // 2 - 1]
        tk[KC // 2] ^= ((Rijndael.S[ tt    & 0xFF] & 0xFF)     ^
                       (Rijndael.S[(tt >>  8) & 0xFF] & 0xFF) <<  8 ^
                       (Rijndael.S[(tt >> 16) & 0xFF] & 0xFF) << 16 ^
                       (Rijndael.S[(tt >> 24) & 0xFF] & 0xFF) << 24)
        for i in xrange(KC // 2 + 1, KC):
          tk[i] ^= tk[i - 1]
      # Copy values into round key arrays.
      j = 0
      while j < KC and t < ROUND_KEY_COUNT:
        Ke[t // BC][t % BC] = tk[j]
        Kd[ROUNDS - (t // BC)][t % BC] = tk[j]
        j += 1
        t += 1
    # Inverse MixColumn where needed.
    for r in xrange(1, ROUNDS):
      for j in xrange(BC):
        tt = Kd[r][j]
        Kd[r][j] = (Rijndael.U1[(tt >> 24) & 0xFF] ^
                    Rijndael.U2[(tt >> 16) & 0xFF] ^
                    Rijndael.U3[(tt >>  8) & 0xFF] ^
                    Rijndael.U4[tt & 0xFF])
    self.Ke = Ke
    self.Kd = Kd


  def encrypt(self, plaintext):
    """Encrypt a block."""
    if len(plaintext) != self.blocklen:
      raise ValueError('wrong block length, expected ' +
               str(self.blocklen) + ' got ' + str(len(plaintext)))
    Ke = self.Ke

    BC = self.blocklen // 4
    ROUNDS = len(Ke) - 1
    if BC == 4:
      Rijndael.SC = 0
    elif BC == 6:
      Rijndael.SC = 1
    else:
      Rijndael.SC = 2
    s1 = Rijndael.shifts[Rijndael.SC][1][0]
    s2 = Rijndael.shifts[Rijndael.SC][2][0]
    s3 = Rijndael.shifts[Rijndael.SC][3][0]
    a = [0] * BC
    # temporary work array
    t = []
    # plaintext to ints + key
    for i in xrange(BC):
      t.append((ord(plaintext[i * 4]) << 24 |
                ord(plaintext[i * 4 + 1]) << 16 |
                ord(plaintext[i * 4 + 2]) << 8 |
                ord(plaintext[i * 4 + 3]))
               ^ Ke[0][i])
    # Apply round transforms.
    for r in xrange(1, ROUNDS):
      for i in xrange(BC):
        a[i] = (Rijndael.T1[(t[i] >> 24) & 0xFF] ^
                Rijndael.T2[(t[(i + s1) % BC] >> 16) & 0xFF] ^
                Rijndael.T3[(t[(i + s2) % BC] >> 8) & 0xFF] ^
                Rijndael.T4[t[(i + s3) % BC] & 0xFF]) ^ Ke[r][i]
      t = copy.copy(a)
    # Last round is special.
    result = []
    for i in xrange(BC):
      tt = Ke[ROUNDS][i]
      result.append(
        (Rijndael.S[(t[i] >> 24) & 0xFF] ^ (tt >> 24)) & 0xFF)
      result.append(
        (Rijndael.S[(t[(i + s1) % BC] >> 16) & 0xFF] ^ (tt >> 16)) & 0xFF)
      result.append(
        (Rijndael.S[(t[(i + s2) % BC] >> 8) & 0xFF] ^ (tt >> 8)) & 0xFF)
      result.append((Rijndael.S[t[(i + s3) % BC] & 0xFF] ^ tt) & 0xFF)
    return bytes(bytearray(result))

  def decrypt(self, ciphertext):
    """Decrypt a block."""
    if len(ciphertext) != self.blocklen:
      raise ValueError('wrong block length, expected {} got {}'
                       .format(self.blocklen, len(ciphertext)))
    Kd = self.Kd

    BC = self.blocklen // 4
    ROUNDS = len(Kd) - 1
    if BC == 4:
      Rijndael.SC = 0
    elif BC == 6:
      Rijndael.SC = 1
    else:
      Rijndael.SC = 2
    s1 = Rijndael.shifts[Rijndael.SC][1][1]
    s2 = Rijndael.shifts[Rijndael.SC][2][1]
    s3 = Rijndael.shifts[Rijndael.SC][3][1]
    a = [0] * BC
    # temporary work array
    t = [0] * BC
    # ciphertext to ints + key
    for i in xrange(BC):
      t[i] = (ord(ciphertext[i * 4  ]) << 24 |
          ord(ciphertext[i * 4 + 1]) << 16 |
          ord(ciphertext[i * 4 + 2]) <<  8 |
          ord(ciphertext[i * 4 + 3])    ) ^ Kd[0][i]
    # apply round transforms
    for r in xrange(1, ROUNDS):
      for i in xrange(BC):
        a[i] = ((Rijndael.T5[(t[ i       ] >> 24) & 0xFF] ^
                 Rijndael.T6[(t[(i + s1) % BC] >> 16) & 0xFF] ^
                 Rijndael.T7[(t[(i + s2) % BC] >>  8) & 0xFF] ^
                 Rijndael.T8[ t[(i + s3) % BC]    & 0xFF]  )
                ^ Kd[r][i])
      t = copy.copy(a)
    # last round is special
    result = []
    for i in xrange(BC):
      tt = Kd[ROUNDS][i]
      result.append((Rijndael.Si[(t[ i       ] >> 24) & 0xFF]
                     ^ (tt >> 24)) & 0xFF)
      result.append((Rijndael.Si[(t[(i + s1) % BC] >> 16) & 0xFF]
                     ^ (tt >> 16)) & 0xFF)
      result.append((Rijndael.Si[(t[(i + s2) % BC] >>  8) & 0xFF]
                     ^ (tt >>  8)) & 0xFF)
      result.append((Rijndael.Si[ t[(i + s3) % BC]    & 0xFF]
                     ^  tt     ) & 0xFF)
    return bytes(bytearray(result))

  def __repr__(self):
    """Return a formatted representation of the class."""
    return ("{}(keylength={}, blocklen={})"
            .format(self.__class__.__name__, self.blocklen, self.keylen))


class TestRijndael(unittest.TestCase):
  """Test the Rijndael class."""

  def test_encdec(self):
    """Basic sanity check."""
    for blocklen in [16, 24, 32]:
      for key_size in [16, 24, 32]:
        b = 'b' * blocklen
        r = Rijndael('a' * key_size, blocklen)
        # f*f^-1 == 1
        self.assertEqual(b, r.decrypt(r.encrypt(b)))
        self.assertEqual(b, r.encrypt(r.decrypt(b)))
        self.assertNotEqual(b, r.encrypt(b))
        self.assertNotEqual(b, r.decrypt(b))

if __name__ == '__main__':
  unittest.main()
