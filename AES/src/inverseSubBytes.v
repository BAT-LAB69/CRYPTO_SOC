`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 06:52:35 PM
// Design Name: 
// Module Name: inverseSubBytes
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


module inverseSubBytes(
input  [127:0] in,
    output [127:0] out
);

    // 1. Tách input thành 16 byte
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

    // 2. Dây nối kết quả đầu ra
    wire [7:0] sb0, sb1, sb2, sb3;
    wire [7:0] sb4, sb5, sb6, sb7;
    wire [7:0] sb8, sb9, sb10, sb11;
    wire [7:0] sb12, sb13, sb14, sb15;

    // 3. Gọi 16 module sbox_inver
    // Lưu ý: Tên port phải khớp với module sbox_inver(selector, sbout)
    sbox_inver u0  (.selector(s0),  .sbout(sb0));
    sbox_inver u1  (.selector(s1),  .sbout(sb1));
    sbox_inver u2  (.selector(s2),  .sbout(sb2));
    sbox_inver u3  (.selector(s3),  .sbout(sb3));

    sbox_inver u4  (.selector(s4),  .sbout(sb4));
    sbox_inver u5  (.selector(s5),  .sbout(sb5));
    sbox_inver u6  (.selector(s6),  .sbout(sb6));
    sbox_inver u7  (.selector(s7),  .sbout(sb7));

    sbox_inver u8  (.selector(s8),  .sbout(sb8));
    sbox_inver u9  (.selector(s9),  .sbout(sb9));
    sbox_inver u10 (.selector(s10), .sbout(sb10));
    sbox_inver u11 (.selector(s11), .sbout(sb11));

    sbox_inver u12 (.selector(s12), .sbout(sb12));
    sbox_inver u13 (.selector(s13), .sbout(sb13));
    sbox_inver u14 (.selector(s14), .sbout(sb14));
    sbox_inver u15 (.selector(s15), .sbout(sb15));

    // 4. Ghép lại thành 128-bit output
    assign out = {
        sb0,  sb1,  sb2,  sb3,
        sb4,  sb5,  sb6,  sb7,
        sb8,  sb9,  sb10, sb11,
        sb12, sb13, sb14, sb15
    };
endmodule
