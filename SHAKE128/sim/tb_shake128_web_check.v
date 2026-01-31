//`timescale 1ns / 1ps

//module tb_shake128_web_check;

//    // --- 1. Tín hiệu kết nối ---
//    reg          clk;
//    reg          rst_n;
//    reg  [63:0]  i_data;
//    reg          i_valid;
//    reg          i_last;
//    wire         o_ready;
//    wire [63:0]  o_data;
//    wire         o_valid;
//    reg          i_ack;
//    wire         o_squeeze;

//    // --- 2. Dữ liệu Test ---
//    // 10 trường hợp test lấy từ hình ảnh của bạn
//    reg [63:0] test_vectors [0:9];
//    reg [63:0] expected_out_0 [0:9]; // Kết quả Word 1 (64-bit đầu)
//    reg [63:0] expected_out_1 [0:9]; // Kết quả Word 2 (64-bit sau)
    
//    integer i;
//    integer pass_count;
//    integer fail_count;

//    // --- 3. Instance Module SHAKE128 ---
//    shake128_top dut (
//        .i_clk(clk),
//        .i_rst_n(rst_n),
//        .i_data(i_data),
//        .i_valid(i_valid),
//        .i_last(i_last),
//        .o_ready(o_ready),
//        .o_data(o_data),
//        .o_valid(o_valid),
//        .i_ack(i_ack),
//        .o_squeeze_mode(o_squeeze)
//    );

//    // --- 4. Tạo xung Clock ---
//    always #5 clk = ~clk; // Chu kỳ 10ns (100MHz)

//    // --- 5. Hàm đảo byte (Endian Swap) ---
//    // Giúp chuyển chuỗi Hex bạn nhìn thấy sang format Little Endian cho chip
//    function [63:0] swap_endian;
//        input [63:0] in;
//        begin
//            swap_endian = {in[7:0], in[15:8], in[23:16], in[31:24], 
//                           in[39:32], in[47:40], in[55:48], in[63:56]};
//        end
//    endfunction

//    // --- 6. Chuẩn bị bộ dữ liệu Test ---
//    initial begin
//        // --- INPUTS (Copy y nguyên từ hình ảnh của bạn) ---
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

//        // --- EXPECTED OUTPUTS (Tính toán từ kết quả web của bạn) ---
//        // Lưu ý: Kết quả web là Byte Stream. Ta gom 8 byte thành 1 Word Little Endian.
        
//        // Case 0: 00...00 -> 7a24b666...
//        expected_out_0[0] = 64'h985c34da66b6247a; 
//        expected_out_1[0] = 64'h1aa514fdaa00a4c3;

//        // Case 1: FF...FF -> 9aede33b...
//        expected_out_0[1] = 64'h9279fac13be3ed9a;
//        expected_out_1[1] = 64'h53732a2138a84fdd;

//        // Case 2: 0123...EF -> f1f72be3...
//        expected_out_0[2] = 64'h8ae06141e32bf7f1;
//        expected_out_1[2] = 64'h30a2ac8c7f73ff80;

//        // Case 3: FEDC...10 -> 0ac46d96...
//        expected_out_0[3] = 64'h9b2a195a966dc40a;
//        expected_out_1[3] = 64'hc3a1f9387d18255b;

//        // Case 4: AA...AA -> d682aacd...
//        expected_out_0[4] = 64'h01b673a1cdaa82d6;
//        expected_out_1[4] = 64'h169a7e05208dac86;

//        // Case 5: 55...55 -> 9a010d90...
//        expected_out_0[5] = 64'h04a82f11900d019a;
//        expected_out_1[5] = 64'hbeb227d8441b9823;

//        // Case 6: 1234...00 -> 57affc13...
//        expected_out_0[6] = 64'hf56f3eef13fcaf57;
//        expected_out_1[6] = 64'hb3c3bb0b4a91f811;

//        // Case 7: 0000...21 -> c3c5212e...
//        expected_out_0[7] = 64'hb82a5efa2e21c5c3;
//        expected_out_1[7] = 64'h67125e2b9c1368b7;

//        // Case 8: 00FF...00 -> d8b027db...
//        expected_out_0[8] = 64'h857f6a8adb27b0d8;
//        expected_out_1[8] = 64'hb089f7d480ebb4fa;

//        // Case 9: 8000...01 -> e00d8138...
//        expected_out_0[9] = 64'h25b7403f38810de0;
//        expected_out_1[9] = 64'haf002d515fdb2249;
//    end

//    // --- 7. Task kiểm tra kết quả ---
//    task check_result;
//        input [31:0] test_id;
//        input [31:0] word_idx;
//        input [63:0] actual;
//        input [63:0] expected;
//        begin
//            if (actual === expected) begin
//                $display("    [Word %0d] Check: MATCH (%h)", word_idx, actual);
//            end else begin
//                $display("    [Word %0d] Check: ERROR !!!", word_idx);
//                $display("             Actual:   %h", actual);
//                $display("             Expected: %h", expected);
//                fail_count = fail_count + 1;
//            end
//        end
//    endtask

//    // --- 8. Kịch bản chạy Test ---
//    initial begin
//        $display("==========================================================");
//        $display("        AUTOMATED SHAKE128 VERIFICATION START             ");
//        $display("==========================================================");

//        // Khởi tạo
//        clk = 0;
//        rst_n = 0;
//        i_valid = 0; i_data = 0; i_last = 0; i_ack = 0;
//        pass_count = 0;
//        fail_count = 0;

//        // Reset hệ thống
//        #20; rst_n = 1; #10;

//        // --- Vòng lặp chạy 10 Test Cases ---
//        for (i = 0; i < 10; i = i + 1) begin
//            $display("\n--- Test Case #%0d: Input = %h ---", i, test_vectors[i]);
            
//            // 1. Nạp dữ liệu (Quan trọng: Đảo byte để khớp với cách nhập của Web)
//            wait(o_ready);
//            @(posedge clk);
//            i_valid = 1;
//            i_last  = 1; // Test này chỉ gửi 1 gói 64-bit là kết thúc luôn
//            i_data  = swap_endian(test_vectors[i]); 
            
//            @(posedge clk);
//            i_valid = 0;
//            i_last  = 0;
            
//            // 2. Chờ kết quả
//            wait(o_valid);
            
//            // 3. Kiểm tra Word đầu tiên (64-bit đầu)
//            check_result(i, 0, o_data, expected_out_0[i]);
            
//            // Báo đã nhận để lấy Word tiếp theo
//            @(posedge clk);
//            i_ack = 1;
//            @(posedge clk);
//            i_ack = 0;
//            #1; // Đợi tín hiệu ổn định
            
//            // 4. Kiểm tra Word thứ hai (64-bit sau)
//            check_result(i, 1, o_data, expected_out_1[i]);
            
//            // Flush output (đọc thêm 1 cái cho sạch pipeline nếu cần)
//            @(posedge clk);
//            i_ack = 1; 
//            @(posedge clk);
//            i_ack = 0;
            
//            // Reset nhẹ (optional) để test case sau sạch sẽ
//            rst_n = 0; #10; rst_n = 1; #10; 
//        end

//        // --- 9. Tổng kết ---
//        $display("\n==========================================================");
//        $display("                    FINAL REPORT                          ");
//        $display("==========================================================");
//        if (fail_count == 0) begin
//            $display("   RESULT: [ PASS ]  ALL 10 TESTS PASSED.");
//            $display("   Chuc mung! Chip SHAKE128 cua ban hoat dong chinh xac.");
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
    reg  [63:0]  i_data;
    reg          i_valid;
    reg          i_last;
    wire         o_ready;
    wire [63:0]  o_data;
    wire         o_valid;
    reg          i_ack;
    wire         o_squeeze;

    // --- 2. Instance DUT ---
    shake128_top dut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_data(i_data),
        .i_valid(i_valid),
        .i_last(i_last),
        .o_ready(o_ready),
        .o_data(o_data),
        .o_valid(o_valid),
        .i_ack(i_ack),
        .o_squeeze_mode(o_squeeze)
    );

    // --- 3. Clock ---
    always #5 clk = ~clk; 

    // --- 4. Helper Tasks ---
    task print_like_website;
        input [63:0] word;
        begin
            $write("%h", word[7:0]);
            $write("%h", word[15:8]);
            $write("%h", word[23:16]);
            $write("%h", word[31:24]);
            $write("%h", word[39:32]);
            $write("%h", word[47:40]);
            $write("%h", word[55:48]);
            $write("%h", word[63:56]);
        end
    endtask

    // Hàm đảo byte để Input khớp với Web
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
        $display("   TESTBENCH KIEM TRA VOI WEBSITE (DA FIX ENDIAN)         ");
        $display("==========================================================");

        clk = 0; rst_n = 0; i_valid = 0; i_data = 0; i_last = 0; i_ack = 0;
        #20; rst_n = 1; #10;
        
        // ----------------------------------------------------------------
        // INPUT: "FEDCBA9876543210"
        // ----------------------------------------------------------------
        $display("\n[1] INPUT: Nap chuoi Hex 'FEDCBA9876543210'...");
        
        wait(o_ready);
        @(posedge clk);
        i_valid = 1;
        // QUAN TRỌNG: Gọi hàm swap_endian để đảo byte cho đúng thứ tự
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
        
        repeat (4) begin
            print_like_website(o_data);
            @(posedge clk); i_ack = 1;
            @(posedge clk); i_ack = 0; #1; 
        end
        $write("\n");
        $display("==========================================================");
        #50; $finish;
    end

endmodule