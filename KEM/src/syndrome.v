
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

    // =============================
    // Internal wires
    // =============================
    wire [R-1:0] s0, s1;
    wire done0, done1;

    reg mul_start;

    // =============================
    // Instantiate multipliers
    // =============================
    circulant_sparse_mul_pipe #(
        .R(R), .W(W), .POS_W(POS_W)
    ) MUL0 (
        .clk(clk),
        .rst(rst),
        .start(mul_start),
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
        .start(mul_start),
        .b(c1),
        .a_pos_flat(h1_pos_flat),
        .c(s1),
        .done(done1)
    );

    // =============================
    // FSM
    // =============================
    localparam IDLE = 2'd0;
    localparam RUN  = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            done      <= 0;
            mul_start <= 0;
            s         <= 0;
        end else begin
            done      <= 0;
            mul_start <= 0;

            case (state)

                IDLE: begin
                    if (start) begin
                        mul_start <= 1;  // pulse
                        state     <= RUN;
                    end
                end

                RUN: begin
                    if (done0 && done1) begin
                        s     <= s0 ^ s1;
                        state <= DONE;
                    end
                end

                DONE: begin
                    done  <= 1;      // 1-cycle pulse
                    state <= IDLE;   // ready for next start
                end

            endcase
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

    // =============================
    // Unflatten
    // =============================
    wire [POS_W-1:0] a_pos [0:W-1];
    genvar i;
    generate
        for (i = 0; i < W; i = i + 1) begin : UNFLATTEN
            assign a_pos[i] = a_pos_flat[i*POS_W +: POS_W];
        end
    endgenerate

    // =============================
    // FSM
    // =============================
    localparam IDLE = 2'd0;
    localparam RUN  = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state;

    reg [R-1:0] b_reg;
    reg [R-1:0] acc;
    integer k;

    function [R-1:0] rotate_left;
        input [R-1:0] x;
        input [POS_W-1:0] s;
        begin
            rotate_left = (x << s) | (x >> (R - s));
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            acc   <= 0;
            k     <= 0;
            done  <= 0;
        end else begin
            done <= 0; // default

            case (state)

                IDLE: begin
                    if (start) begin
                        b_reg <= b;
                        acc   <= 0;
                        k     <= 0;
                        state <= RUN;
                    end
                end

                RUN: begin
                    if (k < W) begin
                        acc <= acc ^
                               rotate_left(b_reg, a_pos[k]) ^
                               ((k+1 < W) ? rotate_left(b_reg, a_pos[k+1]) : 0) ^
                               ((k+2 < W) ? rotate_left(b_reg, a_pos[k+2]) : 0) ^
                               ((k+3 < W) ? rotate_left(b_reg, a_pos[k+3]) : 0);

                        k <= k + 4;
                    end else begin
                        c     <= acc;
                        state <= DONE;
                    end
                end

                DONE: begin
                    done  <= 1;     // 1-cycle pulse
                    state <= IDLE;  // return to idle
                end

            endcase
        end
    end

endmodule




////////////////// TESTING //////////////////


// module tb_syndrome;

//     // ===============================
//     // Parameters (same as DUT)
//     // ===============================
//     localparam R     = 127;
//     localparam W     = 5;
//     localparam POS_W = 8;

//     // ===============================
//     // Clock / Reset
//     // ===============================
//     reg clk = 0;
//     always #5 clk = ~clk;   // 100MHz

//     reg rst;
//     reg start;

//     // ===============================
//     // DUT Inputs
//     // ===============================
//     reg  [R-1:0] c0;
//     reg  [R-1:0] c1;

//     reg  [W*POS_W-1:0] h0_pos_flat;
//     reg  [W*POS_W-1:0] h1_pos_flat;

//     // ===============================
//     // DUT Outputs
//     // ===============================
//     wire [R-1:0] s;
//     wire done;

//     // ===============================
//     // Instantiate DUT
//     // ===============================
//     syndrome #(
//         .R(R),
//         .W(W),
//         .POS_W(POS_W)
//     ) DUT (
//         .clk(clk),
//         .rst(rst),
//         .start(start),
//         .c0(c0),
//         .c1(c1),
//         .h0_pos_flat(h0_pos_flat),
//         .h1_pos_flat(h1_pos_flat),
//         .s(s),
//         .done(done)
//     );

//     // ============================================================
//     // Reference model (software-like inside TB)
//     // ============================================================

//     function [R-1:0] rotate_left;
//         input [R-1:0] x;
//         input integer shift;
//         begin
//             rotate_left = (x << shift) | (x >> (R - shift));
//         end
//     endfunction

//     function [R-1:0] sparse_mul_ref;
//         input [R-1:0] b;
//         input [W*POS_W-1:0] pos_flat;
//         integer i;
//         reg [R-1:0] acc;
//         reg [POS_W-1:0] pos;
//         begin
//             acc = 0;
//             for (i = 0; i < W; i = i + 1) begin
//                 pos = pos_flat[i*POS_W +: POS_W];
//                 acc = acc ^ rotate_left(b, pos);
//             end
//             sparse_mul_ref = acc;
//         end
//     endfunction

//     reg [R-1:0] s_expected;

//     // ============================================================
//     // Test sequence
//     // ============================================================

//     initial begin

//         // =====================
//         // Reset
//         // =====================
//         rst   = 1;
//         start = 0;
//         #20;
//         rst = 0;

//         // =====================
//         // Test Vector
//         // =====================

//         // Random example
//         c0 = 127'h123456789ABCDEF0123456789ABCDEF;
//         c1 = 127'h0FEDCBA9876543210FEDCBA987654321;

//         // Example sparse positions
//         // (must be < R)
//         h0_pos_flat = {
//             8'd3,
//             8'd7,
//             8'd11,
//             8'd19,
//             8'd25
//         };

//         h1_pos_flat = {
//             8'd2,
//             8'd5,
//             8'd13,
//             8'd17,
//             8'd29
//         };

//         // =====================
//         // Start
//         // =====================
//         #10;
//         start = 1;
//         #10;
//         start = 0;

//         // =====================
//         // Wait done
//         // =====================
//         wait(done);

//         // =====================
//         // Compute expected
//         // =====================
//         s_expected =
//             sparse_mul_ref(c0, h0_pos_flat) ^
//             sparse_mul_ref(c1, h1_pos_flat);

//         // =====================
//         // Compare
//         // =====================
//         if (s == s_expected) begin
//             $display("=================================");
//             $display("TEST PASSED");
//             $display("s = %h", s);
//             $display("=================================");
//         end else begin
//             $display("=================================");
//             $display("TEST FAILED");
//             $display("Expected = %h", s_expected);
//             $display("Got      = %h", s);
//             $display("=================================");
//         end

//         #50;
//         $finish;
//     end

// endmodule