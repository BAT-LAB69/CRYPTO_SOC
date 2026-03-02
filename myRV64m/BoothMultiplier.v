`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// BoothMultiplier - Iterative Shift-and-Add Multiplier
//
// Processes 2 bits per cycle (Radix-4 style).
// Supports: MUL, MULH, MULHSU, MULHU, MULW
// Ready/valid interface.
//////////////////////////////////////////////////////////////////////////////////

module BoothMultiplier (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [63:0] rs1,
    input  wire [63:0] rs2,
    input  wire [1:0]  sign_mode,   // 00=UxU, 01=SxU, 11=SxS
    input  wire        is_word,     // 1=32-bit W-variant
    output reg  [127:0] product,
    output wire        busy,
    output reg         done
);

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam FINISH  = 2'd2;

    reg [1:0]   state;
    reg [6:0]   count;
    reg [127:0] acc;       // Accumulator (upper half accumulates, lower half is multiplier)
    reg [63:0]  mcand;     // Multiplicand (absolute value)
    reg         neg_result;// Negate final result
    reg [5:0]   num_iters; // 64 or 32

    assign busy = (state != IDLE);

    // Absolute values for signed operations
    wire [63:0] abs_rs1 = (sign_mode[1] && rs1[63]) ? (~rs1 + 64'd1) : rs1;
    wire [63:0] abs_rs2 = ((sign_mode[1] || sign_mode[0]) && sign_mode != 2'b01 && rs2[63]) ? (~rs2 + 64'd1) :
                          (sign_mode == 2'b01) ? rs2 :  // SxU: rs2 is unsigned
                          rs2;
    // For SxU: rs2 is unsigned, so don't negate
    // For SxS: both signed, negate if negative
    // For UxU: neither signed

    wire need_neg_rs2 = (sign_mode == 2'b11) && rs2[63]; // SxS and rs2 negative

    always @(posedge clk) begin
        if (!rst) begin
            state      <= IDLE;
            done       <= 1'b0;
            product    <= 128'b0;
            acc        <= 128'b0;
            mcand      <= 64'b0;
            count      <= 7'd0;
            neg_result <= 1'b0;
            num_iters  <= 6'd0;
        end
        else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    if (start) begin
                        if (is_word) begin
                            // W-variant: use 32-bit absolute values
                            mcand <= {32'b0, (sign_mode[1] && rs1[31]) ? (~rs1[31:0] + 32'd1) : rs1[31:0]};
                            acc   <= {96'b0, (need_neg_rs2 && rs2[31]) ? (~rs2[31:0] + 32'd1) :
                                      (sign_mode == 2'b01) ? rs2[31:0] :
                                      ((sign_mode == 2'b11) && rs2[31]) ? (~rs2[31:0] + 32'd1) : rs2[31:0]};
                            neg_result <= (sign_mode == 2'b11) ? (rs1[31] ^ rs2[31]) :
                                          (sign_mode == 2'b01) ? rs1[31] : 1'b0;
                            num_iters <= 6'd31; // 32 iterations: count 0..31
                        end
                        else begin
                            mcand <= abs_rs1;
                            acc   <= {64'b0, need_neg_rs2 ? (~rs2 + 64'd1) :
                                      (sign_mode == 2'b01) ? rs2 : abs_rs2};
                            neg_result <= (sign_mode == 2'b11) ? (rs1[63] ^ rs2[63]) :
                                          (sign_mode == 2'b01) ? rs1[63] : 1'b0;
                            num_iters <= 6'd63;
                        end
                        count <= 7'd0;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    // Shift-and-add: if LSB of lower half is 1, add multiplicand to upper half
                    if (acc[0])
                        acc <= {(acc[127:64] + mcand), acc[63:1]};
                    else
                        acc <= {acc[127:64], acc[63:1]};

                    count <= count + 7'd1;
                    if (count == {1'b0, num_iters})
                        state <= FINISH;
                end

                FINISH: begin
                    if (neg_result)
                        product <= ~acc + 128'd1;
                    else
                        product <= acc;
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
