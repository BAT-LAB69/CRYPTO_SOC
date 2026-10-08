`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ghash
// Description: GHASH for AES-GCM (GF(2^128) multiplication)
//              16-bit parallel version: processes 16 bits per clock cycle
//              Total latency: 8 clock cycles (vs 128 in serial version)
//              Reduction polynomial: x^128 + x^7 + x^2 + x + 1
//////////////////////////////////////////////////////////////////////////////////

module ghash(
    input  wire        clk,
    input  wire        rst,        // active high
    input  wire        start,      // pulse 1 cycle
    input  wire [127:0] data_in,
    input  wire [127:0] h_key,
    input  wire [127:0] y_prev,
    output reg         done,       // pulse 1 cycle
    output reg  [127:0] y_out
);

    // Reduction polynomial R for GF(2^128)
    localparam [127:0] R = 128'hE1000000000000000000000000000000;

    reg [127:0] x;      // Multiplicand (data_in ^ y_prev)
    reg [127:0] v;      // Multiplier (h_key), shifted each iteration
    reg [127:0] z;      // Accumulator
    reg [2:0]   cnt;    // Counter 0..7 (8 cycles x 16 bits = 128 bits)
    reg         busy;

    // =========================================================
    // 16-stage unrolled combinational logic
    // Each stage processes 1 bit of x
    // 16 stages run in parallel within 1 clock cycle
    // =========================================================
    wire [127:0] z_stage [0:16];
    wire [127:0] v_stage [0:16];

    assign z_stage[0] = z;
    assign v_stage[0] = v;

    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : unroll
            // Select the appropriate bit of x (MSB first)
            wire x_bit = x[127 - (cnt * 16 + gi)];

            // Z update: if x_bit == 1, Z = Z ^ V; else Z unchanged
            assign z_stage[gi+1] = x_bit ? (z_stage[gi] ^ v_stage[gi]) : z_stage[gi];

            // V update: shift right 1 bit, reduce modulo R if LSB was 1
            wire v_lsb = v_stage[gi][0];
            wire [127:0] v_shifted = {1'b0, v_stage[gi][127:1]};
            assign v_stage[gi+1] = v_lsb ? (v_shifted ^ R) : v_shifted;
        end
    endgenerate

    // =========================================================
    // Sequential control logic
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x      <= 128'b0;
            v      <= 128'b0;
            z      <= 128'b0;
            cnt    <= 3'b0;
            busy   <= 1'b0;
            done   <= 1'b0;
            y_out  <= 128'b0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                x    <= data_in ^ y_prev;
                v    <= h_key;
                z    <= 128'b0;
                cnt  <= 3'b0;
                busy <= 1'b1;
            end
            else if (busy) begin
                z <= z_stage[16];
                v <= v_stage[16];

                if (cnt == 3'd7) begin
                    y_out <= z_stage[16];
                    done  <= 1'b1;
                    busy  <= 1'b0;
                end
                else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end

endmodule
