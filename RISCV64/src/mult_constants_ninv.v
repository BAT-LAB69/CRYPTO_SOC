`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 23:01:40
// Design Name: 
// Module Name: mult_constants_ninv
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


module mult_constants_ninv(
input  wire        clk,
input  wire        srst,
input  wire [15:0] din,
output wire [31:0] dout
);

reg [31:0] sum0, sum1, sum;

assign dout = sum;

always @(posedge clk) begin
    if (srst) begin
        sum0 <= 32'h0;
        sum1 <= 32'h0;
        sum  <= 32'h0;
    end
    else begin
        sum0 <= {{6{din[15]}}, din, 10'h0} + {{8{din[15]}}, din, 8'h0} + {{9{din[15]}}, din, 7'h0};
        sum1 <= {{11{din[15]}}, din, 5'h0} + {{16{din[15]}}, din};
        sum  <= sum0  + sum1;
    end
end
endmodule
