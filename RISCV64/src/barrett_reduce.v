`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2024 09:09:03
// Design Name: 
// Module Name: barrett_reduce
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


module bart_red(
    input  wire        clk,
    input  wire        srst,
    input  wire [15:0] din,
    output wire [15:0] dout
);

    wire [15:0] p0, q;
    wire [31:0] p1;
    reg  [15:0] diff;

    mult_constants_v Mult_V (.clk(clk), .srst(srst), .din(din), .dout(p0));
    mult_constants_q Mult_Q (.clk(clk), .srst(srst), .din(p0), .dout(p1));
    c_shift_ram_0    Sft_RAM(.CLK(clk), .D(din), .Q(q));

    assign dout = diff;

    always @(posedge clk) begin
    if (srst) diff <= 16'h0;
    else diff <= q - p1[15:0];
end

endmodule
