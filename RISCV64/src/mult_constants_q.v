`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2024 21:21:49
// Design Name: 
// Module Name: mult_constants_q
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


module mult_constants_q(
input  wire        clk,
input  wire        srst,
input  wire [15:0] din,
output wire [31:0] dout
);

wire [19:0] d0, d1, d2, d3, sum;
reg  [31:0] data_output;

assign d0   = {din[15], din, 3'h0};
assign d1   = {{2{din[15]}}, din, 2'h0};
assign d2   = {{4{din[15]}}, din};
assign d3   = {{16{din[15]}}, din[15:8]};
assign sum  = d0 + d1 + d2 + d3;
assign dout = data_output;

always @(posedge clk) begin
    if (srst) data_output <= 32'h0;
    else data_output <= {{4{sum[19]}}, sum, din[7:0]};
end

endmodule
