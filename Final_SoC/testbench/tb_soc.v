`timescale 1ns/1ps

module tb_soc;

    reg clk;
    reg rst;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz
    end

    initial begin
        $dumpfile("soc_wave.vcd");
        $dumpvars(0, tb_soc);
        
        rst = 1;
        #20;
        rst = 0;
        
        // Lặp chạy 1000 chu kỳ dao động
        #10000;
        $finish;
    end

    soc_top u_soc_top (
        .clk(clk),
        .rst(rst)
    );

endmodule
