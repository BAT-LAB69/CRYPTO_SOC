`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 22:55:58
// Design Name: 
// Module Name: rom_gen_1
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


module rom_gen_1(
input  wire        clk,
input  wire        srst,
input  wire [ 6:0] addr,
output wire [63:0] dout
);

(*ram_style = "registers"*)
reg [63:0] data_output;

assign dout = data_output;

always @(posedge clk) begin
    if (srst) data_output <= 64'h0000000000000000;
    else case (addr)
        7'h00: data_output <= 64'h04fb00040b9a0040;
        7'h01: data_output <= 64'h04fb01050b9a0141;
        7'h02: data_output <= 64'h04fb02060b9a0242;
        7'h03: data_output <= 64'h04fb03070b9a0343;
        7'h04: data_output <= 64'h0a5c080c0b9a0444;
        7'h05: data_output <= 64'h0a5c090d0b9a0545;
        7'h06: data_output <= 64'h0a5c0a0e0b9a0646;
        7'h07: data_output <= 64'h0a5c0b0f0b9a0747;
        7'h08: data_output <= 64'h042910140b9a0848;
        7'h09: data_output <= 64'h042911150b9a0949;
        7'h0a: data_output <= 64'h042912160b9a0a4a;
        7'h0b: data_output <= 64'h042913170b9a0b4b;
        7'h0c: data_output <= 64'h0b41181c0b9a0c4c;
        7'h0d: data_output <= 64'h0b41191d0b9a0d4d;
        7'h0e: data_output <= 64'h0b411a1e0b9a0e4e;
        7'h0f: data_output <= 64'h0b411b1f0b9a0f4f;
        7'h10: data_output <= 64'h02d520240b9a1050;
        7'h11: data_output <= 64'h02d521250b9a1151;
        7'h12: data_output <= 64'h02d522260b9a1252;
        7'h13: data_output <= 64'h02d523270b9a1353;
        7'h14: data_output <= 64'h05e4282c0b9a1454;
        7'h15: data_output <= 64'h05e4292d0b9a1555;
        7'h16: data_output <= 64'h05e42a2e0b9a1656;
        7'h17: data_output <= 64'h05e42b2f0b9a1757;
        7'h18: data_output <= 64'h094030340b9a1858;
        7'h19: data_output <= 64'h094031350b9a1959;
        7'h1a: data_output <= 64'h094032360b9a1a5a;
        7'h1b: data_output <= 64'h094033370b9a1b5b;
        7'h1c: data_output <= 64'h018e383c0b9a1c5c;
        7'h1d: data_output <= 64'h018e393d0b9a1d5d;
        7'h1e: data_output <= 64'h018e3a3e0b9a1e5e;
        7'h1f: data_output <= 64'h018e3b3f0b9a1f5f;
        7'h20: data_output <= 64'h03b740440b9a2060;
        7'h21: data_output <= 64'h03b741450b9a2161;
        7'h22: data_output <= 64'h03b742460b9a2262;
        7'h23: data_output <= 64'h03b743470b9a2363;
        7'h24: data_output <= 64'h00f7484c0b9a2464;
        7'h25: data_output <= 64'h00f7494d0b9a2565;
        7'h26: data_output <= 64'h00f74a4e0b9a2666;
        7'h27: data_output <= 64'h00f74b4f0b9a2767;
        7'h28: data_output <= 64'h058d50540b9a2868;
        7'h29: data_output <= 64'h058d51550b9a2969;
        7'h2a: data_output <= 64'h058d52560b9a2a6a;
        7'h2b: data_output <= 64'h058d53570b9a2b6b;
        7'h2c: data_output <= 64'h0c96585c0b9a2c6c;
        7'h2d: data_output <= 64'h0c96595d0b9a2d6d;
        7'h2e: data_output <= 64'h0c965a5e0b9a2e6e;
        7'h2f: data_output <= 64'h0c965b5f0b9a2f6f;
        7'h30: data_output <= 64'h09c360640b9a3070;
        7'h31: data_output <= 64'h09c361650b9a3171;
        7'h32: data_output <= 64'h09c362660b9a3272;
        7'h33: data_output <= 64'h09c363670b9a3373;
        7'h34: data_output <= 64'h010f686c0b9a3474;
        7'h35: data_output <= 64'h010f696d0b9a3575;
        7'h36: data_output <= 64'h010f6a6e0b9a3676;
        7'h37: data_output <= 64'h010f6b6f0b9a3777;
        7'h38: data_output <= 64'h005a70740b9a3878;
        7'h39: data_output <= 64'h005a71750b9a3979;
        7'h3a: data_output <= 64'h005a72760b9a3a7a;
        7'h3b: data_output <= 64'h005a73770b9a3b7b;
        7'h3c: data_output <= 64'h0355787c0b9a3c7c;
        7'h3d: data_output <= 64'h0355797d0b9a3d7d;
        7'h3e: data_output <= 64'h03557a7e0b9a3e7e;
        7'h3f: data_output <= 64'h03557b7f0b9a3f7f;
        7'h40: data_output <= 64'h07448084071480c0;
        7'h41: data_output <= 64'h07448185071481c1;
        7'h42: data_output <= 64'h07448286071482c2;
        7'h43: data_output <= 64'h07448387071483c3;
        7'h44: data_output <= 64'h0c83888c071484c4;
        7'h45: data_output <= 64'h0c83898d071485c5;
        7'h46: data_output <= 64'h0c838a8e071486c6;
        7'h47: data_output <= 64'h0c838b8f071487c7;
        7'h48: data_output <= 64'h048a9094071488c8;
        7'h49: data_output <= 64'h048a9195071489c9;
        7'h4a: data_output <= 64'h048a929607148aca;
        7'h4b: data_output <= 64'h048a939707148bcb;
        7'h4c: data_output <= 64'h0652989c07148ccc;
        7'h4d: data_output <= 64'h0652999d07148dcd;
        7'h4e: data_output <= 64'h06529a9e07148ece;
        7'h4f: data_output <= 64'h06529b9f07148fcf;
        7'h50: data_output <= 64'h029aa0a4071490d0;
        7'h51: data_output <= 64'h029aa1a5071491d1;
        7'h52: data_output <= 64'h029aa2a6071492d2;
        7'h53: data_output <= 64'h029aa3a7071493d3;
        7'h54: data_output <= 64'h0140a8ac071494d4;
        7'h55: data_output <= 64'h0140a9ad071495d5;
        7'h56: data_output <= 64'h0140aaae071496d6;
        7'h57: data_output <= 64'h0140abaf071497d7;
        7'h58: data_output <= 64'h0008b0b4071498d8;
        7'h59: data_output <= 64'h0008b1b5071499d9;
        7'h5a: data_output <= 64'h0008b2b607149ada;
        7'h5b: data_output <= 64'h0008b3b707149bdb;
        7'h5c: data_output <= 64'h0afdb8bc07149cdc;
        7'h5d: data_output <= 64'h0afdb9bd07149ddd;
        7'h5e: data_output <= 64'h0afdbabe07149ede;
        7'h5f: data_output <= 64'h0afdbbbf07149fdf;
        7'h60: data_output <= 64'h0608c0c40714a0e0;
        7'h61: data_output <= 64'h0608c1c50714a1e1;
        7'h62: data_output <= 64'h0608c2c60714a2e2;
        7'h63: data_output <= 64'h0608c3c70714a3e3;
        7'h64: data_output <= 64'h011ac8cc0714a4e4;
        7'h65: data_output <= 64'h011ac9cd0714a5e5;
        7'h66: data_output <= 64'h011acace0714a6e6;
        7'h67: data_output <= 64'h011acbcf0714a7e7;
        7'h68: data_output <= 64'h072ed0d40714a8e8;
        7'h69: data_output <= 64'h072ed1d50714a9e9;
        7'h6a: data_output <= 64'h072ed2d60714aaea;
        7'h6b: data_output <= 64'h072ed3d70714abeb;
        7'h6c: data_output <= 64'h050dd8dc0714acec;
        7'h6d: data_output <= 64'h050dd9dd0714aded;
        7'h6e: data_output <= 64'h050ddade0714aeee;
        7'h6f: data_output <= 64'h050ddbdf0714afef;
        7'h70: data_output <= 64'h090ae0e40714b0f0;
        7'h71: data_output <= 64'h090ae1e50714b1f1;
        7'h72: data_output <= 64'h090ae2e60714b2f2;
        7'h73: data_output <= 64'h090ae3e70714b3f3;
        7'h74: data_output <= 64'h0228e8ec0714b4f4;
        7'h75: data_output <= 64'h0228e9ed0714b5f5;
        7'h76: data_output <= 64'h0228eaee0714b6f6;
        7'h77: data_output <= 64'h0228ebef0714b7f7;
        7'h78: data_output <= 64'h0a75f0f40714b8f8;
        7'h79: data_output <= 64'h0a75f1f50714b9f9;
        7'h7a: data_output <= 64'h0a75f2f60714bafa;
        7'h7b: data_output <= 64'h0a75f3f70714bbfb;
        7'h7c: data_output <= 64'h083af8fc0714bcfc;
        7'h7d: data_output <= 64'h083af9fd0714bdfd;
        7'h7e: data_output <= 64'h083afafe0714befe;
        7'h7f: data_output <= 64'h083afbff0714bfff;
        default: data_output <= 64'h0000000000000000;
    endcase
end

endmodule
