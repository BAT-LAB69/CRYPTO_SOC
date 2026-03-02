`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// Adder - 64-bit adder using CLA64 Carry-Lookahead
// Used for PC+4 and branch target calculations
//////////////////////////////////////////////////////////////////////////////////

module Adder (
    input  wire [63:0] A,
    input  wire [63:0] B,
    output wire [63:0] C
);

    wire cout;

    CLA64 u_cla (
        .A(A), .B(B), .cin(1'b0),
        .S(C), .cout(cout)
    );

endmodule
