`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 06:55:15 PM
// Design Name: 
// Module Name: inv_mixcol
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


module inv_mixcol(
input  [127:0] in,
    output [127:0] out
);

    // ==========================================
    // 1. Các hàm nhân trong GF(2^8)
    // ==========================================

    // --- Nhân 2 (x2) ---
    function [7:0] mb2;
        input [7:0] x;
        begin
            mb2 = (x[7] == 1'b1) ? ((x << 1) ^ 8'h1b) : (x << 1);
        end
    endfunction

    // --- Nhân 4 (x4) = mb2(mb2(x)) ---
    function [7:0] mb4;
        input [7:0] x;
        begin
            mb4 = mb2(mb2(x));
        end
    endfunction

    // --- Nhân 8 (x8) = mb2(mb4(x)) ---
    function [7:0] mb8;
        input [7:0] x;
        begin
            mb8 = mb2(mb4(x));
        end
    endfunction

    // --- Nhân 9 (0x09) = x8 ^ x1 ---
    function [7:0] mb9;
        input [7:0] x;
        begin
            mb9 = mb8(x) ^ x;
        end
    endfunction

    // --- Nhân 11 (0x0b) = x8 ^ x2 ^ x1 ---
    function [7:0] mb11;
        input [7:0] x;
        begin
            mb11 = mb8(x) ^ mb2(x) ^ x;
        end
    endfunction

    // --- Nhân 13 (0x0d) = x8 ^ x4 ^ x1 ---
    function [7:0] mb13;
        input [7:0] x;
        begin
            mb13 = mb8(x) ^ mb4(x) ^ x;
        end
    endfunction

    // --- Nhân 14 (0x0e) = x8 ^ x4 ^ x2 ---
    function [7:0] mb14;
        input [7:0] x;
        begin
            mb14 = mb8(x) ^ mb4(x) ^ mb2(x);
        end
    endfunction

    // ==========================================
    // 2. Tách input thành 16 byte
    // ==========================================
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

    // ==========================================
    // 3. Tính toán từng cột (Column)
    // ==========================================

    // --- Column 0 ---
    wire [7:0] m0  = mb14(s0) ^ mb11(s1) ^ mb13(s2) ^ mb9(s3);
    wire [7:0] m1  = mb9(s0)  ^ mb14(s1) ^ mb11(s2) ^ mb13(s3);
    wire [7:0] m2  = mb13(s0) ^ mb9(s1)  ^ mb14(s2) ^ mb11(s3);
    wire [7:0] m3  = mb11(s0) ^ mb13(s1) ^ mb9(s2)  ^ mb14(s3);

    // --- Column 1 ---
    wire [7:0] m4  = mb14(s4) ^ mb11(s5) ^ mb13(s6) ^ mb9(s7);
    wire [7:0] m5  = mb9(s4)  ^ mb14(s5) ^ mb11(s6) ^ mb13(s7);
    wire [7:0] m6  = mb13(s4) ^ mb9(s5)  ^ mb14(s6) ^ mb11(s7);
    wire [7:0] m7  = mb11(s4) ^ mb13(s5) ^ mb9(s6)  ^ mb14(s7);

    // --- Column 2 ---
    wire [7:0] m8  = mb14(s8) ^ mb11(s9) ^ mb13(s10) ^ mb9(s11);
    wire [7:0] m9  = mb9(s8)  ^ mb14(s9) ^ mb11(s10) ^ mb13(s11);
    wire [7:0] m10 = mb13(s8) ^ mb9(s9)  ^ mb14(s10) ^ mb11(s11);
    wire [7:0] m11 = mb11(s8) ^ mb13(s9) ^ mb9(s10)  ^ mb14(s11);

    // --- Column 3 ---
    wire [7:0] m12 = mb14(s12) ^ mb11(s13) ^ mb13(s14) ^ mb9(s15);
    wire [7:0] m13 = mb9(s12)  ^ mb14(s13) ^ mb11(s14) ^ mb13(s15);
    wire [7:0] m14 = mb13(s12) ^ mb9(s13)  ^ mb14(s14) ^ mb11(s15);
    wire [7:0] m15 = mb11(s12) ^ mb13(s13) ^ mb9(s14)  ^ mb14(s15);

    // ==========================================
    // 4. Ghép lại thành output 128-bit
    // ==========================================
    assign out = {
        m0,  m1,  m2,  m3,
        m4,  m5,  m6,  m7,
        m8,  m9,  m10, m11,
        m12, m13, m14, m15
    };
endmodule
