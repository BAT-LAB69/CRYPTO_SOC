`include "defines.vh"

module BranchCompare (
    input  wire [63:0] A,         // rs1 value
    input  wire [63:0] B,         // rs2 value
    input  wire        BrUn,      // 1 = unsigned comparison
    output wire        BrEq,      // A == B
    output wire        BrLT       // A < B
);

    wire signed [63:0] A_signed = A;
    wire signed [63:0] B_signed = B;

    assign BrEq = (A == B);
    assign BrLT = BrUn ? (A < B) : (A_signed < B_signed);

endmodule
