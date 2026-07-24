`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 22:57:46
// Design Name: 
// Module Name: rom_gen_7
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


module rom_gen_7(
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
        7'h00: data_output <= 16'h0001;
        7'h01: data_output <= 16'h0203;
        7'h02: data_output <= 16'h0405;
        7'h03: data_output <= 16'h0607;
        7'h04: data_output <= 16'h0809;
        7'h05: data_output <= 16'h0a0b;
        7'h06: data_output <= 16'h0c0d;
        7'h07: data_output <= 16'h0e0f;
        7'h08: data_output <= 16'h1011;
        7'h09: data_output <= 16'h1213;
        7'h0a: data_output <= 16'h1415;
        7'h0b: data_output <= 16'h1617;
        7'h0c: data_output <= 16'h1819;
        7'h0d: data_output <= 16'h1a1b;
        7'h0e: data_output <= 16'h1c1d;
        7'h0f: data_output <= 16'h1e1f;
        7'h10: data_output <= 16'h2021;
        7'h11: data_output <= 16'h2223;
        7'h12: data_output <= 16'h2425;
        7'h13: data_output <= 16'h2627;
        7'h14: data_output <= 16'h2829;
        7'h15: data_output <= 16'h2a2b;
        7'h16: data_output <= 16'h2c2d;
        7'h17: data_output <= 16'h2e2f;
        7'h18: data_output <= 16'h3031;
        7'h19: data_output <= 16'h3233;
        7'h1a: data_output <= 16'h3435;
        7'h1b: data_output <= 16'h3637;
        7'h1c: data_output <= 16'h3839;
        7'h1d: data_output <= 16'h3a3b;
        7'h1e: data_output <= 16'h3c3d;
        7'h1f: data_output <= 16'h3e3f;
        7'h20: data_output <= 16'h4041;
        7'h21: data_output <= 16'h4243;
        7'h22: data_output <= 16'h4445;
        7'h23: data_output <= 16'h4647;
        7'h24: data_output <= 16'h4849;
        7'h25: data_output <= 16'h4a4b;
        7'h26: data_output <= 16'h4c4d;
        7'h27: data_output <= 16'h4e4f;
        7'h28: data_output <= 16'h5051;
        7'h29: data_output <= 16'h5253;
        7'h2a: data_output <= 16'h5455;
        7'h2b: data_output <= 16'h5657;
        7'h2c: data_output <= 16'h5859;
        7'h2d: data_output <= 16'h5a5b;
        7'h2e: data_output <= 16'h5c5d;
        7'h2f: data_output <= 16'h5e5f;
        7'h30: data_output <= 16'h6061;
        7'h31: data_output <= 16'h6263;
        7'h32: data_output <= 16'h6465;
        7'h33: data_output <= 16'h6667;
        7'h34: data_output <= 16'h6869;
        7'h35: data_output <= 16'h6a6b;
        7'h36: data_output <= 16'h6c6d;
        7'h37: data_output <= 16'h6e6f;
        7'h38: data_output <= 16'h7071;
        7'h39: data_output <= 16'h7273;
        7'h3a: data_output <= 16'h7475;
        7'h3b: data_output <= 16'h7677;
        7'h3c: data_output <= 16'h7879;
        7'h3d: data_output <= 16'h7a7b;
        7'h3e: data_output <= 16'h7c7d;
        7'h3f: data_output <= 16'h7e7f;
        7'h40: data_output <= 16'h8081;
        7'h41: data_output <= 16'h8283;
        7'h42: data_output <= 16'h8485;
        7'h43: data_output <= 16'h8687;
        7'h44: data_output <= 16'h8889;
        7'h45: data_output <= 16'h8a8b;
        7'h46: data_output <= 16'h8c8d;
        7'h47: data_output <= 16'h8e8f;
        7'h48: data_output <= 16'h9091;
        7'h49: data_output <= 16'h9293;
        7'h4a: data_output <= 16'h9495;
        7'h4b: data_output <= 16'h9697;
        7'h4c: data_output <= 16'h9899;
        7'h4d: data_output <= 16'h9a9b;
        7'h4e: data_output <= 16'h9c9d;
        7'h4f: data_output <= 16'h9e9f;
        7'h50: data_output <= 16'ha0a1;
        7'h51: data_output <= 16'ha2a3;
        7'h52: data_output <= 16'ha4a5;
        7'h53: data_output <= 16'ha6a7;
        7'h54: data_output <= 16'ha8a9;
        7'h55: data_output <= 16'haaab;
        7'h56: data_output <= 16'hacad;
        7'h57: data_output <= 16'haeaf;
        7'h58: data_output <= 16'hb0b1;
        7'h59: data_output <= 16'hb2b3;
        7'h5a: data_output <= 16'hb4b5;
        7'h5b: data_output <= 16'hb6b7;
        7'h5c: data_output <= 16'hb8b9;
        7'h5d: data_output <= 16'hbabb;
        7'h5e: data_output <= 16'hbcbd;
        7'h5f: data_output <= 16'hbebf;
        7'h60: data_output <= 16'hc0c1;
        7'h61: data_output <= 16'hc2c3;
        7'h62: data_output <= 16'hc4c5;
        7'h63: data_output <= 16'hc6c7;
        7'h64: data_output <= 16'hc8c9;
        7'h65: data_output <= 16'hcacb;
        7'h66: data_output <= 16'hcccd;
        7'h67: data_output <= 16'hcecf;
        7'h68: data_output <= 16'hd0d1;
        7'h69: data_output <= 16'hd2d3;
        7'h6a: data_output <= 16'hd4d5;
        7'h6b: data_output <= 16'hd6d7;
        7'h6c: data_output <= 16'hd8d9;
        7'h6d: data_output <= 16'hdadb;
        7'h6e: data_output <= 16'hdcdd;
        7'h6f: data_output <= 16'hdedf;
        7'h70: data_output <= 16'he0e1;
        7'h71: data_output <= 16'he2e3;
        7'h72: data_output <= 16'he4e5;
        7'h73: data_output <= 16'he6e7;
        7'h74: data_output <= 16'he8e9;
        7'h75: data_output <= 16'heaeb;
        7'h76: data_output <= 16'heced;
        7'h77: data_output <= 16'heeef;
        7'h78: data_output <= 16'hf0f1;
        7'h79: data_output <= 16'hf2f3;
        7'h7a: data_output <= 16'hf4f5;
        7'h7b: data_output <= 16'hf6f7;
        7'h7c: data_output <= 16'hf8f9;
        7'h7d: data_output <= 16'hfafb;
        7'h7e: data_output <= 16'hfcfd;
        7'h7f: data_output <= 16'hfeff;
        default: data_output <= 16'h0000;
    endcase
end

endmodule
