`timescale 1ns/1ps

module tb_trng;
    reg clk, rst, enable;
    wire [31:0] data_out;
    wire data_valid;

    top_trng dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    always #5 clk = ~clk;

    integer word_count;

    initial begin
        $dumpfile("trng_wave.vcd");
        $dumpvars(0, tb_trng);
        
        clk = 0; rst = 1; enable = 0;
        word_count = 0;

        #20 rst = 0;
        #10 enable = 1;

        $display("[TRNG] Enabled. Waiting for random words...");
    end

    always @(posedge clk) begin
        if (data_valid) begin
            $display("[TRNG] Word %0d: 0x%h", word_count, data_out);
            word_count = word_count + 1;
            if (word_count >= 8) begin
                $display("=================================");
                $display("[TRNG] Test Completed! Generated %0d random words.", word_count);
                $display("=================================");
                $finish;
            end
        end
    end

    // Safety timeout
    initial begin
        #500000;
        $display("[TRNG] Timeout! Only generated %0d words.", word_count);
        $finish;
    end
endmodule
