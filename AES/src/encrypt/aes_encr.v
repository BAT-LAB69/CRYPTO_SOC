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

<<<<<<< HEAD
    
=======
    // =================================================
    // 1) Sinh round keys (AES-128 → 11 keys)
    // =================================================
>>>>>>> 3f11f30cd54255b1977f697f4b03ac3b119f622c
    wire [1407:0] roundKeys;
  

    keyexpan ke (
        .key(key),
        .roundKeys(roundKeys)
    );

<<<<<<< HEAD
  
    wire [127:0] state [0:10];

 
=======
    // =================================================
    // 2) State qua các round
    // =================================================
    wire [127:0] state [0:10];

    // =================================================
    // 3) Initial AddRoundKey (Round 0)
    // =================================================
>>>>>>> 3f11f30cd54255b1977f697f4b03ac3b119f622c
    addroundkey ark0 (
        .data(in),
        .key (roundKeys[1407 -: 128]), // K0
        .out (state[0])
    );

<<<<<<< HEAD
   
=======
    // =================================================
    // 4) Round 1 → 9
    // =================================================
>>>>>>> 3f11f30cd54255b1977f697f4b03ac3b119f622c
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

<<<<<<< HEAD
   
=======
    // =================================================
    // 5) Final Round (NO MixColumns)
    // =================================================
>>>>>>> 3f11f30cd54255b1977f697f4b03ac3b119f622c
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

<<<<<<< HEAD
    
=======
    // =================================================
    // 6) Output
    // =================================================
>>>>>>> 3f11f30cd54255b1977f697f4b03ac3b119f622c
    assign out = state[10];
endmodule
