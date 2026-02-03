`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 22:57:05
// Design Name: 
// Module Name: rom_gen_4
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

module rom_gen_4(
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
        7'h00: data_output <= 64'h0c370020023d0008;
        7'h01: data_output <= 64'h0c370121023d0109;
        7'h02: data_output <= 64'h0c370222023d020a;
        7'h03: data_output <= 64'h0c370323023d030b;
        7'h04: data_output <= 64'h0c370424023d040c;
        7'h05: data_output <= 64'h0c370525023d050d;
        7'h06: data_output <= 64'h0c370626023d060e;
        7'h07: data_output <= 64'h0c370727023d070f;
        7'h08: data_output <= 64'h0c37082807d41018;
        7'h09: data_output <= 64'h0c37092907d41119;
        7'h0a: data_output <= 64'h0c370a2a07d4121a;
        7'h0b: data_output <= 64'h0c370b2b07d4131b;
        7'h0c: data_output <= 64'h0c370c2c07d4141c;
        7'h0d: data_output <= 64'h0c370d2d07d4151d;
        7'h0e: data_output <= 64'h0c370e2e07d4161e;
        7'h0f: data_output <= 64'h0c370f2f07d4171f;
        7'h10: data_output <= 64'h0c37103001082028;
        7'h11: data_output <= 64'h0c37113101082129;
        7'h12: data_output <= 64'h0c3712320108222a;
        7'h13: data_output <= 64'h0c3713330108232b;
        7'h14: data_output <= 64'h0c3714340108242c;
        7'h15: data_output <= 64'h0c3715350108252d;
        7'h16: data_output <= 64'h0c3716360108262e;
        7'h17: data_output <= 64'h0c3717370108272f;
        7'h18: data_output <= 64'h0c371838017f3038;
        7'h19: data_output <= 64'h0c371939017f3139;
        7'h1a: data_output <= 64'h0c371a3a017f323a;
        7'h1b: data_output <= 64'h0c371b3b017f333b;
        7'h1c: data_output <= 64'h0c371c3c017f343c;
        7'h1d: data_output <= 64'h0c371d3d017f353d;
        7'h1e: data_output <= 64'h0c371e3e017f363e;
        7'h1f: data_output <= 64'h0c371f3f017f373f;
        7'h20: data_output <= 64'h0be2406009c44048;
        7'h21: data_output <= 64'h0be2416109c44149;
        7'h22: data_output <= 64'h0be2426209c4424a;
        7'h23: data_output <= 64'h0be2436309c4434b;
        7'h24: data_output <= 64'h0be2446409c4444c;
        7'h25: data_output <= 64'h0be2456509c4454d;
        7'h26: data_output <= 64'h0be2466609c4464e;
        7'h27: data_output <= 64'h0be2476709c4474f;
        7'h28: data_output <= 64'h0be2486805b25058;
        7'h29: data_output <= 64'h0be2496905b25159;
        7'h2a: data_output <= 64'h0be24a6a05b2525a;
        7'h2b: data_output <= 64'h0be24b6b05b2535b;
        7'h2c: data_output <= 64'h0be24c6c05b2545c;
        7'h2d: data_output <= 64'h0be24d6d05b2555d;
        7'h2e: data_output <= 64'h0be24e6e05b2565e;
        7'h2f: data_output <= 64'h0be24f6f05b2575f;
        7'h30: data_output <= 64'h0be2507006bf6068;
        7'h31: data_output <= 64'h0be2517106bf6169;
        7'h32: data_output <= 64'h0be2527206bf626a;
        7'h33: data_output <= 64'h0be2537306bf636b;
        7'h34: data_output <= 64'h0be2547406bf646c;
        7'h35: data_output <= 64'h0be2557506bf656d;
        7'h36: data_output <= 64'h0be2567606bf666e;
        7'h37: data_output <= 64'h0be2577706bf676f;
        7'h38: data_output <= 64'h0be258780c7f7078;
        7'h39: data_output <= 64'h0be259790c7f7179;
        7'h3a: data_output <= 64'h0be25a7a0c7f727a;
        7'h3b: data_output <= 64'h0be25b7b0c7f737b;
        7'h3c: data_output <= 64'h0be25c7c0c7f747c;
        7'h3d: data_output <= 64'h0be25d7d0c7f757d;
        7'h3e: data_output <= 64'h0be25e7e0c7f767e;
        7'h3f: data_output <= 64'h0be25f7f0c7f777f;
        7'h40: data_output <= 64'h077380a00a588088;
        7'h41: data_output <= 64'h077381a10a588189;
        7'h42: data_output <= 64'h077382a20a58828a;
        7'h43: data_output <= 64'h077383a30a58838b;
        7'h44: data_output <= 64'h077384a40a58848c;
        7'h45: data_output <= 64'h077385a50a58858d;
        7'h46: data_output <= 64'h077386a60a58868e;
        7'h47: data_output <= 64'h077387a70a58878f;
        7'h48: data_output <= 64'h077388a803f99098;
        7'h49: data_output <= 64'h077389a903f99199;
        7'h4a: data_output <= 64'h07738aaa03f9929a;
        7'h4b: data_output <= 64'h07738bab03f9939b;
        7'h4c: data_output <= 64'h07738cac03f9949c;
        7'h4d: data_output <= 64'h07738dad03f9959d;
        7'h4e: data_output <= 64'h07738eae03f9969e;
        7'h4f: data_output <= 64'h07738faf03f9979f;
        7'h50: data_output <= 64'h077390b002dca0a8;
        7'h51: data_output <= 64'h077391b102dca1a9;
        7'h52: data_output <= 64'h077392b202dca2aa;
        7'h53: data_output <= 64'h077393b302dca3ab;
        7'h54: data_output <= 64'h077394b402dca4ac;
        7'h55: data_output <= 64'h077395b502dca5ad;
        7'h56: data_output <= 64'h077396b602dca6ae;
        7'h57: data_output <= 64'h077397b702dca7af;
        7'h58: data_output <= 64'h077398b80260b0b8;
        7'h59: data_output <= 64'h077399b90260b1b9;
        7'h5a: data_output <= 64'h07739aba0260b2ba;
        7'h5b: data_output <= 64'h07739bbb0260b3bb;
        7'h5c: data_output <= 64'h07739cbc0260b4bc;
        7'h5d: data_output <= 64'h07739dbd0260b5bd;
        7'h5e: data_output <= 64'h07739ebe0260b6be;
        7'h5f: data_output <= 64'h07739fbf0260b7bf;
        7'h60: data_output <= 64'h072cc0e006fbc0c8;
        7'h61: data_output <= 64'h072cc1e106fbc1c9;
        7'h62: data_output <= 64'h072cc2e206fbc2ca;
        7'h63: data_output <= 64'h072cc3e306fbc3cb;
        7'h64: data_output <= 64'h072cc4e406fbc4cc;
        7'h65: data_output <= 64'h072cc5e506fbc5cd;
        7'h66: data_output <= 64'h072cc6e606fbc6ce;
        7'h67: data_output <= 64'h072cc7e706fbc7cf;
        7'h68: data_output <= 64'h072cc8e8019bd0d8;
        7'h69: data_output <= 64'h072cc9e9019bd1d9;
        7'h6a: data_output <= 64'h072ccaea019bd2da;
        7'h6b: data_output <= 64'h072ccbeb019bd3db;
        7'h6c: data_output <= 64'h072cccec019bd4dc;
        7'h6d: data_output <= 64'h072ccded019bd5dd;
        7'h6e: data_output <= 64'h072cceee019bd6de;
        7'h6f: data_output <= 64'h072ccfef019bd7df;
        7'h70: data_output <= 64'h072cd0f00c34e0e8;
        7'h71: data_output <= 64'h072cd1f10c34e1e9;
        7'h72: data_output <= 64'h072cd2f20c34e2ea;
        7'h73: data_output <= 64'h072cd3f30c34e3eb;
        7'h74: data_output <= 64'h072cd4f40c34e4ec;
        7'h75: data_output <= 64'h072cd5f50c34e5ed;
        7'h76: data_output <= 64'h072cd6f60c34e6ee;
        7'h77: data_output <= 64'h072cd7f70c34e7ef;
        7'h78: data_output <= 64'h072cd8f806def0f8;
        7'h79: data_output <= 64'h072cd9f906def1f9;
        7'h7a: data_output <= 64'h072cdafa06def2fa;
        7'h7b: data_output <= 64'h072cdbfb06def3fb;
        7'h7c: data_output <= 64'h072cdcfc06def4fc;
        7'h7d: data_output <= 64'h072cddfd06def5fd;
        7'h7e: data_output <= 64'h072cdefe06def6fe;
        7'h7f: data_output <= 64'h072cdfff06def7ff;
        default: data_output <= 64'h0000000000000000;
    endcase
end

endmodule
