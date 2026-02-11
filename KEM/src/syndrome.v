
// Encoder = syndrome nhưng thay s bằng c.


module syndrome #(
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,

    input  wire [R-1:0]     c0,
    input  wire [R-1:0]     c1,

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
        .b(c0),
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
        .b(c1),
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




module circulant_sparse_mul_pipe #(
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,

    input  wire [R-1:0]     b,
    input  wire [W*POS_W-1:0] a_pos_flat,

    output reg  [R-1:0]     c,
    output reg              done
);

wire [POS_W-1:0] a_pos [0:W-1];
genvar i;
generate
    for (i = 0; i < W; i = i + 1) begin : UNFLATTEN
        assign a_pos[i] = a_pos_flat[i*POS_W +: POS_W];
    end
endgenerate

    
    reg [R-1:0] b_reg;
    reg [R-1:0] acc;
    reg [POS_W-1:0] pos;

    reg [R-1:0] r0, r1, r2, r3; 
    integer k;

    function  [R-1:0] rotate_left;
        input [R-1:0] x;
        input [POS_W-1:0] s;
        begin
            rotate_left = (x << s) | (x >> (R - s));
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc  <= 0;
            k    <= 0;
            done <= 0;
        end else begin
            if (start) begin
                b_reg <= b;
                acc   <= 0;
                k     <= 0;
                done  <= 0;
            end else if (k < W) begin
                r0 = rotate_left(b_reg, a_pos[k]);

                r1 = (k+1 < W) ? rotate_left(b_reg, a_pos[k+1]) : 0;
                r2 = (k+2 < W) ? rotate_left(b_reg, a_pos[k+2]) : 0;
                r3 = (k+3 < W) ? rotate_left(b_reg, a_pos[k+3]) : 0;

                acc <= acc ^ r0 ^ r1 ^ r2 ^ r3;
                k   <= k + 4;
            end else begin
                c    <= acc;
                done <= 1;
            end
        end
    end
endmodule