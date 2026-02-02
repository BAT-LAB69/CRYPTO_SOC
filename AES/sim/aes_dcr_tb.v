`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 07:12:42 PM
// Design Name: 
// Module Name: aes_dcr_tb
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


module aes_dcr_tb;
// 1. Khai báo tín hiệu
    reg  [127:0] in;  // Ciphertext đầu vào
    reg  [127:0] key; // Khóa giải mã
     reg  [127:0] iv;
    wire [127:0] out; // Plaintext đầu ra (Kết quả)

    // 2. Gọi Module giải mã (Unit Under Test)
    // Lưu ý: Tên module 'aes_decr' phải trùng với file code chính của bạn
    aes_dec_cbc uut (
        .in (in), 
        .key(key), 
        .iv(iv),
        .out(out)
    );

    // 3. Chương trình kiểm tra
    initial begin
        $display("==================================================");
        $display("       STARTING AES-128 DECRYPTION TEST           ");
        $display("==================================================");

        // Theo dõi tín hiệu thay đổi
        $monitor("Time=%0t | In=%h | Key=%h | Out=%h", $time, in, key, out);

        // --- Cài đặt giá trị (Dựa trên snippet của bạn) ---
        // Ciphertext (Input giải mã)
        in  = 128'h7649abac8119b246cee98e9b12e9197d;
        
        // Key
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        iv=128'h000102030405060708090A0B0C0D0E0F;
        // Chờ xử lý (AES combinational thường mất vài ns, để 100ns cho chắc)
        #100;

        // Kiểm tra kết quả (Expected Plaintext cho vector chuẩn này)
        // Plaintext chuẩn: 00112233445566778899aabbccddeeff
        if (out === 128'h6bc1bee22e409f96e93d7e117393172a) begin
            $display("\nResult: [PASS] Giai ma thanh cong!");
        end else begin
            $display("\nResult: [FAIL] Ket qua sai hoac chua on dinh.");
            $display("Expected: 00112233445566778899aabbccddeeff");
            $display("Received: %h", out);
        end
        
        $display("==================================================");
        $finish;
    end
endmodule
