#!/bin/bash
set -e

# Chuyển ra thư mục ngoài để tìm thấy các file module .v
cd ..

echo ""
echo ">>> Running tb_aes_gcm"
iverilog -s tb_aes_gcm -o testbench/aes_sim testbench/tb_aes_gcm.v aes_gcm_top.v aes_encr.v ghash.v sbox.v subbyte.v mixcol.v shiftrow.v keyexpan.v addroundkey.v encryt.v 
vvp testbench/aes_sim

echo ""
echo ">>> Running tb_rsa"
iverilog -s tb_rsa -o testbench/rsa_sim testbench/tb_rsa.v RSA.v 
vvp testbench/rsa_sim

echo ""
echo ">>> Running tb_shake"
iverilog -s tb_shake -o testbench/shake_sim testbench/tb_shake.v shake_top.v sponge.v keccak_f1600.v keccak_round.v
vvp testbench/shake_sim

echo ""
echo ">>> Running tb_bike"
iverilog -s tb_bike -o testbench/bike_sim testbench/tb_bike.v bike_top.v syndrome.v bit_flip_dec.v shake_top.v sponge.v keccak_f1600.v keccak_round.v
vvp testbench/bike_sim

echo ""
echo ">>> Running tb_ed25519"
iverilog -s tb_ed25519 -o testbench/ed_sim testbench/tb_ed25519.v ed25519_shake128.v ed25519_top.v scala_mul_25519.v inv_25519.v point_op_25519.v add_sub_25519.v mul_25519.v arithmetic.v reducer.v shake_top.v sponge.v keccak_f1600.v keccak_round.v
vvp testbench/ed_sim

echo ""
echo ">>> All unit tests finished successfully!"
