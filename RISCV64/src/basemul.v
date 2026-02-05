`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2025 10:59:39 AM
// Design Name: 
// Module Name: basemul
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

module basemul(
input  wire        clk,
input  wire        srst,
input  wire [15:0] a0,
input  wire [15:0] a1,
input  wire [15:0] b0,
input  wire [15:0] b1,
input  wire [15:0] zeta,
output wire [15:0] r0,
output wire [15:0] r1
);

wire [31:0] p0, p1, p2, p3, p4;
wire [15:0] q0, q1, q2;
wire [15:0] red0, red1, red2, red3, red4;
reg  [15:0] sum0, sum1;

mult_gen_0    Mult_0   (.CLK(clk), .A(a0), .B(b0), .P(p0));
mult_gen_0    Mult_1   (.CLK(clk), .A(a1), .B(b1), .P(p1));
mult_gen_0    Mult_2   (.CLK(clk), .A(a0), .B(b1), .P(p2));
mult_gen_0    Mult_3   (.CLK(clk), .A(a1), .B(b0), .P(p3));
mult_gen_0    Mult_4   (.CLK(clk), .A(q0), .B(red1), .P(p4));
mont_red      MRed_0   (.clk(clk), .srst(srst), .din(p0), .dout(red0));
mont_red      MRed_1   (.clk(clk), .srst(srst), .din(p1), .dout(red1));
mont_red      MRed_2   (.clk(clk), .srst(srst), .din(p2), .dout(red2));
mont_red      MRed_3   (.clk(clk), .srst(srst), .din(p3), .dout(red3));
mont_red      MRed_4   (.clk(clk), .srst(srst), .din(p4), .dout(red4));
c_shift_ram_4 Sft_RAM_0(.CLK(clk), .D(zeta), .Q(q0));
c_shift_ram_4 Sft_RAM_1(.CLK(clk), .D(red0), .Q(q1));
c_shift_ram_4 Sft_RAM_2(.CLK(clk), .D(sum1), .Q(q2));

assign r0 = sum0;
assign r1 = q2;

always @(posedge clk) begin
    if (srst) sum0 <= 16'h0;
    else sum0 <= q1 + red4;
end

always @(posedge clk) begin
    if (srst) sum1 <= 16'h0;
    else sum1 <= red2 + red3;
end

endmodule


