`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2024 20:43:37
// Design Name: 
// Module Name: mont_reduce
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


module mont_red(
input  wire        clk,
input  wire        srst,
input  wire [31:0] din,
output wire [15:0] dout
);

wire [15:0] p0;
wire [31:0] p1, q;
reg  [31:0] diff;

mult_constants_qinv Mult_QInv(.clk(clk), .srst(srst), .din(din), .dout(p0));
mult_constants_q    Mult_Q   (.clk(clk), .srst(srst), .din(p0), .dout(p1));
c_shift_ram_7       Sft_RAM  (.CLK(clk), .D(din), .Q(q));

assign dout = diff[31:16];

always @(posedge clk) begin
    if (srst) diff <= 32'h0;
    else diff <= q - p1;
end

endmodule
