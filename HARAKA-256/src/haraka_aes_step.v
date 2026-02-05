`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2026 11:14:02 PM
// Design Name: 
// Module Name: haraka_aes_step
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


module haraka_aes_step(
  input  wire [127:0] in,
    input  wire [127:0] rc,
    output wire [127:0] out
);
    wire [127:0] sb, sr, mc;
  
    //  SB -> SR -> MC -> ARK
    subbyte  u_sb  (.in(in), .out(sb));
    shiftrow u_sr  (.in(sb), .out(sr));
    mixcol   u_mc  (.in(sr), .out(mc));
assign out = mc ^ rc;
   
  
endmodule
