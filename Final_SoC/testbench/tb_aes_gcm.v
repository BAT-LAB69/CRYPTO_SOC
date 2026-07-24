`timescale 1ns/1ps

module tb_aes_gcm;

    reg clk;
    reg rst;
    reg start;
    reg [255:0] key;
    reg [95:0]  nonce;
    reg [127:0] pt1, pt2, pt3;
    reg [223:0] aad;

    wire [127:0] ct1, ct2, ct3;
    wire [127:0] tag;
    wire done;

    aes_gcm_top dut (
        .clk(clk), .rst(rst), .start(start),
        .key(key), .nonce(nonce),
        .plaintext1(pt1), .plaintext2(pt2), .plaintext3(pt3),
        .aad(aad),
        .ciphertext1(ct1), .ciphertext2(ct2), .ciphertext3(ct3),
        .tag(tag), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("aes_wave.vcd");
        $dumpvars(0, tb_aes_gcm);
        
        clk = 0; rst = 1; start = 0;
        key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        nonce = 96'h000000000000000000000000;
        pt1 = 128'hdeadbeefdeadbeefdeadbeefdeadbeef;
        pt2 = 128'h0123456789abcdeffedcba9876543210;
        pt3 = 128'habcdef0123456789abcdef0123456789;
        aad = 224'h112233445566778899aabbccddeeff00112233445566778899aabbcc;

        #20 rst = 0;
        #10 start = 1;
        #10 start = 0;

        wait(done);
        $display("=================================");
        $display("[AES-GCM] Test Completed!");
        $display("[AES-GCM] Ciphertext 1: %h", ct1);
        $display("[AES-GCM] Ciphertext 2: %h", ct2);
        $display("[AES-GCM] Ciphertext 3: %h", ct3);
        $display("[AES-GCM] Auth Tag    : %h", tag);
        $display("=================================");
        #50 $finish;
    end
endmodule
