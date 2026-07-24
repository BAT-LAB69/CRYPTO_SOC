`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 22:57:14
// Design Name: 
// Module Name: rom_gen_5
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

module rom_gen_5(
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
        7'h00: data_output <= 64'h05ed004004c70004;
        7'h01: data_output <= 64'h05ed014104c70105;
        7'h02: data_output <= 64'h05ed024204c70206;
        7'h03: data_output <= 64'h05ed034304c70307;
        7'h04: data_output <= 64'h05ed0444028c080c;
        7'h05: data_output <= 64'h05ed0545028c090d;
        7'h06: data_output <= 64'h05ed0646028c0a0e;
        7'h07: data_output <= 64'h05ed0747028c0b0f;
        7'h08: data_output <= 64'h05ed08480ad91014;
        7'h09: data_output <= 64'h05ed09490ad91115;
        7'h0a: data_output <= 64'h05ed0a4a0ad91216;
        7'h0b: data_output <= 64'h05ed0b4b0ad91317;
        7'h0c: data_output <= 64'h05ed0c4c03f7181c;
        7'h0d: data_output <= 64'h05ed0d4d03f7191d;
        7'h0e: data_output <= 64'h05ed0e4e03f71a1e;
        7'h0f: data_output <= 64'h05ed0f4f03f71b1f;
        7'h10: data_output <= 64'h05ed105007f42024;
        7'h11: data_output <= 64'h05ed115107f42125;
        7'h12: data_output <= 64'h05ed125207f42226;
        7'h13: data_output <= 64'h05ed135307f42327;
        7'h14: data_output <= 64'h05ed145405d3282c;
        7'h15: data_output <= 64'h05ed155505d3292d;
        7'h16: data_output <= 64'h05ed165605d32a2e;
        7'h17: data_output <= 64'h05ed175705d32b2f;
        7'h18: data_output <= 64'h05ed18580be73034;
        7'h19: data_output <= 64'h05ed19590be73135;
        7'h1a: data_output <= 64'h05ed1a5a0be73236;
        7'h1b: data_output <= 64'h05ed1b5b0be73337;
        7'h1c: data_output <= 64'h05ed1c5c06f9383c;
        7'h1d: data_output <= 64'h05ed1d5d06f9393d;
        7'h1e: data_output <= 64'h05ed1e5e06f93a3e;
        7'h1f: data_output <= 64'h05ed1f5f06f93b3f;
        7'h20: data_output <= 64'h05ed206002044044;
        7'h21: data_output <= 64'h05ed216102044145;
        7'h22: data_output <= 64'h05ed226202044246;
        7'h23: data_output <= 64'h05ed236302044347;
        7'h24: data_output <= 64'h05ed24640cf9484c;
        7'h25: data_output <= 64'h05ed25650cf9494d;
        7'h26: data_output <= 64'h05ed26660cf94a4e;
        7'h27: data_output <= 64'h05ed27670cf94b4f;
        7'h28: data_output <= 64'h05ed28680bc15054;
        7'h29: data_output <= 64'h05ed29690bc15155;
        7'h2a: data_output <= 64'h05ed2a6a0bc15256;
        7'h2b: data_output <= 64'h05ed2b6b0bc15357;
        7'h2c: data_output <= 64'h05ed2c6c0a67585c;
        7'h2d: data_output <= 64'h05ed2d6d0a67595d;
        7'h2e: data_output <= 64'h05ed2e6e0a675a5e;
        7'h2f: data_output <= 64'h05ed2f6f0a675b5f;
        7'h30: data_output <= 64'h05ed307006af6064;
        7'h31: data_output <= 64'h05ed317106af6165;
        7'h32: data_output <= 64'h05ed327206af6266;
        7'h33: data_output <= 64'h05ed337306af6367;
        7'h34: data_output <= 64'h05ed34740877686c;
        7'h35: data_output <= 64'h05ed35750877696d;
        7'h36: data_output <= 64'h05ed367608776a6e;
        7'h37: data_output <= 64'h05ed377708776b6f;
        7'h38: data_output <= 64'h05ed3878007e7074;
        7'h39: data_output <= 64'h05ed3979007e7175;
        7'h3a: data_output <= 64'h05ed3a7a007e7276;
        7'h3b: data_output <= 64'h05ed3b7b007e7377;
        7'h3c: data_output <= 64'h05ed3c7c05bd787c;
        7'h3d: data_output <= 64'h05ed3d7d05bd797d;
        7'h3e: data_output <= 64'h05ed3e7e05bd7a7e;
        7'h3f: data_output <= 64'h05ed3f7f05bd7b7f;
        7'h40: data_output <= 64'h016780c009ac8084;
        7'h41: data_output <= 64'h016781c109ac8185;
        7'h42: data_output <= 64'h016782c209ac8286;
        7'h43: data_output <= 64'h016783c309ac8387;
        7'h44: data_output <= 64'h016784c40ca7888c;
        7'h45: data_output <= 64'h016785c50ca7898d;
        7'h46: data_output <= 64'h016786c60ca78a8e;
        7'h47: data_output <= 64'h016787c70ca78b8f;
        7'h48: data_output <= 64'h016788c80bf29094;
        7'h49: data_output <= 64'h016789c90bf29195;
        7'h4a: data_output <= 64'h01678aca0bf29296;
        7'h4b: data_output <= 64'h01678bcb0bf29397;
        7'h4c: data_output <= 64'h01678ccc033e989c;
        7'h4d: data_output <= 64'h01678dcd033e999d;
        7'h4e: data_output <= 64'h01678ece033e9a9e;
        7'h4f: data_output <= 64'h01678fcf033e9b9f;
        7'h50: data_output <= 64'h016790d0006ba0a4;
        7'h51: data_output <= 64'h016791d1006ba1a5;
        7'h52: data_output <= 64'h016792d2006ba2a6;
        7'h53: data_output <= 64'h016793d3006ba3a7;
        7'h54: data_output <= 64'h016794d40774a8ac;
        7'h55: data_output <= 64'h016795d50774a9ad;
        7'h56: data_output <= 64'h016796d60774aaae;
        7'h57: data_output <= 64'h016797d70774abaf;
        7'h58: data_output <= 64'h016798d80c0ab0b4;
        7'h59: data_output <= 64'h016799d90c0ab1b5;
        7'h5a: data_output <= 64'h01679ada0c0ab2b6;
        7'h5b: data_output <= 64'h01679bdb0c0ab3b7;
        7'h5c: data_output <= 64'h01679cdc094ab8bc;
        7'h5d: data_output <= 64'h01679ddd094ab9bd;
        7'h5e: data_output <= 64'h01679ede094ababe;
        7'h5f: data_output <= 64'h01679fdf094abbbf;
        7'h60: data_output <= 64'h0167a0e00b73c0c4;
        7'h61: data_output <= 64'h0167a1e10b73c1c5;
        7'h62: data_output <= 64'h0167a2e20b73c2c6;
        7'h63: data_output <= 64'h0167a3e30b73c3c7;
        7'h64: data_output <= 64'h0167a4e403c1c8cc;
        7'h65: data_output <= 64'h0167a5e503c1c9cd;
        7'h66: data_output <= 64'h0167a6e603c1cace;
        7'h67: data_output <= 64'h0167a7e703c1cbcf;
        7'h68: data_output <= 64'h0167a8e8071dd0d4;
        7'h69: data_output <= 64'h0167a9e9071dd1d5;
        7'h6a: data_output <= 64'h0167aaea071dd2d6;
        7'h6b: data_output <= 64'h0167abeb071dd3d7;
        7'h6c: data_output <= 64'h0167acec0a2cd8dc;
        7'h6d: data_output <= 64'h0167aded0a2cd9dd;
        7'h6e: data_output <= 64'h0167aeee0a2cdade;
        7'h6f: data_output <= 64'h0167afef0a2cdbdf;
        7'h70: data_output <= 64'h0167b0f001c0e0e4;
        7'h71: data_output <= 64'h0167b1f101c0e1e5;
        7'h72: data_output <= 64'h0167b2f201c0e2e6;
        7'h73: data_output <= 64'h0167b3f301c0e3e7;
        7'h74: data_output <= 64'h0167b4f408d8e8ec;
        7'h75: data_output <= 64'h0167b5f508d8e9ed;
        7'h76: data_output <= 64'h0167b6f608d8eaee;
        7'h77: data_output <= 64'h0167b7f708d8ebef;
        7'h78: data_output <= 64'h0167b8f802a5f0f4;
        7'h79: data_output <= 64'h0167b9f902a5f1f5;
        7'h7a: data_output <= 64'h0167bafa02a5f2f6;
        7'h7b: data_output <= 64'h0167bbfb02a5f3f7;
        7'h7c: data_output <= 64'h0167bcfc0806f8fc;
        7'h7d: data_output <= 64'h0167bdfd0806f9fd;
        7'h7e: data_output <= 64'h0167befe0806fafe;
        7'h7f: data_output <= 64'h0167bfff0806fbff;
        default: data_output <= 64'h0000000000000000;
    endcase
end

endmodule
