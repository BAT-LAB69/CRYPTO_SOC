`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2025 09:05:08 AM
// Design Name: 
// Module Name: ROM_ZETA
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


module round_constant(
    input  wire [ 4:0] round,
    output reg [63:0] constant
    );    
    
    always @(*) case (round)
        5'h00:	 constant = 64'h0000000000000001;
        5'h01:	 constant = 64'h0000000000008082;
        5'h02:	 constant = 64'h800000000000808a;
        5'h03:	 constant = 64'h8000000080008000;
        5'h04:	 constant = 64'h000000000000808b;
        5'h05:	 constant = 64'h0000000080000001;
        5'h06:	 constant = 64'h8000000080008081;
        5'h07:	 constant = 64'h8000000000008009;
        5'h08:	 constant = 64'h000000000000008a;
        5'h09:	 constant = 64'h0000000000000088;
        5'h0a:	 constant = 64'h0000000080008009;
        5'h0b:	 constant = 64'h000000008000000a;
        5'h0c:	 constant = 64'h000000008000808b;
        5'h0d:	 constant = 64'h800000000000008b;
        5'h0e:	 constant = 64'h8000000000008089;
        5'h0f:	 constant = 64'h8000000000008003;
        5'h10:	 constant = 64'h8000000000008002;
        5'h11:	 constant = 64'h8000000000000080;
        5'h12:	 constant = 64'h000000000000800a;
        5'h13:	 constant = 64'h800000008000000a;
        5'h14:	 constant = 64'h8000000080008081;
        5'h15:	 constant = 64'h8000000000008080;
        5'h16:	 constant = 64'h0000000080000001;
        5'h17:	 constant = 64'h8000000080008008;
        default: constant = 64'h0000000000000000;
    endcase

endmodule
