`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2024 21:21:25
// Design Name: 
// Module Name: mult_constants_qinv
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


module mult_constants_qinv(
input  wire        clk,
input  wire        srst,
input  wire [31:0] din,
output wire [15:0] dout
);

wire [ 7:0] d0, d1, d2, d3, d4, d5, d6, sum;
reg  [15:0] data_output;

assign d0   = din[15:8];
assign d1   = din[7:0];
assign d2   = {din[6:0], 1'h0};
assign d3   = {din[3:0], 4'h0};
assign d4   = {din[2:0], 5'h0};
assign d5   = {din[1:0], 6'h0};
assign d6   = {din[0], 7'h0};
assign sum  = d0 + d1 + d2 + d3 + d4 + d5 + d6;
assign dout = data_output;

always @(posedge clk) begin
    if (srst) data_output <= 16'h0;
    else data_output <= {sum, din[7:0]};
end

endmodule
