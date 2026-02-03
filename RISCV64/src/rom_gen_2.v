`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 22:56:12
// Design Name: 
// Module Name: rom_gen_2
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


module rom_gen_2(
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
        7'h00: data_output <= 64'h0623000805d50020;
        7'h01: data_output <= 64'h0623010905d50121;
        7'h02: data_output <= 64'h0623020a05d50222;
        7'h03: data_output <= 64'h0623030b05d50323;
        7'h04: data_output <= 64'h0623040c05d50424;
        7'h05: data_output <= 64'h0623050d05d50525;
        7'h06: data_output <= 64'h0623060e05d50626;
        7'h07: data_output <= 64'h0623070f05d50727;
        7'h08: data_output <= 64'h00cd101805d50828;
        7'h09: data_output <= 64'h00cd111905d50929;
        7'h0a: data_output <= 64'h00cd121a05d50a2a;
        7'h0b: data_output <= 64'h00cd131b05d50b2b;
        7'h0c: data_output <= 64'h00cd141c05d50c2c;
        7'h0d: data_output <= 64'h00cd151d05d50d2d;
        7'h0e: data_output <= 64'h00cd161e05d50e2e;
        7'h0f: data_output <= 64'h00cd171f05d50f2f;
        7'h10: data_output <= 64'h0b66202805d51030;
        7'h11: data_output <= 64'h0b66212905d51131;
        7'h12: data_output <= 64'h0b66222a05d51232;
        7'h13: data_output <= 64'h0b66232b05d51333;
        7'h14: data_output <= 64'h0b66242c05d51434;
        7'h15: data_output <= 64'h0b66252d05d51535;
        7'h16: data_output <= 64'h0b66262e05d51636;
        7'h17: data_output <= 64'h0b66272f05d51737;
        7'h18: data_output <= 64'h0606303805d51838;
        7'h19: data_output <= 64'h0606313905d51939;
        7'h1a: data_output <= 64'h0606323a05d51a3a;
        7'h1b: data_output <= 64'h0606333b05d51b3b;
        7'h1c: data_output <= 64'h0606343c05d51c3c;
        7'h1d: data_output <= 64'h0606353d05d51d3d;
        7'h1e: data_output <= 64'h0606363e05d51e3e;
        7'h1f: data_output <= 64'h0606373f05d51f3f;
        7'h20: data_output <= 64'h0aa14048058e4060;
        7'h21: data_output <= 64'h0aa14149058e4161;
        7'h22: data_output <= 64'h0aa1424a058e4262;
        7'h23: data_output <= 64'h0aa1434b058e4363;
        7'h24: data_output <= 64'h0aa1444c058e4464;
        7'h25: data_output <= 64'h0aa1454d058e4565;
        7'h26: data_output <= 64'h0aa1464e058e4666;
        7'h27: data_output <= 64'h0aa1474f058e4767;
        7'h28: data_output <= 64'h0a255058058e4868;
        7'h29: data_output <= 64'h0a255159058e4969;
        7'h2a: data_output <= 64'h0a25525a058e4a6a;
        7'h2b: data_output <= 64'h0a25535b058e4b6b;
        7'h2c: data_output <= 64'h0a25545c058e4c6c;
        7'h2d: data_output <= 64'h0a25555d058e4d6d;
        7'h2e: data_output <= 64'h0a25565e058e4e6e;
        7'h2f: data_output <= 64'h0a25575f058e4f6f;
        7'h30: data_output <= 64'h09086068058e5070;
        7'h31: data_output <= 64'h09086169058e5171;
        7'h32: data_output <= 64'h0908626a058e5272;
        7'h33: data_output <= 64'h0908636b058e5373;
        7'h34: data_output <= 64'h0908646c058e5474;
        7'h35: data_output <= 64'h0908656d058e5575;
        7'h36: data_output <= 64'h0908666e058e5676;
        7'h37: data_output <= 64'h0908676f058e5777;
        7'h38: data_output <= 64'h02a97078058e5878;
        7'h39: data_output <= 64'h02a97179058e5979;
        7'h3a: data_output <= 64'h02a9727a058e5a7a;
        7'h3b: data_output <= 64'h02a9737b058e5b7b;
        7'h3c: data_output <= 64'h02a9747c058e5c7c;
        7'h3d: data_output <= 64'h02a9757d058e5d7d;
        7'h3e: data_output <= 64'h02a9767e058e5e7e;
        7'h3f: data_output <= 64'h02a9777f058e5f7f;
        7'h40: data_output <= 64'h00828088011f80a0;
        7'h41: data_output <= 64'h00828189011f81a1;
        7'h42: data_output <= 64'h0082828a011f82a2;
        7'h43: data_output <= 64'h0082838b011f83a3;
        7'h44: data_output <= 64'h0082848c011f84a4;
        7'h45: data_output <= 64'h0082858d011f85a5;
        7'h46: data_output <= 64'h0082868e011f86a6;
        7'h47: data_output <= 64'h0082878f011f87a7;
        7'h48: data_output <= 64'h06429098011f88a8;
        7'h49: data_output <= 64'h06429199011f89a9;
        7'h4a: data_output <= 64'h0642929a011f8aaa;
        7'h4b: data_output <= 64'h0642939b011f8bab;
        7'h4c: data_output <= 64'h0642949c011f8cac;
        7'h4d: data_output <= 64'h0642959d011f8dad;
        7'h4e: data_output <= 64'h0642969e011f8eae;
        7'h4f: data_output <= 64'h0642979f011f8faf;
        7'h50: data_output <= 64'h074fa0a8011f90b0;
        7'h51: data_output <= 64'h074fa1a9011f91b1;
        7'h52: data_output <= 64'h074fa2aa011f92b2;
        7'h53: data_output <= 64'h074fa3ab011f93b3;
        7'h54: data_output <= 64'h074fa4ac011f94b4;
        7'h55: data_output <= 64'h074fa5ad011f95b5;
        7'h56: data_output <= 64'h074fa6ae011f96b6;
        7'h57: data_output <= 64'h074fa7af011f97b7;
        7'h58: data_output <= 64'h033db0b8011f98b8;
        7'h59: data_output <= 64'h033db1b9011f99b9;
        7'h5a: data_output <= 64'h033db2ba011f9aba;
        7'h5b: data_output <= 64'h033db3bb011f9bbb;
        7'h5c: data_output <= 64'h033db4bc011f9cbc;
        7'h5d: data_output <= 64'h033db5bd011f9dbd;
        7'h5e: data_output <= 64'h033db6be011f9ebe;
        7'h5f: data_output <= 64'h033db7bf011f9fbf;
        7'h60: data_output <= 64'h0b82c0c800cac0e0;
        7'h61: data_output <= 64'h0b82c1c900cac1e1;
        7'h62: data_output <= 64'h0b82c2ca00cac2e2;
        7'h63: data_output <= 64'h0b82c3cb00cac3e3;
        7'h64: data_output <= 64'h0b82c4cc00cac4e4;
        7'h65: data_output <= 64'h0b82c5cd00cac5e5;
        7'h66: data_output <= 64'h0b82c6ce00cac6e6;
        7'h67: data_output <= 64'h0b82c7cf00cac7e7;
        7'h68: data_output <= 64'h0bf9d0d800cac8e8;
        7'h69: data_output <= 64'h0bf9d1d900cac9e9;
        7'h6a: data_output <= 64'h0bf9d2da00cacaea;
        7'h6b: data_output <= 64'h0bf9d3db00cacbeb;
        7'h6c: data_output <= 64'h0bf9d4dc00caccec;
        7'h6d: data_output <= 64'h0bf9d5dd00cacded;
        7'h6e: data_output <= 64'h0bf9d6de00caceee;
        7'h6f: data_output <= 64'h0bf9d7df00cacfef;
        7'h70: data_output <= 64'h052de0e800cad0f0;
        7'h71: data_output <= 64'h052de1e900cad1f1;
        7'h72: data_output <= 64'h052de2ea00cad2f2;
        7'h73: data_output <= 64'h052de3eb00cad3f3;
        7'h74: data_output <= 64'h052de4ec00cad4f4;
        7'h75: data_output <= 64'h052de5ed00cad5f5;
        7'h76: data_output <= 64'h052de6ee00cad6f6;
        7'h77: data_output <= 64'h052de7ef00cad7f7;
        7'h78: data_output <= 64'h0ac4f0f800cad8f8;
        7'h79: data_output <= 64'h0ac4f1f900cad9f9;
        7'h7a: data_output <= 64'h0ac4f2fa00cadafa;
        7'h7b: data_output <= 64'h0ac4f3fb00cadbfb;
        7'h7c: data_output <= 64'h0ac4f4fc00cadcfc;
        7'h7d: data_output <= 64'h0ac4f5fd00caddfd;
        7'h7e: data_output <= 64'h0ac4f6fe00cadefe;
        7'h7f: data_output <= 64'h0ac4f7ff00cadfff;
        default: data_output <= 64'h0000000000000000;
    endcase
end

endmodule
