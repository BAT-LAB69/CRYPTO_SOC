`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 07:42:10 PM
// Design Name: 
// Module Name: decryptRound
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


module decryptRound(
input  [127:0] in,
    input  [127:0] key,
    output [127:0] out
);
    wire [127:0] afterShiftRows;
    wire [127:0] afterSubBytes;
    wire [127:0] afterAddRoundKey;

  
    shiftrow_inver sr_inv (in, afterShiftRows);
    inverseSubBytes sb_inv (afterShiftRows, afterSubBytes);
    addroundkey add_k (afterSubBytes, key, afterAddRoundKey);
    inv_mixcol mc_inv (afterAddRoundKey, out);
    
endmodule
