`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2024 09:13:58
// Design Name: 
// Module Name: mult_constants_v
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


module mult_constants_v(
input  wire        clk,
input  wire        srst,
input  wire [15:0] din,
output wire [15:0] dout
);

reg [31:0] sum0, sum1, sum2, sum;

assign dout = {{10{sum[31]}}, sum[31:26]};

always @(posedge clk) begin
    if (srst) begin
        sum0 <= 32'h0;
        sum1 <= 32'h0;
        sum2 <= 32'h0;
        sum  <= 32'h0;
    end
    else begin
        sum0 <= {{2{din[15]}}, din, 14'h0} + {{5{din[15]}}, din, 11'h0} + {{6{din[15]}}, din, 10'h0} + {{7{din[15]}}, din, 9'h0};
        sum1 <= {{9{din[15]}}, din, 7'h0}  + {{11{din[15]}}, din, 5'h0} + {{12{din[15]}}, din, 4'h0} + {{13{din[15]}}, din, 3'h0};
        sum2 <= {{14{din[15]}}, din, 2'h0} + {{15{din[15]}}, din, 1'h0} + {{16{din[15]}}, din};
        sum  <= sum0 + sum1 + sum2;
    end
end

endmodule
