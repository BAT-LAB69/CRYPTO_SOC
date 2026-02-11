import numpy as np

# =========================
# Parameters
# =========================
R = 5
W = 3
MAX_IT = 1
THRESHOLD = 2

# =========================
# Rotate left in GF(2)
# =========================
def rotl(x, s):
    return np.roll(x, s)

# =========================
# Build syndrome: s = H0*e0 + H1*e1
# =========================
def build_syndrome(e0, e1, h0_pos, h1_pos):
    s = np.zeros(R, dtype=np.uint8)
    for i in range(W):
        s ^= rotl(e0, h0_pos[i])
        s ^= rotl(e1, h1_pos[i])
    return s

# =========================
# Bit-Flipping Decoder
# =========================
def bit_flipping_decode(s_in, h0_pos, h1_pos):
    syndrome = s_in.copy()
    e0 = np.zeros(R, dtype=np.uint8)
    e1 = np.zeros(R, dtype=np.uint8)

    for iteration in range(MAX_IT):
        flipped = False

        for i in range(R):
            print("i:", i, "synd:", syndrome, "e0:",e0, "e1:", e1)

            # -------- Vote e0[i] --------
            vote0 = 0
            for k in range(W):
                idx = (i + h0_pos[k]) % R
                vote0 += syndrome[idx]
                print("idx:", idx, "k:", k, "pos:", h0_pos[k])

            # -------- Vote e1[i] --------
            vote1 = 0
            for k in range(W):
                idx = (i + h1_pos[k]) % R
                vote1 += syndrome[idx]

            # -------- Flip if needed --------
            if vote0 >= THRESHOLD:
                e0[i] ^= 1
                for k in range(W):
                    idx = (i + h0_pos[k]) % R
                    syndrome[idx] ^= 1
                    print("idx:", idx, "k:", k)
                flipped = True

            if vote1 >= THRESHOLD:
                e1[i] ^= 1
                for k in range(W):
                    idx = (i + h1_pos[k]) % R
                    syndrome[idx] ^= 1
                flipped = True

        # Stop early if solved
        if np.sum(syndrome) == 0:
            return e0, e1, True

        if not flipped:
            break

    return e0, e1, False



h0_pos = [4, 1, 0]
h1_pos = [3, 2, 1] 

# Example: single-bit error in e0
e0_ref = np.zeros(R, dtype=np.uint8)
e1_ref = np.zeros(R, dtype=np.uint8)

#e0_ref[5] = 1

#s = build_syndrome(e0_ref, e1_ref, h0_pos, h1_pos)
s = [1, 0, 1, 1, 0] 


e0_dec, e1_dec, success = bit_flipping_decode(s[::-1], h0_pos[::-1], h1_pos[::-1])

#print("Success:", success)
print("Decoded e0:", e0_dec[::-1])
print("Decoded e1:", e1_dec[::-1])
# print("Match e0:", np.array_equal(e0_dec, e0_ref))
# print("Match e1:", np.array_equal(e1_dec, e1_ref))
