`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// NonRestoringDivider - Restoring Division (64 cycles)
//
// Supports: DIV, DIVU, REM, REMU, DIVW, DIVUW, REMW, REMUW
// Uses simple restoring division algorithm.
//
// Special cases per RISC-V spec:
//   - Divide by zero: quotient = all 1s, remainder = dividend
//   - Signed overflow (MIN/-1): quotient = MIN, remainder = 0
//////////////////////////////////////////////////////////////////////////////////

module NonRestoringDivider (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [63:0] rs1,       // Dividend
    input  wire [63:0] rs2,       // Divisor
    input  wire        is_signed, // 1=signed, 0=unsigned
    input  wire        is_word,   // 1=32-bit W-variant
    output reg  [63:0] quotient,
    output reg  [63:0] remainder,
    output wire        busy,
    output reg         done
);

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam FINISH  = 2'd2;

    reg [1:0]  state;
    reg [6:0]  count;
    reg [63:0] R;          // Partial remainder
    reg [63:0] D;          // Divisor (absolute)
    reg [63:0] Q;          // Quotient (built bit by bit)
    reg [63:0] N;          // Dividend shifted out bit by bit
    reg        dividend_neg;
    reg        divisor_neg;
    reg        is_special;
    reg [63:0] sp_q;
    reg [63:0] sp_r;
    reg [6:0]  total_bits; // 64 or 32
    reg        word_mode;

    assign busy = (state != IDLE);

    always @(posedge clk) begin
        if (!rst) begin
            state        <= IDLE;
            done         <= 1'b0;
            quotient     <= 64'b0;
            remainder    <= 64'b0;
            count        <= 7'd0;
            R            <= 64'b0;
            D            <= 64'b0;
            Q            <= 64'b0;
            N            <= 64'b0;
            dividend_neg <= 1'b0;
            divisor_neg  <= 1'b0;
            is_special   <= 1'b0;
            sp_q         <= 64'b0;
            sp_r         <= 64'b0;
            total_bits   <= 7'd0;
            word_mode    <= 1'b0;
        end
        else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    if (start) begin
                        is_special <= 1'b0;
                        word_mode  <= is_word;

                        if (is_word) begin
                            // 32-bit operation
                            dividend_neg <= is_signed && rs1[31];
                            divisor_neg  <= is_signed && rs2[31];
                            total_bits   <= 7'd32;

                            if (rs2[31:0] == 32'd0) begin
                                // Divide by zero
                                is_special <= 1'b1;
                                sp_q <= 64'hFFFFFFFFFFFFFFFF;
                                sp_r <= {{32{rs1[31]}}, rs1[31:0]};
                                state <= FINISH;
                            end
                            else if (is_signed && rs1[31:0] == 32'h80000000 && rs2[31:0] == 32'hFFFFFFFF) begin
                                // Signed overflow
                                is_special <= 1'b1;
                                sp_q <= 64'hFFFFFFFF80000000;
                                sp_r <= 64'd0;
                                state <= FINISH;
                            end
                            else begin
                                R <= 64'd0;
                                D <= {32'd0, (is_signed && rs2[31]) ? (~rs2[31:0] + 32'd1) : rs2[31:0]};
                                N <= {32'd0, (is_signed && rs1[31]) ? (~rs1[31:0] + 32'd1) : rs1[31:0]};
                                Q <= 64'd0;
                                count <= 7'd0;
                                state <= COMPUTE;
                            end
                        end
                        else begin
                            // 64-bit operation
                            dividend_neg <= is_signed && rs1[63];
                            divisor_neg  <= is_signed && rs2[63];
                            total_bits   <= 7'd64;

                            if (rs2 == 64'd0) begin
                                // Divide by zero
                                is_special <= 1'b1;
                                sp_q <= 64'hFFFFFFFFFFFFFFFF;
                                sp_r <= rs1;
                                state <= FINISH;
                            end
                            else if (is_signed && rs1 == 64'h8000000000000000 && rs2 == 64'hFFFFFFFFFFFFFFFF) begin
                                // Signed overflow
                                is_special <= 1'b1;
                                sp_q <= 64'h8000000000000000;
                                sp_r <= 64'd0;
                                state <= FINISH;
                            end
                            else begin
                                R <= 64'd0;
                                D <= (is_signed && rs2[63]) ? (~rs2 + 64'd1) : rs2;
                                N <= (is_signed && rs1[63]) ? (~rs1 + 64'd1) : rs1;
                                Q <= 64'd0;
                                count <= 7'd0;
                                state <= COMPUTE;
                            end
                        end
                    end
                end

                COMPUTE: begin
                    // Restoring division:
                    // 1. Shift R left by 1, bring in MSB of N
                    // 2. Try R - D
                    // 3. If R >= D: quotient bit = 1, R = R - D
                    //    Else: quotient bit = 0, R unchanged

                    // Shift R left, bring in next bit of N
                    if (word_mode) begin
                        R <= {R[62:0], N[31]};
                        N <= {N[63:32], N[30:0], 1'b0};
                    end
                    else begin
                        R <= {R[62:0], N[63]};
                        N <= {N[62:0], 1'b0};
                    end

                    // Compare and subtract
                    if ({R[62:0], (word_mode ? N[31] : N[63])} >= D) begin
                        R <= {R[62:0], (word_mode ? N[31] : N[63])} - D;
                        Q <= {Q[62:0], 1'b1};
                    end
                    else begin
                        Q <= {Q[62:0], 1'b0};
                    end

                    count <= count + 7'd1;
                    if (count == total_bits - 7'd1)
                        state <= FINISH;
                end

                FINISH: begin
                    if (is_special) begin
                        quotient  <= sp_q;
                        remainder <= sp_r;
                    end
                    else begin
                        // Adjust signs
                        if (word_mode) begin
                            // 32-bit result, sign-extend to 64
                            if (dividend_neg ^ divisor_neg)
                                quotient <= {{32{(~Q[31]+1'b0)}}, (~Q[31:0] + 32'd1)};
                            else
                                quotient <= {{32{Q[31]}}, Q[31:0]};

                            if (dividend_neg)
                                remainder <= {{32{(~R[31]+1'b0)}}, (~R[31:0] + 32'd1)};
                            else
                                remainder <= {{32{R[31]}}, R[31:0]};
                        end
                        else begin
                            // 64-bit result
                            if (dividend_neg ^ divisor_neg)
                                quotient <= ~Q + 64'd1;
                            else
                                quotient <= Q;

                            if (dividend_neg)
                                remainder <= ~R + 64'd1;
                            else
                                remainder <= R;
                        end
                    end

                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
