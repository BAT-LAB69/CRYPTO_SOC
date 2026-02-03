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
input wire [127:0] in, iv, key,
output [127:0] out
    );
    wire [127:0] in1;
    assign in1 = in ^ iv;
    aes_encr aes_encr_dut(.in(in1),.key(key),.out(out));
endmodule
