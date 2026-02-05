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
<<<<<<< HEAD
    output wire [127:0] out // Ciphertext 
);
    wire [127:0] xor_result;

    
    assign xor_result = in ^ iv;

   
=======
    output wire [127:0] out // Ciphertext (Kết quả sau mã hóa)
);
    wire [127:0] xor_result;

    // Bước 1 của CBC: XOR Plaintext với IV trước khi mã hóa
    assign xor_result = in ^ iv;

    // Bước 2 của CBC: Đưa kết quả XOR vào lõi mã hóa AES
>>>>>>> 3f11f30cd54255b1977f697f4b03ac3b119f622c
    aes_encr aes_core (
        .rst(1'b0),
        .in(xor_result), // Input bây giờ là kết quả XOR
        .key(key),
        .out(out)        // Output này chính là Ciphertext chuẩn CBC
    );

<<<<<<< HEAD
  
=======
    // Lưu ý: Nếu bạn mã hóa khối tiếp theo, 
    // IV của khối sau chính là Ciphertext (out) của khối trước.
>>>>>>> 3f11f30cd54255b1977f697f4b03ac3b119f622c
endmodule
