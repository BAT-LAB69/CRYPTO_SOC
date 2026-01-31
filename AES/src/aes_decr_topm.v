`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 07:38:13 PM
// Design Name: 
// Module Name: aes_decr_topm
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


module aes_decr_topm(

  input  [127:0] in,  // Ciphertext
    input  [127:0] key, // Key
    input  [127:0] iv,  // Initialization Vector
    output [127:0] out  // Plaintext
);
    wire [127:0] core_out;

    // Gọi AES Core (File mới tạo ở Bước 2)
    aes_decr_top uut (
        .rst(1'b0),
        .in (in),
        .key(key),
        .out(core_out)
    );

    // XOR với IV (CBC Mode)
    assign out = core_out ^ iv;
endmodule
