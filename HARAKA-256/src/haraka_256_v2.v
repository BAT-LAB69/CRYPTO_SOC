`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2026 11:14:58 PM
// Design Name: 
// Module Name: haraka_256_v2
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


module haraka_256_v2(
input wire [255:0] in,
    output wire [255:0] out
);

    function [127:0] swap_endian; // hàm đảo ngược
        input [127:0] data;
        integer i;
        begin
            for (i = 0; i < 16; i = i + 1) begin
                
                swap_endian[8*i +: 8] = data[128 - 8*(i+1) +: 8];
            end
        end
    endfunction

    
    wire [127:0] rc [0:19];
    
    // Bảng dùng trên paper
    assign rc[0]  = swap_endian(128'h0684704ce620c00ab2c5fef075817b9d);
    assign rc[1]  = swap_endian(128'h8b66b4e188f3a06b640f6ba42f08f717);
    assign rc[2]  = swap_endian(128'h3402de2d53f28498cf029d609f029114);
    assign rc[3]  = swap_endian(128'h0ed6eae62e7b4f08bbf3bcaffd5b4f79);
    assign rc[4]  = swap_endian(128'hcbcfb0cb4872448b79eecd1cbe397044);
    assign rc[5]  = swap_endian(128'h7eeacdee6e9032b78d5335ed2b8a057b);
    assign rc[6]  = swap_endian(128'h67c28f435e2e7cd0e2412761da4fef1b);
    assign rc[7]  = swap_endian(128'h2924d9b0afcacc07675ffde21fc70b3b);
    assign rc[8]  = swap_endian(128'hab4d63f1e6867fe9ecdb8fcab9d465ee);
    assign rc[9]  = swap_endian(128'h1c30bf84d4b7cd645b2a404fad037e33);
    assign rc[10] = swap_endian(128'hb2cc0bb9941723bf69028b2e8df69800);
    assign rc[11] = swap_endian(128'hfa0478a6de6f55724aaa9ec85c9d2d8a);
    assign rc[12] = swap_endian(128'hdfb49f2b6b772a120efa4f2e29129fd4);
    assign rc[13] = swap_endian(128'h1ea10344f449a23632d611aebb6a12ee);
    assign rc[14] = swap_endian(128'haf0449884b0500845f9600c99ca8eca6);
    assign rc[15] = swap_endian(128'h21025ed89d199c4f78a2c7e327e593ec);
    assign rc[16] = swap_endian(128'hbf3aaaf8a759c9b7b9282ecd82d40173);
    assign rc[17] = swap_endian(128'h6260700d6186b01737f2efd910307d6b);
    assign rc[18] = swap_endian(128'h5aca45c22130044381c29153f6fc9ac6);
    assign rc[19] = swap_endian(128'h9223973c226b68bb2caf92e836d1943a);

    
    wire [255:0] s [0:5];
    assign s[0] = in; // Trạng thái ban đầu

    genvar t;
    generate
        for (t = 0; t < 5; t = t + 1) begin : Haraka_Round
            wire [127:0] b0_step1, b1_step1;
            wire [127:0] b0_step2, b1_step2;

           
            
            haraka_aes_step aes0_s1 (.in(s[t][255:128]), .rc(rc[4*t]),     .out(b0_step1));
            haraka_aes_step aes1_s1 (.in(s[t][127:0]),   .rc(rc[4*t + 1]), .out(b1_step1));

            // Bước AES 2 (m=2)
            
            haraka_aes_step aes0_s2 (.in(b0_step1),      .rc(rc[4*t + 2]), .out(b0_step2));
            haraka_aes_step aes1_s2 (.in(b1_step1),      .rc(rc[4*t + 3]), .out(b1_step2));

           
            assign s[t+1][255:224] = b0_step2[127:96]; // x0
            assign s[t+1][223:192] = b1_step2[127:96]; // x4
            assign s[t+1][191:160] = b0_step2[95:64];  // x1
            assign s[t+1][159:128] = b1_step2[95:64];  // x5
            assign s[t+1][127:96]  = b0_step2[63:32];  // x2
            assign s[t+1][95:64]   = b1_step2[63:32];  // x6
            assign s[t+1][63:32]   = b0_step2[31:0];   // x3
            assign s[t+1][31:0]    = b1_step2[31:0];   // x7
        end
    endgenerate

    
    assign out = s[5] ^ in;
endmodule
