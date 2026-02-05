`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:12:17
// Design Name: 
// Module Name: Mux2_1_64
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

module Mux2_1_64(
        input Sel,
        input [`DATA_BITS-1:0] In_0,
        input [`DATA_BITS-1:0] In_1,
        output [`DATA_BITS-1:0] Out
    );
    assign Out = (Sel) ? In_1 : In_0;
endmodule
