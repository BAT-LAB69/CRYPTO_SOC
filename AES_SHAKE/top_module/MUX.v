`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 02:39:04 AM
// Design Name: 
// Module Name: MUX
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


module MUX(
input wire [127:0] i_plaintext,
input wire press,
input wire [127:0] i_iv,
input wire [127:0] i_key,
output reg [127:0] o_plaintext,
output reg [127:0] o_key,
output reg [127:0] o_iv
    );
    
    always @ (*) begin
    if(!press) begin 
    o_iv = 128'b0;
    o_key = 128'b0;
    o_plaintext=128'b0;
    end
    else begin
     o_iv = i_iv ;
    o_key = i_key;
    o_plaintext=i_plaintext;
    end
    end
endmodule
