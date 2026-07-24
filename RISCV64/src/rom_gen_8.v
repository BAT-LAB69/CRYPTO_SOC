`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2025 11:00:15 AM
// Design Name: 
// Module Name: rom_gen_8
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

module rom_gen_8(
input  wire        clk,
input  wire        srst,
input  wire [ 6:0] addr,
output wire [15:0] dout
);

(*ram_style = "registers"*)
reg [15:0] data_output;

assign dout = data_output;

always @(posedge clk) begin
    if (srst) data_output <= 16'h0000;
    else case (addr)
        7'h00: data_output <= 16'h08b2;
        7'h01: data_output <= 16'hf74e;
        7'h02: data_output <= 16'h01ae;
        7'h03: data_output <= 16'hfe52;
        7'h04: data_output <= 16'h022b;
        7'h05: data_output <= 16'hfdd5;
        7'h06: data_output <= 16'h034b;
        7'h07: data_output <= 16'hfcb5;
        7'h08: data_output <= 16'h081e;
        7'h09: data_output <= 16'hf7e2;
        7'h0a: data_output <= 16'h0367;
        7'h0b: data_output <= 16'hfc99;
        7'h0c: data_output <= 16'h060e;
        7'h0d: data_output <= 16'hf9f2;
        7'h0e: data_output <= 16'h0069;
        7'h0f: data_output <= 16'hff97;
        7'h10: data_output <= 16'h01a6;
        7'h11: data_output <= 16'hfe5a;
        7'h12: data_output <= 16'h024b;
        7'h13: data_output <= 16'hfdb5;
        7'h14: data_output <= 16'h00b1;
        7'h15: data_output <= 16'hff4f;
        7'h16: data_output <= 16'h0c16;
        7'h17: data_output <= 16'hf3ea;
        7'h18: data_output <= 16'h0bde;
        7'h19: data_output <= 16'hf422;
        7'h1a: data_output <= 16'h0b35;
        7'h1b: data_output <= 16'hf4cb;
        7'h1c: data_output <= 16'h0626;
        7'h1d: data_output <= 16'hf9da;
        7'h1e: data_output <= 16'h0675;
        7'h1f: data_output <= 16'hf98b;
        7'h20: data_output <= 16'h0c0b;
        7'h21: data_output <= 16'hf3f5;
        7'h22: data_output <= 16'h030a;
        7'h23: data_output <= 16'hfcf6;
        7'h24: data_output <= 16'h0487;
        7'h25: data_output <= 16'hfb79;
        7'h26: data_output <= 16'h0c6e;
        7'h27: data_output <= 16'hf392;
        7'h28: data_output <= 16'h09f8;
        7'h29: data_output <= 16'hf608;
        7'h2a: data_output <= 16'h05cb;
        7'h2b: data_output <= 16'hfa35;
        7'h2c: data_output <= 16'h0aa7;
        7'h2d: data_output <= 16'hf559;
        7'h2e: data_output <= 16'h045f;
        7'h2f: data_output <= 16'hfba1;
        7'h30: data_output <= 16'h06cb;
        7'h31: data_output <= 16'hf935;
        7'h32: data_output <= 16'h0284;
        7'h33: data_output <= 16'hfd7c;
        7'h34: data_output <= 16'h0999;
        7'h35: data_output <= 16'hf667;
        7'h36: data_output <= 16'h015d;
        7'h37: data_output <= 16'hfea3;
        7'h38: data_output <= 16'h01a2;
        7'h39: data_output <= 16'hfe5e;
        7'h3a: data_output <= 16'h0149;
        7'h3b: data_output <= 16'hfeb7;
        7'h3c: data_output <= 16'h0c65;
        7'h3d: data_output <= 16'hf39b;
        7'h3e: data_output <= 16'h0cb6;
        7'h3f: data_output <= 16'hf34a;
        7'h40: data_output <= 16'h0331;
        7'h41: data_output <= 16'hfccf;
        7'h42: data_output <= 16'h0449;
        7'h43: data_output <= 16'hfbb7;
        7'h44: data_output <= 16'h025b;
        7'h45: data_output <= 16'hfda5;
        7'h46: data_output <= 16'h0262;
        7'h47: data_output <= 16'hfd9e;
        7'h48: data_output <= 16'h052a;
        7'h49: data_output <= 16'hfad6;
        7'h4a: data_output <= 16'h07fc;
        7'h4b: data_output <= 16'hf804;
        7'h4c: data_output <= 16'h0748;
        7'h4d: data_output <= 16'hf8b8;
        7'h4e: data_output <= 16'h0180;
        7'h4f: data_output <= 16'hfe80;
        7'h50: data_output <= 16'h0842;
        7'h51: data_output <= 16'hf7be;
        7'h52: data_output <= 16'h0c79;
        7'h53: data_output <= 16'hf387;
        7'h54: data_output <= 16'h04c2;
        7'h55: data_output <= 16'hfb3e;
        7'h56: data_output <= 16'h07ca;
        7'h57: data_output <= 16'hf836;
        7'h58: data_output <= 16'h0997;
        7'h59: data_output <= 16'hf669;
        7'h5a: data_output <= 16'h00dc;
        7'h5b: data_output <= 16'hff24;
        7'h5c: data_output <= 16'h085e;
        7'h5d: data_output <= 16'hf7a2;
        7'h5e: data_output <= 16'h0686;
        7'h5f: data_output <= 16'hf97a;
        7'h60: data_output <= 16'h0860;
        7'h61: data_output <= 16'hf7a0;
        7'h62: data_output <= 16'h0707;
        7'h63: data_output <= 16'hf8f9;
        7'h64: data_output <= 16'h0803;
        7'h65: data_output <= 16'hf7fd;
        7'h66: data_output <= 16'h031a;
        7'h67: data_output <= 16'hfce6;
        7'h68: data_output <= 16'h071b;
        7'h69: data_output <= 16'hf8e5;
        7'h6a: data_output <= 16'h09ab;
        7'h6b: data_output <= 16'hf655;
        7'h6c: data_output <= 16'h099b;
        7'h6d: data_output <= 16'hf665;
        7'h6e: data_output <= 16'h01de;
        7'h6f: data_output <= 16'hfe22;
        7'h70: data_output <= 16'h0c95;
        7'h71: data_output <= 16'hf36b;
        7'h72: data_output <= 16'h0bcd;
        7'h73: data_output <= 16'hf433;
        7'h74: data_output <= 16'h03e4;
        7'h75: data_output <= 16'hfc1c;
        7'h76: data_output <= 16'h03df;
        7'h77: data_output <= 16'hfc21;
        7'h78: data_output <= 16'h03be;
        7'h79: data_output <= 16'hfc42;
        7'h7a: data_output <= 16'h074d;
        7'h7b: data_output <= 16'hf8b3;
        7'h7c: data_output <= 16'h05f2;
        7'h7d: data_output <= 16'hfa0e;
        7'h7e: data_output <= 16'h065c;
        7'h7f: data_output <= 16'hf9a4;
        default: data_output <= 16'h0000;
    endcase
end

endmodule

