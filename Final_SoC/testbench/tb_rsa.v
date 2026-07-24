`timescale 1ns/1ps

module tb_rsa;
    parameter WIDTH = 32;
    parameter E_BITS = 32;

    reg clk, rst, start;
    reg [WIDTH-1:0] M, N, N_INV, R2_MOD_N;
    reg [E_BITS-1:0] E;
    wire [WIDTH-1:0] C;
    wire done;

    rsa #(
        .WIDTH(WIDTH), .E_BITS(E_BITS)
    ) dut (
        .clk(clk), .rst(rst), .start(start),
        .M(M), .E(E), .N(N), .N_INV(N_INV), .R2_MOD_N(R2_MOD_N),
        .C(C), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("rsa_wave.vcd");
        $dumpvars(0, tb_rsa);
        
        clk = 0; rst = 1; start = 0;
        M = 32'd5;
        E = 32'd3;
        N = 32'd11; 
        N_INV = 32'h7; 
        R2_MOD_N = 32'h3;
        
        #20 rst = 0;
        #10 start = 1;
        #10 start = 0;

        wait(done);
        $display("=================================");
        $display("[RSA] Test Completed!");
        $display("[RSA] Result Ciphertext C: %h", C);
        $display("=================================");
        #50 $finish;
    end
endmodule
