`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 02:08:06 AM
// Design Name: 
// Module Name: aes_enc_top
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


module aes_enc_top(
input wire [127:0] in,  // Plaintext
    input wire [127:0] iv,  // Initial Vector
    input wire [127:0] key, // Cipher Key
    output wire [127:0] out // Ciphertext 
);
    wire [127:0] xor_result;

    
    assign xor_result = in ^ iv;

   
    aes_encr aes_core (
        .rst(1'b0),
        .in(xor_result), // Input bây giờ là kết quả XOR
        .key(key),
        .out(out)        // Output này chính là Ciphertext chuẩn CBC
    );

  
endmodule
