`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2026 10:03:53 PM
// Design Name: 
// Module Name: aes_encr
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


module aes_encr(
 input wire rst,
 input  [127:0] in,
    input  [127:0] key,
    output [127:0] out
);

    // =================================================
    // 1) Sinh round keys (AES-128 → 11 keys)
    // =================================================
    wire [1407:0] roundKeys;
  

    keyexpan ke (
        .key(key),
        .roundKeys(roundKeys)
    );

    // =================================================
    // 2) State qua các round
    // =================================================
    wire [127:0] state [0:10];

    // =================================================
    // 3) Initial AddRoundKey (Round 0)
    // =================================================
    addroundkey ark0 (
        .data(in),
        .key (roundKeys[1407 -: 128]), // K0
        .out (state[0])
    );

    // =================================================
    // 4) Round 1 → 9
    // =================================================
    genvar i;
    generate
        for (i = 1; i < 10; i = i + 1) begin : ROUND_LOOP
            encryptRound r (
                .in  (state[i-1]),
                .key (roundKeys[1407 - 128*i -: 128]),
                .out (state[i])
            );
        end
    endgenerate

    // =================================================
    // 5) Final Round (NO MixColumns)
    // =================================================
    wire [127:0] sb_out;
    wire [127:0] sr_out;

    subbyte sb (
        .in (state[9]),
        .out(sb_out)
    );

    shiftrow sr (
        .in (sb_out),
        .out(sr_out)
    );

    addroundkey ark10 (
        .data(sr_out),
        .key (roundKeys[127:0]), // K10
        .out (state[10])
    );

    // =================================================
    // 6) Output
    // =================================================
    assign out = state[10];
endmodule
