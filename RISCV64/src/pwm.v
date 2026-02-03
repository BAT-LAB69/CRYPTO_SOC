`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2025 10:59:13 AM
// Design Name: 
// Module Name: pwm
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


module pwm(
input  wire        clk,
input  wire        srst,
input  wire        en,
input  wire [31:0] a,
input  wire [31:0] b,
output wire        valid,
output wire [15:0] ra,
output wire [15:0] rb
);

reg         valid_output, compute, counter_output;
reg         counter_ce, counter_sclr;
reg  [ 6:0] counter_q;
wire [ 6:0] rom_addr;
wire [15:0] rom_dout;
reg	 [31:0] sftreg0_a, sftreg1_a;
reg	 [31:0] sftreg0_b, sftreg1_b;

// c_counter_binary_1 Counter(.CLK(clk), .CE(counter_ce), .SCLR(counter_sclr), .Q(counter_q));
rom_gen_8          ROM    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout));
basemul            BaseMul(.clk(clk), .srst(srst), .a0(sftreg1_a[31:16]), .a1(sftreg1_a[15:0]), .b0(sftreg1_b[31:16]), .b1(sftreg1_b[15:0]), .zeta(rom_dout), .r0(ra), .r1(rb));

assign rom_addr = counter_q;
assign valid    = valid_output;

always @(posedge clk) begin
    if (srst) counter_q <= 7'h0;
    else begin
        if (counter_sclr) counter_q <= 7'h0;
        else if (counter_ce) counter_q <= counter_q + 1'h1;
        else counter_q <= counter_q;
    end
end

always @(posedge clk) begin
	if (srst) begin
		sftreg0_a <= 32'h0;
		sftreg1_a <= 32'h0;
	end
	begin
		sftreg0_a <= a;
		sftreg1_a <= sftreg0_a;
	end
end

always @(posedge clk) begin
	if (srst) begin
		sftreg0_b <= 32'h0;
		sftreg1_b <= 32'h0;
	end
	begin
		sftreg0_b <= b;
		sftreg1_b <= sftreg0_b;
	end
end

always @(posedge clk) begin
    if (srst) begin
        counter_sclr   <= 1'b0;
        counter_ce     <= 1'b0;
        valid_output   <= 1'b0;
        compute        <= 1'b0;
        counter_output <= 1'b0;
    end
    else begin
        if (compute) begin
            if (counter_output) begin
                if (counter_q == 7'h0a) begin
                    counter_sclr   <= 1'b1;
                    counter_ce     <= 1'b1;
                    compute        <= 1'b0;
                    valid_output   <= 1'b1;
                    counter_output <= 1'b0;
                end
                else begin
                    counter_sclr   <= 1'b0;
                    counter_ce     <= 1'b1;
                    compute        <= 1'b1;
                    valid_output   <= 1'b1;
                    counter_output <= 1'b1;
                end
            end
            else begin
                if (counter_q == 7'h09) begin
                    counter_sclr   <= 1'b0;
                    counter_ce     <= 1'b1;
                    compute        <= 1'b1;
                    valid_output   <= 1'b1;
                    counter_output <= 1'b0;
                end
                else if (counter_q == 7'h7f) begin
                    counter_sclr   <= 1'b0;
                    counter_ce     <= 1'b1;
                    compute        <= 1'b1;
                    valid_output   <= 1'b1;
                    counter_output <= 1'b1;
                end
                else begin
                    counter_sclr   <= 1'b0;
                    counter_ce     <= 1'b1;
                    compute        <= 1'b1;
                    valid_output   <= valid_output;
                    counter_output <= 1'b0;
                end
            end
        end
        else begin
            if (en) begin
                counter_sclr   <= 1'b0;
                counter_ce     <= 1'b1;
                valid_output   <= 1'b0;
                compute        <= 1'b1;
                counter_output <= 1'b0;
            end
            else begin
                counter_sclr   <= 1'b0;
                counter_ce     <= 1'b0;
                valid_output   <= 1'b0;
                compute        <= 1'b0;
                counter_output <= 1'b0;
            end
        end
    end
end

endmodule

