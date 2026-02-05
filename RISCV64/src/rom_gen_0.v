`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.08.2024 11:02:43
// Design Name: 
// Module Name: rom_gen_0
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


module rom_gen_0(
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
            7'h00: data_output <= 64'h06a500020a0b0080;
            7'h01: data_output <= 64'h06a501030a0b0181;
            7'h02: data_output <= 64'h070f04060a0b0282;
            7'h03: data_output <= 64'h070f05070a0b0383;
            7'h04: data_output <= 64'h05b4080a0a0b0484;
            7'h05: data_output <= 64'h05b4090b0a0b0585;
            7'h06: data_output <= 64'h09430c0e0a0b0686;
            7'h07: data_output <= 64'h09430d0f0a0b0787;
            7'h08: data_output <= 64'h092210120a0b0888;
            7'h09: data_output <= 64'h092211130a0b0989;
            7'h0a: data_output <= 64'h091d14160a0b0a8a;
            7'h0b: data_output <= 64'h091d15170a0b0b8b;
            7'h0c: data_output <= 64'h0134181a0a0b0c8c;
            7'h0d: data_output <= 64'h0134191b0a0b0d8d;
            7'h0e: data_output <= 64'h006c1c1e0a0b0e8e;
            7'h0f: data_output <= 64'h006c1d1f0a0b0f8f;
            7'h10: data_output <= 64'h0b2320220a0b1090;
            7'h11: data_output <= 64'h0b2321230a0b1191;
            7'h12: data_output <= 64'h036624260a0b1292;
            7'h13: data_output <= 64'h036625270a0b1393;
            7'h14: data_output <= 64'h0356282a0a0b1494;
            7'h15: data_output <= 64'h0356292b0a0b1595;
            7'h16: data_output <= 64'h05e62c2e0a0b1696;
            7'h17: data_output <= 64'h05e62d2f0a0b1797;
            7'h18: data_output <= 64'h09e730320a0b1898;
            7'h19: data_output <= 64'h09e731330a0b1999;
            7'h1a: data_output <= 64'h04fe34360a0b1a9a;
            7'h1b: data_output <= 64'h04fe35370a0b1b9b;
            7'h1c: data_output <= 64'h05fa383a0a0b1c9c;
            7'h1d: data_output <= 64'h05fa393b0a0b1d9d;
            7'h1e: data_output <= 64'h04a13c3e0a0b1e9e;
            7'h1f: data_output <= 64'h04a13d3f0a0b1f9f;
            7'h20: data_output <= 64'h067b40420a0b20a0;
            7'h21: data_output <= 64'h067b41430a0b21a1;
            7'h22: data_output <= 64'h04a344460a0b22a2;
            7'h23: data_output <= 64'h04a345470a0b23a3;
            7'h24: data_output <= 64'h0c25484a0a0b24a4;
            7'h25: data_output <= 64'h0c25494b0a0b25a5;
            7'h26: data_output <= 64'h036a4c4e0a0b26a6;
            7'h27: data_output <= 64'h036a4d4f0a0b27a7;
            7'h28: data_output <= 64'h053750520a0b28a8;
            7'h29: data_output <= 64'h053751530a0b29a9;
            7'h2a: data_output <= 64'h083f54560a0b2aaa;
            7'h2b: data_output <= 64'h083f55570a0b2bab;
            7'h2c: data_output <= 64'h0088585a0a0b2cac;
            7'h2d: data_output <= 64'h0088595b0a0b2dad;
            7'h2e: data_output <= 64'h04bf5c5e0a0b2eae;
            7'h2f: data_output <= 64'h04bf5d5f0a0b2faf;
            7'h30: data_output <= 64'h0b8160620a0b30b0;
            7'h31: data_output <= 64'h0b8161630a0b31b1;
            7'h32: data_output <= 64'h05b964660a0b32b2;
            7'h33: data_output <= 64'h05b965670a0b33b3;
            7'h34: data_output <= 64'h0505686a0a0b34b4;
            7'h35: data_output <= 64'h0505696b0a0b35b5;
            7'h36: data_output <= 64'h07d76c6e0a0b36b6;
            7'h37: data_output <= 64'h07d76d6f0a0b37b7;
            7'h38: data_output <= 64'h0a9f70720a0b38b8;
            7'h39: data_output <= 64'h0a9f71730a0b39b9;
            7'h3a: data_output <= 64'h0aa674760a0b3aba;
            7'h3b: data_output <= 64'h0aa675770a0b3bbb;
            7'h3c: data_output <= 64'h08b8787a0a0b3cbc;
            7'h3d: data_output <= 64'h08b8797b0a0b3dbd;
            7'h3e: data_output <= 64'h09d07c7e0a0b3ebe;
            7'h3f: data_output <= 64'h09d07d7f0a0b3fbf;
            7'h40: data_output <= 64'h004b80820a0b40c0;
            7'h41: data_output <= 64'h004b81830a0b41c1;
            7'h42: data_output <= 64'h009c84860a0b42c2;
            7'h43: data_output <= 64'h009c85870a0b43c3;
            7'h44: data_output <= 64'h0bb8888a0a0b44c4;
            7'h45: data_output <= 64'h0bb8898b0a0b45c5;
            7'h46: data_output <= 64'h0b5f8c8e0a0b46c6;
            7'h47: data_output <= 64'h0b5f8d8f0a0b47c7;
            7'h48: data_output <= 64'h0ba490920a0b48c8;
            7'h49: data_output <= 64'h0ba491930a0b49c9;
            7'h4a: data_output <= 64'h036894960a0b4aca;
            7'h4b: data_output <= 64'h036895970a0b4bcb;
            7'h4c: data_output <= 64'h0a7d989a0a0b4ccc;
            7'h4d: data_output <= 64'h0a7d999b0a0b4dcd;
            7'h4e: data_output <= 64'h06369c9e0a0b4ece;
            7'h4f: data_output <= 64'h06369d9f0a0b4fcf;
            7'h50: data_output <= 64'h08a2a0a20a0b50d0;
            7'h51: data_output <= 64'h08a2a1a30a0b51d1;
            7'h52: data_output <= 64'h025aa4a60a0b52d2;
            7'h53: data_output <= 64'h025aa5a70a0b53d3;
            7'h54: data_output <= 64'h0736a8aa0a0b54d4;
            7'h55: data_output <= 64'h0736a9ab0a0b55d5;
            7'h56: data_output <= 64'h0309acae0a0b56d6;
            7'h57: data_output <= 64'h0309adaf0a0b57d7;
            7'h58: data_output <= 64'h0093b0b20a0b58d8;
            7'h59: data_output <= 64'h0093b1b30a0b59d9;
            7'h5a: data_output <= 64'h087ab4b60a0b5ada;
            7'h5b: data_output <= 64'h087ab5b70a0b5bdb;
            7'h5c: data_output <= 64'h09f7b8ba0a0b5cdc;
            7'h5d: data_output <= 64'h09f7b9bb0a0b5ddd;
            7'h5e: data_output <= 64'h00f6bcbe0a0b5ede;
            7'h5f: data_output <= 64'h00f6bdbf0a0b5fdf;
            7'h60: data_output <= 64'h068cc0c20a0b60e0;
            7'h61: data_output <= 64'h068cc1c30a0b61e1;
            7'h62: data_output <= 64'h06dbc4c60a0b62e2;
            7'h63: data_output <= 64'h06dbc5c70a0b63e3;
            7'h64: data_output <= 64'h01ccc8ca0a0b64e4;
            7'h65: data_output <= 64'h01ccc9cb0a0b65e5;
            7'h66: data_output <= 64'h0123ccce0a0b66e6;
            7'h67: data_output <= 64'h0123cdcf0a0b67e7;
            7'h68: data_output <= 64'h00ebd0d20a0b68e8;
            7'h69: data_output <= 64'h00ebd1d30a0b69e9;
            7'h6a: data_output <= 64'h0c50d4d60a0b6aea;
            7'h6b: data_output <= 64'h0c50d5d70a0b6beb;
            7'h6c: data_output <= 64'h0ab6d8da0a0b6cec;
            7'h6d: data_output <= 64'h0ab6d9db0a0b6ded;
            7'h6e: data_output <= 64'h0b5bdcde0a0b6eee;
            7'h6f: data_output <= 64'h0b5bdddf0a0b6fef;
            7'h70: data_output <= 64'h0c98e0e20a0b70f0;
            7'h71: data_output <= 64'h0c98e1e30a0b71f1;
            7'h72: data_output <= 64'h06f3e4e60a0b72f2;
            7'h73: data_output <= 64'h06f3e5e70a0b73f3;
            7'h74: data_output <= 64'h099ae8ea0a0b74f4;
            7'h75: data_output <= 64'h099ae9eb0a0b75f5;
            7'h76: data_output <= 64'h04e3ecee0a0b76f6;
            7'h77: data_output <= 64'h04e3edef0a0b77f7;
            7'h78: data_output <= 64'h09b6f0f20a0b78f8;
            7'h79: data_output <= 64'h09b6f1f30a0b79f9;
            7'h7a: data_output <= 64'h0ad6f4f60a0b7afa;
            7'h7b: data_output <= 64'h0ad6f5f70a0b7bfb;
            7'h7c: data_output <= 64'h0b53f8fa0a0b7cfc;
            7'h7d: data_output <= 64'h0b53f9fb0a0b7dfd;
            7'h7e: data_output <= 64'h044ffcfe0a0b7efe;
            7'h7f: data_output <= 64'h044ffdff0a0b7fff;
            default: data_output <= 64'h0000000000000000;
        endcase
    end
endmodule
