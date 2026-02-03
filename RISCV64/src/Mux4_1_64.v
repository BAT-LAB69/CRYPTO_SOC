`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:12:38
// Design Name: 
// Module Name: Mux4_1_64
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
`include "common.vh"

module Mux4_1_64(
        input [1:0] Sel,
		input [`DATA_BITS-1:0] In_0,
		input [`DATA_BITS-1:0] In_1,
		input [`DATA_BITS-1:0] In_2,
		input [`DATA_BITS-1:0] In_3,
		output reg [`DATA_BITS-1:0] Out
		);
	always @(*) begin
		case(Sel)
			2'b00: Out <= In_0;
			2'b01: Out <= In_1;
			2'b10: Out <= In_2;
			2'b11: Out <= In_3;
			default: Out <= In_0;
		endcase
	end
endmodule
