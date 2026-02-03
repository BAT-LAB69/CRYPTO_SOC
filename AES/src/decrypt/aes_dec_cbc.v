`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 07:43:29 PM
// Design Name: 
// Module Name: aes_dec_cbc
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


module aes_dec_cbc(
input  [127:0] in,  // Ciphertext
    input  [127:0] key, // Key
    input  [127:0] iv,  // Initialization Vector
    output [127:0] out  // Plaintext
);
    wire [127:0] core_out;

    // Gọi AES Core (File ở Bước 2)
    // Quan trọng: Phải gọi đúng tên module 'aes_decr'
    aes_decr core_inst (
        .rst(1'b0),
        .in (in),
        .key(key),
        .out(core_out)
    );

    // XOR với IV (Logic của CBC Decryption)
    assign out = core_out ^ iv;
endmodule
