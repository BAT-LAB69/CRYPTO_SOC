`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2026 11:16:47 PM
// Design Name: 
// Module Name: haraka_256_v2_tb
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


module haraka_256_v2_tb;
reg  [255:0] test_in;
    wire [255:0] test_out;
    reg  [255:0] expected_out;

    // Khởi tạo module Haraka-256 v2 cần test
    haraka_256_v2 uut (
        .in(test_in),
        .out(test_out)
    );

    initial begin
        // 1. Nạp Test Vector từ đề bài 
        // Thứ tự byte: byte đầu tiên (00) nằm ở MSB [255:248] theo cấu trúc AES của bạn
        test_in = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        
        // 2. Nạp kết quả kỳ vọng (Expected Output) 
        expected_out = 256'h8027ccb87949774b78d0545fb72bf70c695c2a0923cbd47bba1159efbf2b2c1c;

        // Chờ một khoảng thời gian để mạch tổ hợp tính toán xong
        #10;

        // 3. Hiển thị và so sánh kết quả
        $display("---------------------------------------------------------");
        $display("Haraka-256 v2 Hardware Testbench");
        $display("---------------------------------------------------------");
        $display("Input:    %h", test_in);
        $display("Output:   %h", test_out);
        $display("Expected: %h", expected_out);
        $display("---------------------------------------------------------");

        if (test_out === expected_out) begin
            $display("RESULT: SUCCESS! Hardware match with test vector.");
        end else begin
            $display("RESULT: FAILED! Check your Mixing Layer or S-Box implementation.");
            
            // Chỉ ra vị trí lỗi nếu có
            if (test_out[255:128] !== expected_out[255:128]) 
                $display("Error detected in Block 0 (Left 128-bit)");
            if (test_out[127:0] !== expected_out[127:0]) 
                $display("Error detected in Block 1 (Right 128-bit)");
        end
        $display("---------------------------------------------------------");

        #100000 ;$finish;
end
   
endmodule
