`timescale 1ns / 1ps

module tb_keccak_f1600;

    // 1. Khai báo tín hiệu
    reg          clk;
    reg          rst_n;
    reg          start;
    reg [1599:0] i_state;
    
    wire [1599:0] o_state;
    wire          done;
    wire          busy;

    // 2. Instance module DUT (Device Under Test)
    keccak_f1600 dut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start),
        .i_state(i_state),
        .o_state(o_state),
        .o_done(done),
        .o_busy(busy)
    );

    // 3. Tạo xung Clock (10ns period = 100MHz)
    always #5 clk = ~clk;

    // 4. Các biến hỗ trợ hiển thị (Helper variables)
    integer x, y;

    // 5. Kịch bản Test
    initial begin
        // Khởi tạo
        clk = 0;
        rst_n = 0;
        start = 0;
        i_state = 0;

        // Reset hệ thống
        #20;
        rst_n = 1;
        #10;


        i_state[63:0] = 64'h0000000000000006; 
        

        i_state[1024 +: 64] = 64'h8000000000000000;

        $display("\n--- BAT DAU TEST ---");
        $display("Input State loaded tu PDF Page 2.");
        
        // Gửi xung Start
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Chờ tín hiệu Done
        wait(done);
        #10;
        
        $display("\n--- KET THUC TINH TOAN ---");
        $display("Final Result (so sanh voi PDF trang cuoi cung, muc 'State'):");
        
        // In kết quả cuối cùng theo dạng Lane [x,y] để dễ so sánh
        for (y = 0; y < 5; y = y + 1) begin
            for (x = 0; x < 5; x = x + 1) begin
                $display("[x=%0d, y=%0d] = %16h", x, y, o_state[64*(5*y+x) +: 64]);
            end
        end

        // Kiểm tra nhanh kết quả Lane [0,0] với trang 36 của PDF
        if (o_state[63:0] == 64'h66d71ebff8c6ffa7) 
            $display("\n>>> TEST PASS: Lane [0,0] khop hoan toan voi PDF! <<<");
        else
            $display("\n>>> TEST FAIL: Lane [0,0] khong khop! <<<");

        #50;
        $finish;
    end


    always @(dut.round_ctr) begin
        if (dut.round_ctr > 0 || dut.o_done) begin
            #1; // Đợi tín hiệu ổn định
            $display("--------------------------------------------------");
            $display("Debug RC used for Round #%0d was: %h", dut.round_ctr - 1, dut.round_const);
            $display("Ket qua sau khi chay xong Round #%0d:", dut.round_ctr - 1);
            
            $display("   [0,0] = %16h", dut.current_state[63:0]);
            $display("   [1,0] = %16h", dut.current_state[127:64]);
            $display("   [2,0] = %16h", dut.current_state[191:128]);
            $display("   [3,0] = %16h", dut.current_state[255:192]);
            $display("   [4,0] = %16h", dut.current_state[319:256]);

            $display("   [1,3] = %16h", dut.current_state[1087:1024]);
        end
    end

endmodule