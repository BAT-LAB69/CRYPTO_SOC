`timescale 1ns/1ps

module tb_shake;
    reg clk, rst, start;
    reg [2:0] out_len_type;
    reg mode;
    reg [1023:0] din;
    reg [6:0] byte_len;
    
    wire [511:0] dout;
    wire done, busy;

    shake_top dut (
        .clk(clk), .rst(rst), .start(start),
        .out_len_type(out_len_type), .mode(mode),
        .din(din), .byte_len(byte_len),
        .dout(dout), .done(done), .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("shake_wave.vcd");
        $dumpvars(0, tb_shake);
        
        clk = 0; rst = 1; start = 0;
        out_len_type = 1; // 512 bit
        mode = 0; // SHAKE128
        din = 1024'habcd;
        byte_len = 2; // 2 bytes
        
        #20 rst = 0;
        #10 start = 1;
        #10 start = 0;

        wait(done);
        $display("=================================");
        $display("[SHAKE128] Test Completed!");
        $display("[SHAKE128] Hash Output: %h", dout);
        $display("=================================");
        #50 $finish;
    end
endmodule
