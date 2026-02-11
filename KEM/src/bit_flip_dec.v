`timescale  1ps/1ps

module bit_flipping_decoder #(
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8,
    parameter MAX_IT = 10,
    parameter THRESHOLD = 2
)(
    input wire clk,
    input wire rst,
    input wire start,

    input  wire [R-1:0]     s_in,

    input  wire [W*POS_W-1:0] h0_pos_flat,
    input  wire [W*POS_W-1:0] h1_pos_flat,

    output reg  [R-1:0]     e0,
    output reg  [R-1:0]     e1,
    output reg              done,
    output reg              success
);

// =====================================================
// Unflatten sparse positions
// =====================================================
wire [POS_W-1:0] h0_pos [0:W-1];
wire [POS_W-1:0] h1_pos [0:W-1];

genvar gi;
generate
    for (gi = 0; gi < W; gi = gi + 1) begin
        assign h0_pos[gi] = h0_pos_flat[gi*POS_W +: POS_W];
        assign h1_pos[gi] = h1_pos_flat[gi*POS_W +: POS_W];
    end
endgenerate

// =====================================================
// Registers
// =====================================================
reg [R-1:0] syndrome;
reg [$clog2(R)-1:0] i;
reg [$clog2(W)-1:0] k;
reg [$clog2(MAX_IT)-1:0] iter;
reg [3:0] vote0, vote1;
reg any_flipped;
reg flip0_reg, flip1_reg;


wire [POS_W:0] sum0 = i + h0_pos[k];
wire [POS_W:0] sum1 = i + h1_pos[k];
wire [$clog2(R)-1:0] idx0 = (sum0 >= R) ? (sum0 - R) : sum0[ $clog2(R)-1:0 ];
//wire [$clog2(R)-1:0] idx0; 
//assign idx0 = (i + h0_pos[k]) % R;
wire [$clog2(R)-1:0] idx1 = (sum1 >= R) ? (sum1 - R) : sum1[ $clog2(R)-1:0 ];
//wire [$clog2(R)-1:0] idx1;
//assign idx1 = (i + h1_pos[k]) % R;
// =====================================================
// FSM
// =====================================================
localparam IDLE        = 3'd0,
           VOTE        = 3'd1,
           FLIP_PREP   = 3'd2,
           FLIP_UPDATE = 3'd3,
           NEXT_I      = 3'd4,
           CHECK_ITER  = 3'd5,
           DONE        = 3'd6;

reg [2:0] state;

always @(i)begin
    $display( "i=%0d, k=%0d, syndrome=%b, e0=%b, e1=%b", i, k, syndrome, e0, e1);
end

always @(k)begin
    $display(" idx0:%0d, k:%d, pos:%d", idx0, k, h0_pos[k]);    //sai ngay chỗ truy cập pos này
end
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state       <= IDLE;
        e0          <= 0;
        e1          <= 0;
        syndrome    <= 0;
        i           <= 0;
        k           <= 0;
        iter        <= 0;
        vote0       <= 0;
        vote1       <= 0;
        any_flipped <= 0;
        flip0_reg   <= 0;
        flip1_reg   <= 0;
        done        <= 0;
        success     <= 0;
    end else begin
        case (state)
            IDLE: begin
                done <= 0;
                success <= 0;
                if (start) begin
                    e0          <= 0;
                    e1          <= 0;
                    syndrome    <= s_in;
                    i           <= 0;
                    k           <= 0;
                    iter        <= 0;
                    any_flipped <= 0;
                    state       <= VOTE;
                end
            end

            VOTE: begin
                
                if (k == 0) begin
                    vote0 <= syndrome[idx0];
                    vote1 <= syndrome[idx1];
                end else begin
                    vote0 <= vote0 + syndrome[idx0];
                    vote1 <= vote1 + syndrome[idx1];
                end

                if (k == W - 1) begin
                    k     <= 0;
                    state <= FLIP_PREP;
                end else begin
                    k <= k + 1;
                end
            end

            FLIP_PREP: begin
                flip0_reg <= (vote0 >= THRESHOLD);
                flip1_reg <= (vote1 >= THRESHOLD);
                if (vote0 >= THRESHOLD || vote1 >= THRESHOLD)
                    any_flipped <= 1;
                k <= 0;
                state <= FLIP_UPDATE;  
            end

            FLIP_UPDATE: begin
                if (flip0_reg && flip1_reg && (idx0 == idx1)) begin
                    // XORing twice cancels out
                end else begin
                    if (flip0_reg) syndrome[idx0] <= ~syndrome[idx0];
                    if (flip1_reg) syndrome[idx1] <= ~syndrome[idx1];
                end
                
                if (k == 0) begin
                    if (flip0_reg) e0[i] <= ~e0[i];
                    if (flip1_reg) e1[i] <= ~e1[i];
                end

                if (k == W - 1) begin
                    k <= 0;
                    state <= NEXT_I;
                end else begin
                    k <= k + 1;
                end
            end

            NEXT_I: begin
                vote0 <= 0;
                vote1 <= 0;
                if (i == R - 1) begin
                    state <= CHECK_ITER;
                end else begin
                    i <= i + 1;
                    k <= 0;
                    state <= VOTE;
                end
            end

            CHECK_ITER: begin
                if (syndrome == 0) begin
                    success <= 1;
                    state <= DONE;
                end else if (!any_flipped || iter == MAX_IT - 1) begin
                    success <= 0;
                    state <= DONE;
                end else begin
                    iter <= iter + 1;
                    i <= 0;
                    k <= 0;
                    any_flipped <= 0;
                    state <= VOTE;
                end
            end

            DONE: begin
                done <= 1;
                if (!start) state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule






// `timescale 1ps / 1ps

// module tb_bit_flipping_decoder;

//     // =========================
//     // Parameters
//     // =========================
//     localparam R = 5;
//     localparam W = 3;
//     localparam POS_W = 8;
//     localparam MAX_IT = 1;
//     localparam THRESHOLD = 2;

//     // =========================
//     // Clock
//     // =========================
//     reg clk = 0;
//     always #5 clk = ~clk;

//     // =========================
//     // Signals
//     // =========================
//     reg rst;
//     reg start;
//     reg  [R-1:0] s_in;
//     reg  [W*POS_W-1:0] h0_pos_flat;
//     reg  [W*POS_W-1:0] h1_pos_flat;

//     wire [R-1:0] e0;
//     wire [R-1:0] e1;
//     wire done;
//     wire success;

//     // =========================
//     // DUT
//     // =========================
//     bit_flipping_decoder #(
//         .R(R),
//         .W(W),
//         .POS_W(POS_W),
//         .MAX_IT(MAX_IT),
//         .THRESHOLD(THRESHOLD)
//     ) dut (
//         .clk(clk),
//         .rst(rst),
//         .start(start),
//         .s_in(5'b10110),
//         .h0_pos_flat(h0_pos_flat),
//         .h1_pos_flat(h1_pos_flat),
//         .e0(e0),
//         .e1(e1),
//         .done(done),
//         .success(success)
//     );

//     // =========================
//     // rotate-left
//     // =========================
//     function [R-1:0] rotl;
//         input [R-1:0] x;
//         input integer s;
//         begin
//             rotl = (x << s) | (x >> (R - s));
//         end
//     endfunction

//     // =========================
//     // Build syndrome
//     // =========================
//     task build_syndrome;
//         input  [R-1:0] e0_ref;
//         input  [R-1:0] e1_ref;
//         output [R-1:0] s;
//         integer i;
//         reg [R-1:0] tmp;
//         begin
//             tmp = 0;
//             for (i = 0; i < W; i = i + 1) begin
//                 tmp = tmp ^
//                       rotl(e0_ref, h0_pos_flat[i*POS_W +: POS_W]) ^
//                       rotl(e1_ref, h1_pos_flat[i*POS_W +: POS_W]);
//             end
//             s = tmp;
//         end
//     endtask

//     // =========================
//     // Run one test (CORRECT)
//     // =========================
//     task run_test;
//         input [R-1:0] e0_ref;
//         input [R-1:0] e1_ref;
//         reg   [R-1:0] s_tmp;
//         begin
//             build_syndrome(e0_ref, e1_ref, s_tmp);

//             @(posedge clk);
//             s_in  <= s_tmp;
//             start <= 1;

//             @(posedge clk);
//             start <= 0;

//             wait(done);

//             $display("=================================");
//             $display("Input syndrome = %b", s_tmp);
//             $display("Decoded e0     = %b", e0);
//             $display("Decoded e1     = %b", e1);
//             $display("Success flag   = %0d", success);

//             if (success)
//                 $display("✅ Syndrome cleared (decoder success)\n");
//             else
//                 $display("⚠️ Decoder did not converge\n");
//         end
//     endtask

//     // =========================
//     // Tests
//     // =========================
//     initial begin
//         rst   = 1;
//         start = 0;
//         s_in  = 0;

//         h0_pos_flat = {8'd4, 8'd1, 8'd0}; // mảng bị xoay ngược
//         h1_pos_flat = {8'd3, 8'd2, 8'd1};

//         #20 rst = 0;

//         // // 1️⃣ no error (MUST PASS)
//         // run_test(0, 0);

//         // // 2️⃣ single-bit error (may PASS or FAIL)
//         // run_test(127'b1 << 10, 0);

//         // // 3️⃣ two-bit error
//         // run_test((127'b1 << 5) | (127'b1 << 40), 0);

//         // // 4️⃣ mixed e0/e1
//         // run_test(127'b1 << 12, 127'b1 << 77);

//         //5️⃣ random low-weight
//         run_test(
//             (10'b1 << 2) | (10'b1 << 3),
//             (10'b1 << 1)
//         );

//         $finish;
//     end

// endmodule
