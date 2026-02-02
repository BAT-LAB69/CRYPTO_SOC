`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2026 10:02:16 PM
// Design Name: 
// Module Name: AES _ENCRYPT
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


module AES _ENCRYPT(
input  [127:0] in,
    input  [127:0] key,
    output [127:0] out
);

    // ====================================================
    // 1) Round keys
    // ====================================================
    wire [1407:0] roundKeys;   // 11 × 128 bit
    keyExpansion128 ke (
        .key(key),
        .roundKeys(roundKeys)
    );

    // ====================================================
    // 2) State array
    // ====================================================
    wire [127:0] state [0:10];

    // ====================================================
    // 3) Initial AddRoundKey (Round 0)
    // ====================================================
    addRoundKey ark0 (
        .in (in),
        .out(state[0]),
        .key(roundKeys[1407 -: 128]) // K0
    );

    // ====================================================
    // 4) Rounds 1 → 9
    // ====================================================
    genvar r;
    generate
        for (r = 1; r < 10; r = r + 1) begin : rounds
            encryptRound er (
                .in (state[r-1]),
                .key(roundKeys[1407 - 128*r -: 128]), // K1..K9
                .out(state[r])
            );
        end
    endgenerate

    // ====================================================
    // 5) Final round (Round 10)
    // ====================================================
    wire [127:0] sb_out, sr_out;

    subBytes  sb (state[9], sb_out);
    shiftRows sr (sb_out, sr_out);

    addRoundKey ark10 (
        .in (sr_out),
        .out(state[10]),
        .key(roundKeys[127:0]) // K10
    );

    // ====================================================
    // 6) Output
    // ====================================================
    assign out = state[10];
endmodule
