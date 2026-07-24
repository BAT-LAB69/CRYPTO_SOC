import hashlib

def check_shake128(msg: bytes, out_bytes=64):
    shake = hashlib.shake_128()
    shake.update(msg)
    return shake.digest(out_bytes)

def check_shake256(msg: bytes, out_bytes=64):
    shake = hashlib.shake_256()
    shake.update(msg)
    return shake.digest(out_bytes)

# ==============================
# TEST với "abc"
# ==============================

message = b"abc"

out128 = check_shake128(message, 64)  # 64 bytes = 512 bits
out256 = check_shake256(message, 64)

#print("SHAKE128 (512-bit) =", out128.hex())
print("SHAKE256 (512-bit) =", out256.hex())