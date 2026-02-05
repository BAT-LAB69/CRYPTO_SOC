`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 06:26:14 PM
// Design Name: 
// Module Name: shiftrow_inver
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


module shiftrow_inver(
input  [127:0] in,
    output [127:0] out
);

    // ===============================
    // 1️⃣ Tách state thành 16 byte
    // ===============================
    wire [7:0] s0  = in[127:120];
    wire [7:0] s1  = in[119:112];
    wire [7:0] s2  = in[111:104];
    wire [7:0] s3  = in[103:96];

    wire [7:0] s4  = in[95:88];
    wire [7:0] s5  = in[87:80];
    wire [7:0] s6  = in[79:72];
    wire [7:0] s7  = in[71:64];

    wire [7:0] s8  = in[63:56];
    wire [7:0] s9  = in[55:48];
    wire [7:0] s10 = in[47:40];
    wire [7:0] s11 = in[39:32];

    wire [7:0] s12 = in[31:24];
    wire [7:0] s13 = in[23:16];
    wire [7:0] s14 = in[15:8];
    wire [7:0] s15 = in[7:0];

    // ===============================
    // 2️⃣ ShiftRows (RIGHT SHIFT)
    // ===============================
    // Row 0: no shift
    // Row 1: shift right by 1
    // Row 2: shift right by 2
    // Row 3: shift right by 3

    assign out = {
        // Column 0
        s0,   s13,  s10,  s7,

        // Column 1
        s4,   s1,   s14,  s11,

        // Column 2
        s8,   s5,   s2,   s15,

        // Column 3
        s12,  s9,   s6,   s3
    };

endmodule
