`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 07:37:39 AM
// Design Name: 
// Module Name: ALU_Mult
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


module ALU_Mult(
    input CLK,
    input [`DATA_BITS-1:0] A,
    input [`DATA_BITS-1:0] B,
    input [`ALU_CTRL_BITS-1:0] ALUOp,
    output reg [`DATA_BITS-1:0] Result

    );
    
    wire [127:0] mul64_result;
    wire [63:0] mul32_result;
    wire [63:0] mul64_out, mul32_out;
    
    mult_gen_1 mul32 (.CLK(CLK), .A(A[31:0]), .B(B[31:0]), .P(mul32_result));
    mult_gen_2 mul64 (.CLK(CLK), .A(A), .B(B), .P(mul64_result));
    
    assign mul64_out = mul64_result[63:0];
    assign mul32_out = {{32{mul32_result[31]}},mul32_result[31:0]};
    
    always @ (*) begin
        if (ALUOp == `ALU_MULW)
            Result = mul32_out;
        else if (ALUOp == `ALU_MUL) 
            Result = mul64_out;
        else
            Result = 64'h0;
    end
endmodule
