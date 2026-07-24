`timescale 1ns/1ps

module tb_ed25519;
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] seed;
    reg [255:0] msg;
    reg [6:0] msg_len;

    wire [255:0] sig_r;
    wire [255:0] sig_s;
    wire done;
    wire busy;

    ed25519_shake128 dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .seed(seed),
        .msg(msg),
        .msg_len(msg_len),
        .sig_r(sig_r),
        .sig_s(sig_s),
        .done(done),
        .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("ed25519_wave.vcd");
        $dumpvars(0, tb_ed25519);
        
        clk = 0; rst_n = 0; start = 0;
        
        seed = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        msg = 256'h0;
        msg_len = 0;

        #20 rst_n = 1;
        #10 start = 1;
        #10 start = 0;

        $display("[Ed25519] Test started. This might take thousands of cycles...");

        wait(done);
        $display("=================================");
        $display("[Ed25519] Test Completed!");
        $display("[Ed25519] Signature R: %h", sig_r);
        $display("[Ed25519] Signature S: %h", sig_s);
        $display("=================================");
        #50 $finish;
    end
    
    // Safety timeout
    initial begin
        #50000000;
        $display("[Ed25519] Simulation timed out!");
        $finish;
    end
endmodule
