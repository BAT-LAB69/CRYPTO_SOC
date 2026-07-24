`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:17:11
// Design Name: 
// Module Name: ALU
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

module ALU(
    input [`DATA_BITS-1:0] A,
    input [`DATA_BITS-1:0] B,
    input [`ALU_CTRL_BITS-1:0] ALUOp,
    output reg [`DATA_BITS-1:0] Result
    );
    wire signed [`DATA_BITS-1:0] A_signed, B_signed;    

    always @ (*)
        case (ALUOp)
            `ALU_ADD:       Result = A + B;
            `ALU_SUB:       Result = A - B;
            `ALU_AND:       Result = A & B; 
            `ALU_OR:        Result = A | B;
            `ALU_XOR:       Result = A ^ B;
            `ALU_SLL:       Result = A << B;
            `ALU_SLT:       Result = (A_signed < B_signed) ? 1 : 0;
            `ALU_SLTU:      Result = (A < B) ? 1 : 0;
            `ALU_SRL:       Result = A >> B;
            `ALU_SRA:       Result = A_signed >>> B;   
            `ALU_LUI:       Result = B;
            `ALU_AUIPC:     Result = A + B;    
            `ALU_SLLW:      Result = {{32{A[31]}}, (A[31:0] << B)};
            `ALU_SRLW:      Result = {{32{1'b0}}, (A[31:0] >> B)};
            `ALU_SRAW:      Result = $signed({{32{A[31]}}, A[31:0]}) >>> B[4:0];
            default:        Result = 64'b0;
        endcase
    assign A_signed = A;
    assign B_signed = B;
    
endmodule
