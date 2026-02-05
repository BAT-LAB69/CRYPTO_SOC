`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 07:36:06 PM
// Design Name: 
// Module Name: aes_decr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module aes_decr(
input wire rst, // Giữ cho đồng bộ với aes_encr
    input  [127:0] in,
    input  [127:0] key,
    output [127:0] out
);
    // 1. Sinh khóa (Key Expansion)
    wire [1407:0] roundKeys;
    keyexpan ke (.key(key), .roundKeys(roundKeys));

    // 2. Mảng lưu trạng thái
    wire [127:0] state [0:10];

    // =================================================
    // ROUND 0: Initial Round (Chỉ AddRoundKey K10)
    // =================================================
    addroundkey ark_init (
        .data(in),
        .key (roundKeys[127:0]), // Key 10 (Cuối cùng)
        .out (state[0])
    );

    // =================================================
    // ROUND 1 -> 9: Main Rounds (Dùng decryptRound)
    // =================================================
    genvar i;
    generate
        for (i = 1; i < 10; i = i + 1) begin : LOOP
            // Key chạy ngược: K9, K8... K1
            decryptRound dr (
                .in (state[i-1]),
                .key(roundKeys[128*i +: 128]), 
                .out(state[i])
            );
        end
    endgenerate

    // =================================================
    // ROUND 10: Final Round (InvShift -> InvSub -> Add K0)
    // =================================================
    wire [127:0] sr_out, sb_out;
    
    shiftrow_inver sr_last (state[9], sr_out);
    inverseSubBytes sb_last (sr_out, sb_out);
    
    addroundkey ark_last (
        .data(sb_out),
        .key (roundKeys[1407 -: 128]), // Key 0 (Đầu tiên)
        .out (state[10])
    );

    assign out = state[10];
endmodule
