`timescale 1ns / 1ps
`include "syndrome.v"

module bit_flipping_decoder #(
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8,
    parameter MAX_IT = 10,
    parameter THRESHOLD = 2
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    input  wire [W*POS_W-1:0] h0_pos_flat,
    input  wire [W*POS_W-1:0] h1_pos_flat,

    output reg  [R-1:0] e0,
    output reg  [R-1:0] e1,
    output reg          done,
    output reg          success
);

    // =========================================================
    // Syndrome
    // =========================================================
    wire [R-1:0] s;
    wire syndrome_done;

    syndrome #(
        .R(R), .W(W), .POS_W(POS_W)
    ) synd (
        .clk(clk),
        .rst(rst),
        .start(start),
        .e0(e0),
        .e1(e1),
        .h0_pos_flat(h0_pos_flat),
        .h1_pos_flat(h1_pos_flat),
        .s(s),
        .done(syndrome_done)
    );

    // =========================================================
    // Unflatten h positions
    // =========================================================
    wire [POS_W-1:0] h0_pos [0:W-1];
    wire [POS_W-1:0] h1_pos [0:W-1];

    genvar gi;
    generate
        for (gi = 0; gi < W; gi = gi + 1) begin
            assign h0_pos[gi] = h0_pos_flat[gi*POS_W +: POS_W];
            assign h1_pos[gi] = h1_pos_flat[gi*POS_W +: POS_W];
        end
    endgenerate

    // =========================================================
    // Internal registers
    // =========================================================
    reg [R-1:0] syndrome_reg;

    reg [$clog2(R)-1:0] i;
    reg [$clog2(W)-1:0] k;
    reg [$clog2(MAX_IT+1)-1:0] iter;

    reg [3:0] vote0, vote1;
    reg [POS_W:0] idx;

    // =========================================================
    // FSM states
    // =========================================================
    localparam IDLE   = 3'd0,
               SYND   = 3'd1,
               VOTE   = 3'd2,
               FLIP   = 3'd3,
               NEXT_I = 3'd4,
               DONE   = 3'd5;

    reg [2:0] state;

    // =========================================================
    // Main FSM
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            e0      <= 0;
            e1      <= 0;
            i       <= 0;
            k       <= 0;
            iter    <= 0;
            vote0   <= 0;
            vote1   <= 0;
            done    <= 0;
            success <= 0;
        end else begin
            case (state)

            // -------------------------------------------------
            IDLE: begin
                done    <= 0;
                success <= 0;
                if (start) begin
                    e0   <= 0;
                    e1   <= 0;
                    iter <= 0;
                    state <= SYND;
                end
            end

            // -------------------------------------------------
            SYND: begin
                if (syndrome_done) begin
                    syndrome_reg <= s;
                    i <= 0;
                    k <= 0;
                    state <= VOTE;
                end
            end

            // -------------------------------------------------
            // Vote accumulation (W cycles)
            // -------------------------------------------------
            VOTE: begin
                if (k == 0) begin
                    vote0 <= 0;
                    vote1 <= 0;
                end

                // h0 vote
                idx = i + h0_pos[k];
                if (idx >= R) idx = idx - R;
                vote0 <= vote0 + syndrome_reg[idx];

                // h1 vote
                idx = i + h1_pos[k];
                if (idx >= R) idx = idx - R;
                vote1 <= vote1 + syndrome_reg[idx];

                if (k == W-1) begin
                    k <= 0;
                    state <= F  LIP;
                end else begin
                    k <= k + 1;
                end
            end

            // -------------------------------------------------
            // Flip + syndrome update
            // -------------------------------------------------

            //nên khi flip e[i], tất cả các phương trình kiểm tra liên quan đến i cũng bị đảo trạng thái.
            // i chang vote ở trên nhưng làm trong W bit
            FLIP: begin
                if (vote0 >= THRESHOLD) begin
                    e0[i] <= ~e0[i];
                    for (k = 0; k < W; k = k + 1) begin
                        idx = i + h0_pos[k];
                        if (idx >= R) idx = idx - R;
                        syndrome_reg[idx] <= ~syndrome_reg[idx];
                    end
                end

                if (vote1 >= THRESHOLD) begin
                    e1[i] <= ~e1[i];
                    for (k = 0; k < W; k = k + 1) begin
                        idx = i + h1_pos[k]; 
                        if (idx >= R) idx = idx - R;
                        syndrome_reg[idx] <= ~syndrome_reg[idx];
                    end
                end

                state <= NEXT_I;
            end

            // -------------------------------------------------
            NEXT_I: begin
                if (syndrome_reg == 0) begin
                    success <= 1;
                    state <= DONE;
                end else if (iter >= MAX_IT) begin
                    success <= 0;
                    state <= DONE;
                end else if (i == R-1) begin
                    i <= 0;
                    iter <= iter + 1;
                    state <= VOTE;
                end else begin
                    i <= i + 1;
                    state <= VOTE;
                end
            end

            // -------------------------------------------------
            DONE: begin
                done <= 1;
            end

            endcase
        end
    end

endmodule
