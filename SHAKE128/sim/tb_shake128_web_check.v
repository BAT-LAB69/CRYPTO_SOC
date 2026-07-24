//`timescale 1ns / 1ps

//module  tb_shake128_web_check;

//    // --- 1. Tín hiệu kết nối ---
//    reg          clk;
//    reg          rst_n;
    
//    // Input 64-bit 
//    reg  [63:0]  i_data;
//    reg          i_valid;
//    reg          i_last;
//    wire         o_ready;
    
//    // Output 128-bit 
//    wire [127:0] o_data; // Sửa thành 128 bit
//    wire         o_valid;
//    reg          i_ack;
//    wire         o_squeeze;

//    // --- 2. Dữ liệu Test ---
//    reg [63:0] test_vectors [0:9];
//    reg [63:0] expected_out_0 [0:9]; // Word 0 (64-bit thấp của output)
//    reg [63:0] expected_out_1 [0:9]; // Word 1 (64-bit cao của output)
    
//    integer i;
//    integer pass_count;
//    integer fail_count;

//    // --- 3. Instance Module SHAKE128 (Hybrid) ---
//    shake128_top dut (
//        .i_clk(clk),
//        .i_rst_n(rst_n),
//        .i_data(i_data),
//        .i_valid(i_valid),
//        .i_last(i_last),
//        .o_ready(o_ready),
//        .o_data(o_data), // Kết nối với dây 128-bit
//        .o_valid(o_valid),
//        .i_ack(i_ack),
//        .o_squeeze_mode(o_squeeze)
//    );

//    // --- 4. Tạo xung Clock ---
//    always #5 clk = ~clk;

//    // --- 5. Hàm đảo byte cho Input 64-bit ---
//    function [63:0] swap_endian;
//        input [63:0] in;
//        begin
//            swap_endian = {in[7:0], in[15:8], in[23:16], in[31:24], 
//                           in[39:32], in[47:40], in[55:48], in[63:56]};
//        end
//    endfunction

//    // --- 6. Chuẩn bị bộ dữ liệu Test ---
//    initial begin
//        // --- INPUTS (64-bit Hex Strings) ---
//        test_vectors[0] = 64'h0000000000000000;
//        test_vectors[1] = 64'hFFFFFFFFFFFFFFFF;
//        test_vectors[2] = 64'h0123456789ABCDEF;
//        test_vectors[3] = 64'hFEDCBA9876543210;
//        test_vectors[4] = 64'hAAAAAAAAAAAAAAAA;
//        test_vectors[5] = 64'h5555555555555555;
//        test_vectors[6] = 64'h1234567800000000;
//        test_vectors[7] = 64'h0000000087654321;
//        test_vectors[8] = 64'h0000FFFFFFFF0000;
//        test_vectors[9] = 64'h8000000000000001;

//        // --- EXPECTED OUTPUTS ---
//        // Word 0 (64-bit đầu)
//        expected_out_0[0] = 64'h985c34da66b6247a; 
//        expected_out_0[1] = 64'h9279fac13be3ed9a;
//        expected_out_0[2] = 64'h8ae06141e32bf7f1; 
//        expected_out_0[3] = 64'h9b2a195a966dc40a; 
//        expected_out_0[4] = 64'h01b673a1cdaa82d6;
//        expected_out_0[5] = 64'h04a82f11900d019a;
//        expected_out_0[6] = 64'hf56f3eef13fcaf57;
//        expected_out_0[7] = 64'hb82a5efa2e21c5c3;
//        expected_out_0[8] = 64'h857f6a8adb27b0d8;
//        expected_out_0[9] = 64'h25b7403f38810de0;

//        // Word 1 (64-bit sau)
//        expected_out_1[0] = 64'h1aa514fdaa00a4c3;
//        expected_out_1[1] = 64'h53732a2138a84fdd;
//        expected_out_1[2] = 64'h30a2ac8c7f73ff80; 
//        expected_out_1[3] = 64'hc3a1f9387d18255b; 
//        expected_out_1[4] = 64'h169a7e05208dac86;
//        expected_out_1[5] = 64'hbeb227d8441b9823;
//        expected_out_1[6] = 64'hb3c3bb0b4a91f811;
//        expected_out_1[7] = 64'h67125e2b9c1368b7;
//        expected_out_1[8] = 64'hb089f7d480ebb4fa;
//        expected_out_1[9] = 64'haf002d515fdb2249;
//    end

//    // --- 7. Task kiểm tra kết quả (Nâng cấp cho 128-bit) ---
//    task check_result_128;
//        input [31:0] test_id;
//        input [127:0] actual_128; // Input thực tế là 128 bit
//        input [63:0] exp_low;     // Word 0 mong đợi
//        input [63:0] exp_high;    // Word 1 mong đợi
//        begin
//            // Kiểm tra 64 bit thấp
//            if (actual_128[63:0] === exp_low) begin
//                $display("    [Low 64b]  Check: MATCH (%h)", actual_128[63:0]);
//            end else begin
//                $display("    [Low 64b]  Check: ERROR !!!");
//                $display("             Actual:   %h", actual_128[63:0]);
//                $display("             Expected: %h", exp_low);
//                fail_count = fail_count + 1;
//            end

//            // Kiểm tra 64 bit cao
//            if (actual_128[127:64] === exp_high) begin
//                $display("    [High 64b] Check: MATCH (%h)", actual_128[127:64]);
//            end else begin
//                $display("    [High 64b] Check: ERROR !!!");
//                $display("             Actual:   %h", actual_128[127:64]);
//                $display("             Expected: %h", exp_high);
//                fail_count = fail_count + 1;
//            end
//        end
//    endtask

//    // --- 8. Kịch bản chạy Test ---
//    initial begin
//        $display("==========================================================");
//        $display("   SHAKE128 VERIFICATION (In: 64b / Out: 128b)            ");
//        $display("==========================================================");

//        clk = 0;
//        rst_n = 0;
//        i_valid = 0; i_data = 0; i_last = 0; i_ack = 0;
//        pass_count = 0;
//        fail_count = 0;

//        #20; rst_n = 1; #10;

//        // --- Vòng lặp chạy 10 Test Cases ---
//        for (i = 0; i < 10; i = i + 1) begin
//            $display("\n--- Test Case #%0d: Input = %h ---", i, test_vectors[i]);
            
//            // 1. Nạp dữ liệu 64-bit (Có đảo byte)
//            wait(o_ready);
//            @(posedge clk);
//            i_valid = 1;
//            i_last  = 1; 
//            i_data  = swap_endian(test_vectors[i]); 
            
//            @(posedge clk);
//            i_valid = 0;
//            i_last  = 0;
            
//            // 2. Chờ kết quả
//            wait(o_valid);
            
//            // 3. Kiểm tra Output 128-bit NGAY LẬP TỨC
//            // o_data bây giờ chứa cả Word 0 và Word 1
//            check_result_128(i, o_data, expected_out_0[i], expected_out_1[i]);
            
//            // Báo đã nhận (Ack) để module chuẩn bị số tiếp theo (nếu cần)
//            @(posedge clk);
//            i_ack = 1;
//            @(posedge clk);
//            i_ack = 0;
            
//            // Reset nhẹ
//            rst_n = 0; #10; rst_n = 1; #10; 
//        end

//        // --- 9. Tổng kết ---
//        $display("\n==========================================================");
//        if (fail_count == 0) begin
//            $display("   RESULT: [ PASS ]  ALL TESTS PASSED.");
//        end else begin
//            $display("   RESULT: [ FAIL ]  Found %0d errors.", fail_count);
//        end
//        $display("==========================================================");
        
//        #50;
//        $finish;
//    end

//endmodule






`timescale 1ns / 1ps

module tb_shake128_web_check;

    // --- 1. Signals ---
    reg          clk;
    reg          rst_n;
    
    // Input 64-bit (Giữ nguyên theo yêu cầu)
    reg  [63:0]  i_data;
    reg          i_valid;
    reg          i_last;
    wire         o_ready;
    
    // Output 128-bit 
    wire [127:0] o_data; 
    wire         o_valid;
    reg          i_ack;
    wire         o_squeeze;

    // --- 2. Instance DUT ---
    // Đảm bảo module shake128_top của bạn đã cập nhật output [127:0]
    shake128_top dut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_data(i_data),
        .i_valid(i_valid),
        .i_last(i_last),
        .o_ready(o_ready),
        .o_data(o_data), // Kết nối dây 128-bit
        .o_valid(o_valid),
        .i_ack(i_ack),
        .o_squeeze_mode(o_squeeze)
    );

    // --- 3. Clock ---
    always #5 clk = ~clk; 

    // --- 4. Helper Tasks (In 128-bit) ---
    // Task này sẽ in 16 byte từ thấp đến cao để khớp chuỗi Hex trên website
    task print_like_website;
        input [127:0] word;
        begin
            // In 64 bit thấp (Byte 0 -> Byte 7)
            $write("%h", word[7:0]);
            $write("%h", word[15:8]);
            $write("%h", word[23:16]);
            $write("%h", word[31:24]);
            $write("%h", word[39:32]);
            $write("%h", word[47:40]);
            $write("%h", word[55:48]);
            $write("%h", word[63:56]);
            
            // In 64 bit cao (Byte 8 -> Byte 15)
            $write("%h", word[71:64]);
            $write("%h", word[79:72]);
            $write("%h", word[87:80]);
            $write("%h", word[95:88]);
            $write("%h", word[103:96]);
            $write("%h", word[111:104]);
            $write("%h", word[119:112]);
            $write("%h", word[127:120]);
        end
    endtask

    // Hàm đảo byte input (Giữ nguyên cho 64-bit input)
    function [63:0] swap_endian;
        input [63:0] in;
        begin
            swap_endian = {in[7:0], in[15:8], in[23:16], in[31:24], 
                           in[39:32], in[47:40], in[55:48], in[63:56]};
        end
    endfunction

    // --- 5. Main Test ---
    initial begin
        $display("==========================================================");
        $display("   TESTBENCH KIEM TRA VOI WEBSITE (OUTPUT 128-BIT)        ");
        $display("==========================================================");

        clk = 0; rst_n = 0; i_valid = 0; i_data = 0; i_last = 0; i_ack = 0;
        #20; rst_n = 1; #10;
        
        // ----------------------------------------------------------------
        // INPUT: 1234567800000000
        // ----------------------------------------------------------------
        $display("\n[1] INPUT: Nap chuoi Hex '1234567800000000'...");
        
        wait(o_ready);
        @(posedge clk);
        i_valid = 1;
        // Đảo byte input 64-bit
        i_data  = swap_endian(64'h1234567800000000); 
        i_last  = 1;
        
        @(posedge clk);
        i_valid = 0; i_last  = 0;
        
        $display("[2] PROCESSING...");
        
        // CHECK OUTPUT
        wait(o_valid);
        $display("[3] OUTPUT READY! So sanh:");
        $display("    Website Expect: 57affc13ef3e6ff511f8914a0bbbc3b3cb44176616a8ce5111c4b77120263e95");
        $write  ("    Verilog Actual: ");
        
        // Lặp 2 lần (2 x 128 bit = 256 bit) thay vì 4 lần
        repeat (2) begin
            print_like_website(o_data); // In ra 16 byte (32 ký tự hex)
            
            @(posedge clk); i_ack = 1;
            @(posedge clk); i_ack = 0; #1; 
        end
        $write("\n");
        $display("==========================================================");
        #50; $finish;
    end

endmodule