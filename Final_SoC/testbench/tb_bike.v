`timescale 1ns/1ps

module tb_bike;

    localparam R = 127;
    localparam W = 5;
    localparam POS_W = 8;

    reg clk, rst, start;
    reg [W*POS_W-1:0] h0_pos_flat;
    reg [W*POS_W-1:0] h1_pos_flat;
    reg [R-1:0] c0, c1;

    wire [511:0] shared_key;
    wire done;

    bike_top #(
        .R(R), .W(W), .POS_W(POS_W)
    ) dut (
        .clk(clk), .rst(rst), .start(start),
        .h0_pos_flat(h0_pos_flat), .h1_pos_flat(h1_pos_flat),
        .c0(c0), .c1(c1),
        .shared_key(shared_key), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("bike_wave.vcd");
        $dumpvars(0, tb_bike);
        
        clk = 0; rst = 1; start = 0;
        h0_pos_flat = 0; h1_pos_flat = 0;
        c0 = 0; c1 = 0;
        
        #20 rst = 0;
        
        h0_pos_flat = 40'h01_02_03_04_05;
        h1_pos_flat = 40'h06_07_08_09_0A;
        c0 = 127'h1234;
        c1 = 127'h5678;

        #10 start = 1;
        #10 start = 0;

        wait(done);
        $display("=================================");
        $display("[BIKE] Test Completed!");
        $display("[BIKE] Shared Key:  %h", shared_key);
        $display("=================================");
        #50 $finish;
    end
endmodule
