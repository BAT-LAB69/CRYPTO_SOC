`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2024 07:29:48
// Design Name: 
// Module Name: butterfly_unit
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


module butterfly_unit_0(
    input  wire        clk,
    input  wire        srst,
    input  wire        s,
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [15:0] zeta,
    output wire [15:0] u,
    output wire [15:0] v,
    output wire [15:0] d,
    output wire [15:0] t
);

    reg  [15:0] sum0, sum1, diff0, diff1, mux0, mux1, zeta_delay, d_delay, zeta_delayy;
    wire [15:0] red0, red1, q;
    wire [31:0] p;

    bart_red      Bart_Red(.clk(clk), .srst(srst), .din(sum0), .dout(red0));
    mont_red      Mont_Red(.clk(clk), .srst(srst), .din(p), .dout(red1));
    mult_gen_0    Mult    (.CLK(clk), .A(mux0), .B(mux1), .P(p));
    c_shift_ram_2 Sft_RAM (.CLK(clk), .D(a), .Q(q));

    assign u = sum1; 
    assign v = diff1; 
    assign d = d_delay;
    assign t = red1;
    
    always @(posedge clk) begin
        if (srst) begin
            sum0       <= 16'h0;
            sum1       <= 16'h0;
            diff0      <= 16'h0;
            diff1      <= 16'h0;
            mux0       <= 16'h0;
            mux1       <= 16'h0;
            zeta_delay <= 16'h0;
            zeta_delayy <= 16'h0;
            d_delay    <= 16'h0;
        end
        else begin
            sum0       <= a + b;
            sum1       <= q + red1;
            diff0      <= a - b;
            diff1      <= q - red1;
            mux0       <= s ? b : diff0;
            mux1       <= s ? zeta : zeta_delayy;
            zeta_delay <= zeta;
            zeta_delayy <= zeta_delay;
            d_delay    <= red0;
        end
    end

endmodule

