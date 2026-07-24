`timescale 1ns/1ps

module osc_cell(
    input wire T,
    input wire I1,
    input wire I2,
    output wire OSC
);

    reg [15:0] lfsr;
    
    initial begin
        lfsr = $random;
        if (lfsr == 0) lfsr = 16'hBEEF;
    end

    always @(*) begin
        if (T && I1) begin
            #1;
            lfsr = {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
        end
    end

    assign OSC = (T & I1) ? lfsr[0] : 1'b0;

endmodule
