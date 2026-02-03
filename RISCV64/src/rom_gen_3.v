`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2024 22:56:56
// Design Name: 
// Module Name: rom_gen_3
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


module rom_gen_3(
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
        7'h00: data_output <= 64'h074500100c560010;
        7'h01: data_output <= 64'h074501110c560111;
        7'h02: data_output <= 64'h074502120c560212;
        7'h03: data_output <= 64'h074503130c560313;
        7'h04: data_output <= 64'h074504140c560414;
        7'h05: data_output <= 64'h074505150c560515;
        7'h06: data_output <= 64'h074506160c560616;
        7'h07: data_output <= 64'h074507170c560717;
        7'h08: data_output <= 64'h074508180c560818;
        7'h09: data_output <= 64'h074509190c560919;
        7'h0a: data_output <= 64'h07450a1a0c560a1a;
        7'h0b: data_output <= 64'h07450b1b0c560b1b;
        7'h0c: data_output <= 64'h07450c1c0c560c1c;
        7'h0d: data_output <= 64'h07450d1d0c560d1d;
        7'h0e: data_output <= 64'h07450e1e0c560e1e;
        7'h0f: data_output <= 64'h07450f1f0c560f1f;
        7'h10: data_output <= 64'h05c22030026e2030;
        7'h11: data_output <= 64'h05c22131026e2131;
        7'h12: data_output <= 64'h05c22232026e2232;
        7'h13: data_output <= 64'h05c22333026e2333;
        7'h14: data_output <= 64'h05c22434026e2434;
        7'h15: data_output <= 64'h05c22535026e2535;
        7'h16: data_output <= 64'h05c22636026e2636;
        7'h17: data_output <= 64'h05c22737026e2737;
        7'h18: data_output <= 64'h05c22838026e2838;
        7'h19: data_output <= 64'h05c22939026e2939;
        7'h1a: data_output <= 64'h05c22a3a026e2a3a;
        7'h1b: data_output <= 64'h05c22b3b026e2b3b;
        7'h1c: data_output <= 64'h05c22c3c026e2c3c;
        7'h1d: data_output <= 64'h05c22d3d026e2d3d;
        7'h1e: data_output <= 64'h05c22e3e026e2e3e;
        7'h1f: data_output <= 64'h05c22f3f026e2f3f;
        7'h20: data_output <= 64'h04b2405006294050;
        7'h21: data_output <= 64'h04b2415106294151;
        7'h22: data_output <= 64'h04b2425206294252;
        7'h23: data_output <= 64'h04b2435306294353;
        7'h24: data_output <= 64'h04b2445406294454;
        7'h25: data_output <= 64'h04b2455506294555;
        7'h26: data_output <= 64'h04b2465606294656;
        7'h27: data_output <= 64'h04b2475706294757;
        7'h28: data_output <= 64'h04b2485806294858;
        7'h29: data_output <= 64'h04b2495906294959;
        7'h2a: data_output <= 64'h04b24a5a06294a5a;
        7'h2b: data_output <= 64'h04b24b5b06294b5b;
        7'h2c: data_output <= 64'h04b24c5c06294c5c;
        7'h2d: data_output <= 64'h04b24d5d06294d5d;
        7'h2e: data_output <= 64'h04b24e5e06294e5e;
        7'h2f: data_output <= 64'h04b24f5f06294f5f;
        7'h30: data_output <= 64'h093f607000b66070;
        7'h31: data_output <= 64'h093f617100b66171;
        7'h32: data_output <= 64'h093f627200b66272;
        7'h33: data_output <= 64'h093f637300b66373;
        7'h34: data_output <= 64'h093f647400b66474;
        7'h35: data_output <= 64'h093f657500b66575;
        7'h36: data_output <= 64'h093f667600b66676;
        7'h37: data_output <= 64'h093f677700b66777;
        7'h38: data_output <= 64'h093f687800b66878;
        7'h39: data_output <= 64'h093f697900b66979;
        7'h3a: data_output <= 64'h093f6a7a00b66a7a;
        7'h3b: data_output <= 64'h093f6b7b00b66b7b;
        7'h3c: data_output <= 64'h093f6c7c00b66c7c;
        7'h3d: data_output <= 64'h093f6d7d00b66d7d;
        7'h3e: data_output <= 64'h093f6e7e00b66e7e;
        7'h3f: data_output <= 64'h093f6f7f00b66f7f;
        7'h40: data_output <= 64'h0c4b809003c28090;
        7'h41: data_output <= 64'h0c4b819103c28191;
        7'h42: data_output <= 64'h0c4b829203c28292;
        7'h43: data_output <= 64'h0c4b839303c28393;
        7'h44: data_output <= 64'h0c4b849403c28494;
        7'h45: data_output <= 64'h0c4b859503c28595;
        7'h46: data_output <= 64'h0c4b869603c28696;
        7'h47: data_output <= 64'h0c4b879703c28797;
        7'h48: data_output <= 64'h0c4b889803c28898;
        7'h49: data_output <= 64'h0c4b899903c28999;
        7'h4a: data_output <= 64'h0c4b8a9a03c28a9a;
        7'h4b: data_output <= 64'h0c4b8b9b03c28b9b;
        7'h4c: data_output <= 64'h0c4b8c9c03c28c9c;
        7'h4d: data_output <= 64'h0c4b8d9d03c28d9d;
        7'h4e: data_output <= 64'h0c4b8e9e03c28e9e;
        7'h4f: data_output <= 64'h0c4b8f9f03c28f9f;
        7'h50: data_output <= 64'h06d8a0b0084fa0b0;
        7'h51: data_output <= 64'h06d8a1b1084fa1b1;
        7'h52: data_output <= 64'h06d8a2b2084fa2b2;
        7'h53: data_output <= 64'h06d8a3b3084fa3b3;
        7'h54: data_output <= 64'h06d8a4b4084fa4b4;
        7'h55: data_output <= 64'h06d8a5b5084fa5b5;
        7'h56: data_output <= 64'h06d8a6b6084fa6b6;
        7'h57: data_output <= 64'h06d8a7b7084fa7b7;
        7'h58: data_output <= 64'h06d8a8b8084fa8b8;
        7'h59: data_output <= 64'h06d8a9b9084fa9b9;
        7'h5a: data_output <= 64'h06d8aaba084faaba;
        7'h5b: data_output <= 64'h06d8abbb084fabbb;
        7'h5c: data_output <= 64'h06d8acbc084facbc;
        7'h5d: data_output <= 64'h06d8adbd084fadbd;
        7'h5e: data_output <= 64'h06d8aebe084faebe;
        7'h5f: data_output <= 64'h06d8afbf084fafbf;
        7'h60: data_output <= 64'h0a93c0d0073fc0d0;
        7'h61: data_output <= 64'h0a93c1d1073fc1d1;
        7'h62: data_output <= 64'h0a93c2d2073fc2d2;
        7'h63: data_output <= 64'h0a93c3d3073fc3d3;
        7'h64: data_output <= 64'h0a93c4d4073fc4d4;
        7'h65: data_output <= 64'h0a93c5d5073fc5d5;
        7'h66: data_output <= 64'h0a93c6d6073fc6d6;
        7'h67: data_output <= 64'h0a93c7d7073fc7d7;
        7'h68: data_output <= 64'h0a93c8d8073fc8d8;
        7'h69: data_output <= 64'h0a93c9d9073fc9d9;
        7'h6a: data_output <= 64'h0a93cada073fcada;
        7'h6b: data_output <= 64'h0a93cbdb073fcbdb;
        7'h6c: data_output <= 64'h0a93ccdc073fccdc;
        7'h6d: data_output <= 64'h0a93cddd073fcddd;
        7'h6e: data_output <= 64'h0a93cede073fcede;
        7'h6f: data_output <= 64'h0a93cfdf073fcfdf;
        7'h70: data_output <= 64'h00abe0f005bce0f0;
        7'h71: data_output <= 64'h00abe1f105bce1f1;
        7'h72: data_output <= 64'h00abe2f205bce2f2;
        7'h73: data_output <= 64'h00abe3f305bce3f3;
        7'h74: data_output <= 64'h00abe4f405bce4f4;
        7'h75: data_output <= 64'h00abe5f505bce5f5;
        7'h76: data_output <= 64'h00abe6f605bce6f6;
        7'h77: data_output <= 64'h00abe7f705bce7f7;
        7'h78: data_output <= 64'h00abe8f805bce8f8;
        7'h79: data_output <= 64'h00abe9f905bce9f9;
        7'h7a: data_output <= 64'h00abeafa05bceafa;
        7'h7b: data_output <= 64'h00abebfb05bcebfb;
        7'h7c: data_output <= 64'h00abecfc05bcecfc;
        7'h7d: data_output <= 64'h00abedfd05bcedfd;
        7'h7e: data_output <= 64'h00abeefe05bceefe;
        7'h7f: data_output <= 64'h00abefff05bcefff;
        default: data_output <= 64'h0000000000000000;
    endcase
end

endmodule
