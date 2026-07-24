`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 22:57:31
// Design Name: 
// Module Name: rom_gen_6
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


module rom_gen_6(
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
        7'h00: data_output <= 64'h02f6008008b20002;
        7'h01: data_output <= 64'h02f6018108b20103;
        7'h02: data_output <= 64'h02f6028201ae0406;
        7'h03: data_output <= 64'h02f6038301ae0507;
        7'h04: data_output <= 64'h02f60484022b080a;
        7'h05: data_output <= 64'h02f60585022b090b;
        7'h06: data_output <= 64'h02f60686034b0c0e;
        7'h07: data_output <= 64'h02f60787034b0d0f;
        7'h08: data_output <= 64'h02f60888081e1012;
        7'h09: data_output <= 64'h02f60989081e1113;
        7'h0a: data_output <= 64'h02f60a8a03671416;
        7'h0b: data_output <= 64'h02f60b8b03671517;
        7'h0c: data_output <= 64'h02f60c8c060e181a;
        7'h0d: data_output <= 64'h02f60d8d060e191b;
        7'h0e: data_output <= 64'h02f60e8e00691c1e;
        7'h0f: data_output <= 64'h02f60f8f00691d1f;
        7'h10: data_output <= 64'h02f6109001a62022;
        7'h11: data_output <= 64'h02f6119101a62123;
        7'h12: data_output <= 64'h02f61292024b2426;
        7'h13: data_output <= 64'h02f61393024b2527;
        7'h14: data_output <= 64'h02f6149400b1282a;
        7'h15: data_output <= 64'h02f6159500b1292b;
        7'h16: data_output <= 64'h02f616960c162c2e;
        7'h17: data_output <= 64'h02f617970c162d2f;
        7'h18: data_output <= 64'h02f618980bde3032;
        7'h19: data_output <= 64'h02f619990bde3133;
        7'h1a: data_output <= 64'h02f61a9a0b353436;
        7'h1b: data_output <= 64'h02f61b9b0b353537;
        7'h1c: data_output <= 64'h02f61c9c0626383a;
        7'h1d: data_output <= 64'h02f61d9d0626393b;
        7'h1e: data_output <= 64'h02f61e9e06753c3e;
        7'h1f: data_output <= 64'h02f61f9f06753d3f;
        7'h20: data_output <= 64'h02f620a00c0b4042;
        7'h21: data_output <= 64'h02f621a10c0b4143;
        7'h22: data_output <= 64'h02f622a2030a4446;
        7'h23: data_output <= 64'h02f623a3030a4547;
        7'h24: data_output <= 64'h02f624a40487484a;
        7'h25: data_output <= 64'h02f625a50487494b;
        7'h26: data_output <= 64'h02f626a60c6e4c4e;
        7'h27: data_output <= 64'h02f627a70c6e4d4f;
        7'h28: data_output <= 64'h02f628a809f85052;
        7'h29: data_output <= 64'h02f629a909f85153;
        7'h2a: data_output <= 64'h02f62aaa05cb5456;
        7'h2b: data_output <= 64'h02f62bab05cb5557;
        7'h2c: data_output <= 64'h02f62cac0aa7585a;
        7'h2d: data_output <= 64'h02f62dad0aa7595b;
        7'h2e: data_output <= 64'h02f62eae045f5c5e;
        7'h2f: data_output <= 64'h02f62faf045f5d5f;
        7'h30: data_output <= 64'h02f630b006cb6062;
        7'h31: data_output <= 64'h02f631b106cb6163;
        7'h32: data_output <= 64'h02f632b202846466;
        7'h33: data_output <= 64'h02f633b302846567;
        7'h34: data_output <= 64'h02f634b40999686a;
        7'h35: data_output <= 64'h02f635b50999696b;
        7'h36: data_output <= 64'h02f636b6015d6c6e;
        7'h37: data_output <= 64'h02f637b7015d6d6f;
        7'h38: data_output <= 64'h02f638b801a27072;
        7'h39: data_output <= 64'h02f639b901a27173;
        7'h3a: data_output <= 64'h02f63aba01497476;
        7'h3b: data_output <= 64'h02f63bbb01497577;
        7'h3c: data_output <= 64'h02f63cbc0c65787a;
        7'h3d: data_output <= 64'h02f63dbd0c65797b;
        7'h3e: data_output <= 64'h02f63ebe0cb67c7e;
        7'h3f: data_output <= 64'h02f63fbf0cb67d7f;
        7'h40: data_output <= 64'h02f640c003318082;
        7'h41: data_output <= 64'h02f641c103318183;
        7'h42: data_output <= 64'h02f642c204498486;
        7'h43: data_output <= 64'h02f643c304498587;
        7'h44: data_output <= 64'h02f644c4025b888a;
        7'h45: data_output <= 64'h02f645c5025b898b;
        7'h46: data_output <= 64'h02f646c602628c8e;
        7'h47: data_output <= 64'h02f647c702628d8f;
        7'h48: data_output <= 64'h02f648c8052a9092;
        7'h49: data_output <= 64'h02f649c9052a9193;
        7'h4a: data_output <= 64'h02f64aca07fc9496;
        7'h4b: data_output <= 64'h02f64bcb07fc9597;
        7'h4c: data_output <= 64'h02f64ccc0748989a;
        7'h4d: data_output <= 64'h02f64dcd0748999b;
        7'h4e: data_output <= 64'h02f64ece01809c9e;
        7'h4f: data_output <= 64'h02f64fcf01809d9f;
        7'h50: data_output <= 64'h02f650d00842a0a2;
        7'h51: data_output <= 64'h02f651d10842a1a3;
        7'h52: data_output <= 64'h02f652d20c79a4a6;
        7'h53: data_output <= 64'h02f653d30c79a5a7;
        7'h54: data_output <= 64'h02f654d404c2a8aa;
        7'h55: data_output <= 64'h02f655d504c2a9ab;
        7'h56: data_output <= 64'h02f656d607caacae;
        7'h57: data_output <= 64'h02f657d707caadaf;
        7'h58: data_output <= 64'h02f658d80997b0b2;
        7'h59: data_output <= 64'h02f659d90997b1b3;
        7'h5a: data_output <= 64'h02f65ada00dcb4b6;
        7'h5b: data_output <= 64'h02f65bdb00dcb5b7;
        7'h5c: data_output <= 64'h02f65cdc085eb8ba;
        7'h5d: data_output <= 64'h02f65ddd085eb9bb;
        7'h5e: data_output <= 64'h02f65ede0686bcbe;
        7'h5f: data_output <= 64'h02f65fdf0686bdbf;
        7'h60: data_output <= 64'h02f660e00860c0c2;
        7'h61: data_output <= 64'h02f661e10860c1c3;
        7'h62: data_output <= 64'h02f662e20707c4c6;
        7'h63: data_output <= 64'h02f663e30707c5c7;
        7'h64: data_output <= 64'h02f664e40803c8ca;
        7'h65: data_output <= 64'h02f665e50803c9cb;
        7'h66: data_output <= 64'h02f666e6031accce;
        7'h67: data_output <= 64'h02f667e7031acdcf;
        7'h68: data_output <= 64'h02f668e8071bd0d2;
        7'h69: data_output <= 64'h02f669e9071bd1d3;
        7'h6a: data_output <= 64'h02f66aea09abd4d6;
        7'h6b: data_output <= 64'h02f66beb09abd5d7;
        7'h6c: data_output <= 64'h02f66cec099bd8da;
        7'h6d: data_output <= 64'h02f66ded099bd9db;
        7'h6e: data_output <= 64'h02f66eee01dedcde;
        7'h6f: data_output <= 64'h02f66fef01dedddf;
        7'h70: data_output <= 64'h02f670f00c95e0e2;
        7'h71: data_output <= 64'h02f671f10c95e1e3;
        7'h72: data_output <= 64'h02f672f20bcde4e6;
        7'h73: data_output <= 64'h02f673f30bcde5e7;
        7'h74: data_output <= 64'h02f674f403e4e8ea;
        7'h75: data_output <= 64'h02f675f503e4e9eb;
        7'h76: data_output <= 64'h02f676f603dfecee;
        7'h77: data_output <= 64'h02f677f703dfedef;
        7'h78: data_output <= 64'h02f678f803bef0f2;
        7'h79: data_output <= 64'h02f679f903bef1f3;
        7'h7a: data_output <= 64'h02f67afa074df4f6;
        7'h7b: data_output <= 64'h02f67bfb074df5f7;
        7'h7c: data_output <= 64'h02f67cfc05f2f8fa;
        7'h7d: data_output <= 64'h02f67dfd05f2f9fb;
        7'h7e: data_output <= 64'h02f67efe065cfcfe;
        7'h7f: data_output <= 64'h02f67fff065cfdff;
        default: data_output <= 64'h0000000000000000;
    endcase
end

endmodule
