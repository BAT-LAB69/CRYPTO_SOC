`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 07:01:25 PM
// Design Name: 
// Module Name: aes_decr_top
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


module aes_decr_top(
input  [127:0] in,
    input  [127:0] key,
    output [127:0] out
);
    wire [127:0] afterShiftRows;
    wire [127:0] afterSubBytes;
    wire [127:0] afterAddRoundKey;

    // 1. Dịch hàng ngược (InvShiftRows) [cite: 1]
    shiftrow_inver sr_inv (in, afterShiftRows);

    // 2. Thay thế byte ngược (InvSubBytes) [cite: 1]
    inverseSubBytes sb_inv (afterShiftRows, afterSubBytes);

    // 3. Cộng khóa (AddRoundKey)
    addroundkey add_k (afterSubBytes, key, afterAddRoundKey);

    // 4. Trộn cột ngược (InvMixColumns) [cite: 1]
    inv_mixcol mc_inv (afterAddRoundKey, out);
endmodule
