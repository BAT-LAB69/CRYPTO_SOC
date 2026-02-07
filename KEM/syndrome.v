`include "poly_mul.v"

module syndrome #(
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,

    input  wire [R-1:0]     e0,
    input  wire [R-1:0]     e1,

    input  wire [W*POS_W-1:0] h0_pos_flat,
    input  wire [W*POS_W-1:0] h1_pos_flat,

    output reg  [R-1:0]     s,
    output reg              done
);

    // ===============================
    // Internal wires
    // ===============================
    wire [R-1:0] s0, s1;
    wire done0, done1;

    // ===============================
    // Two circulant multipliers
    // ===============================
    circulant_sparse_mul_pipe #(
        .R(R), .W(W), .POS_W(POS_W)
    ) MUL0 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .b(e0),
        .a_pos_flat(h0_pos_flat),
        .c(s0),
        .done(done0)
    );

    circulant_sparse_mul_pipe #(
        .R(R), .W(W), .POS_W(POS_W)
    ) MUL1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .b(e1),
        .a_pos_flat(h1_pos_flat),
        .c(s1),
        .done(done1)
    );

    // ===============================
    // Combine result
    // ===============================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s    <= 0;
            done <= 0;
        end else begin
            if (done0 && done1) begin
                s    <= s0 ^ s1;
                done <= 1;
            end else begin
                done <= 0;
            end
        end
    end

endmodule
