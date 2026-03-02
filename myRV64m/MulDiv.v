`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// MulDiv - Wrapper for parallel Multiplier and Divider units
//
// Dispatches M-extension operations to the appropriate unit.
// MUL and DIV can run independently (parallel ready/valid).
//////////////////////////////////////////////////////////////////////////////////

module MulDiv (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [`MULDIV_OP_BITS-1:0] op,
    input  wire [63:0] rs1,
    input  wire [63:0] rs2,
    output reg  [63:0] result,
    output wire        busy,
    output wire        done
);

    // Classify operation
    wire is_mul_op = (op <= `MD_MULHU) || (op == `MD_MULW);
    wire is_div_op = !is_mul_op;
    wire is_word   = (op >= `MD_MULW);

    // Sign mode for multiplier: 00=UxU, 01=SxU, 11=SxS
    reg [1:0] mul_sign_mode;
    always @(*) begin
        case (op)
            `MD_MUL, `MD_MULH, `MD_MULW: mul_sign_mode = 2'b11; // SxS
            `MD_MULHSU:                   mul_sign_mode = 2'b01; // SxU
            default:                      mul_sign_mode = 2'b00; // UxU
        endcase
    end

    // Div signed flag
    wire div_is_signed = (op == `MD_DIV) || (op == `MD_REM) ||
                         (op == `MD_DIVW) || (op == `MD_REMW);

    // Start signals
    wire mul_start = start && is_mul_op;
    wire div_start = start && is_div_op;

    // Multiplier
    wire [127:0] mul_product;
    wire         mul_busy, mul_done;

    BoothMultiplier u_mul (
        .clk       (clk),
        .rst       (rst),
        .start     (mul_start),
        .rs1       (rs1),
        .rs2       (rs2),
        .sign_mode (mul_sign_mode),
        .is_word   (is_word),
        .product   (mul_product),
        .busy      (mul_busy),
        .done      (mul_done)
    );

    // Divider
    wire [63:0] div_quotient, div_remainder;
    wire        div_busy, div_done;

    NonRestoringDivider u_div (
        .clk       (clk),
        .rst       (rst),
        .start     (div_start),
        .rs1       (rs1),
        .rs2       (rs2),
        .is_signed (div_is_signed),
        .is_word   (is_word),
        .quotient  (div_quotient),
        .remainder (div_remainder),
        .busy      (div_busy),
        .done      (div_done)
    );

    assign busy = mul_busy || div_busy;
    assign done = mul_done || div_done;

    // Select result based on operation
    reg [`MULDIV_OP_BITS-1:0] saved_op;
    always @(posedge clk) begin
        if (start) saved_op <= op;
    end

    always @(*) begin
        case (saved_op)
            `MD_MUL:    result = mul_product[63:0];
            `MD_MULH:   result = mul_product[127:64];
            `MD_MULHSU: result = mul_product[127:64];
            `MD_MULHU:  result = mul_product[127:64];
            `MD_MULW:   result = {{32{mul_product[63]}}, mul_product[63:32]};
            `MD_DIV, `MD_DIVU, `MD_DIVW, `MD_DIVUW:
                        result = div_quotient;
            `MD_REM, `MD_REMU, `MD_REMW, `MD_REMUW:
                        result = div_remainder;
            default:    result = 64'b0;
        endcase
    end

endmodule
