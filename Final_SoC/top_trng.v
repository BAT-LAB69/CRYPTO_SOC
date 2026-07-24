`timescale 1ns/1ps  
    
module top_trng (
    input wire clk,         // System clock
    input wire rst,         // System reset
    input wire enable,      // Turn on/off TRNG

    output wire [31:0] data_out,    // 32 random bits
    output wire data_valid          // Signal when data_out has new word
);

    //==========================================================================
    // STAGE 1: TRNG Core - Generate raw random bits
    //==========================================================================
    wire raw_random_bit;
    
    trng_core u_core (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .random_bit(raw_random_bit)
    );

    //==========================================================================
    // STAGE 2: Von Neumann Corrector - Loại bỏ bias
    //==========================================================================
    // Input:  Raw bit (mỗi clock 1 bit, luôn valid)
    // Output: Corrected bit (không đều đặn, chỉ ~25% cycles có output)
    // Hiệu quả: Đẩy entropy từ 0.97 → 0.999+
    //==========================================================================
    wire corrected_bit;
    wire corrected_valid;

    von_neumann_corrector u_vn (
        .clk(clk),
        .rst(rst),
        .bit_in(raw_random_bit),
        .bit_in_valid(1'b1),         // Raw OSC bit luôn valid mỗi clock
        .bit_out(corrected_bit),
        .bit_out_valid(corrected_valid)
    );

    //==========================================================================
    // STAGE 3: Bit Collector - Collect 32 corrected bits into word
    //==========================================================================
    bit_collector u_collector (
        .clk(clk),
        .rst(rst),
        .bit_in(corrected_bit),
        .bit_valid(corrected_valid),   // Chỉ gom bit khi VN corrector output
        .data_out(data_out),
        .data_valid(data_valid)
    );

endmodule
