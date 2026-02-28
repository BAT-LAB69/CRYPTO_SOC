** AES GCM **

0x000 - 0x004   Control

0x008 - 0x030   Key + Nonce

0x040 - 0x06C   Plaintexts

0x080 - 0x098   AAD

0x100 - 0x14C   Ciphertext + Tag


** ED25519 **

0x000  CTRL    bit0 = start (auto clear)

0x004  STATUS  bit0 = done, bit1 = busy

0x008  SEED[0]
...
0x024  SEED[7]

0x040  MSG[0]
...
0x05C  MSG[7]

0x060  MSG_LEN

0x100  SIG_R[0]
...
0x11C  SIG_R[7]

0x140  SIG_S[0]
...
0x15C  SIG_S[7]

**  BIKE **

0x000  CTRL      bit0 = start (auto clear)

0x004  STATUS    bit0 = done

0x008  H0[0]

0x00C  H0[1]
...
0x014  H0[W-1]

0x020  H1[0]
...
0x02C  H1[W-1]

0x040  C0[0]
...
0x05C  C0[ceil(R/32)-1]

0x080  C1[0]
...
0x09C  C1[ceil(R/32)-1]

0x100  SHARED_KEY[0]
...
0x13C  SHARED_KEY[15]   (512-bit = 16 words)

** RSA **

0x000  CTRL      bit0 = start (auto clear)

0x004  STATUS    bit0 = done

0x008  M

0x00C  E

0x010  N

0x014  N_INV

0x018  R2_MOD_N

0x100  C (result)