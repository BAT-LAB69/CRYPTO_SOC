`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 09:58:54
// Design Name: 
// Module Name: BranchCompare
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

module BranchCompare(
    input [`DATA_BITS-1:0] A,
    input [`DATA_BITS-1:0] B,
    input BrUn,
    output reg BrEq,
    output reg BrLT
    );
    
    wire signed [`DATA_BITS-1:0] A_signed, B_signed;
    
    always @ (*) begin
        if (BrUn) begin
            BrEq = (A == B) ? 1 : 0;
            BrLT = (A < B) ? 1 : 0;
        end
        else begin
            BrEq = (A == B) ? 1 : 0;
            BrLT = (A_signed < B_signed) ? 1 : 0;
        end
    end
    
    assign A_signed = A;
    assign B_signed = B;
endmodule
