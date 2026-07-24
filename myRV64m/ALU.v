`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// ALU - Arithmetic Logic Unit with CLA64 Carry-Lookahead Adder
//////////////////////////////////////////////////////////////////////////////////

module ALU (
    input  wire [63:0] A,
    input  wire [63:0] B,
    input  wire [`ALU_CTRL_BITS-1:0] ALUOp,
    output reg  [63:0] Result
);

    wire signed [63:0] A_signed = A;
    wire signed [63:0] B_signed = B;

    // ---- CLA64 for 64-bit add/sub ----
    wire [63:0] add_result, sub_result;
    wire        add_cout, sub_cout;

    CLA64 u_add (
        .A(A), .B(B), .cin(1'b0),
        .S(add_result), .cout(add_cout)
    );

    CLA64 u_sub (
        .A(A), .B(~B), .cin(1'b1),     // A - B = A + ~B + 1
        .S(sub_result), .cout(sub_cout)
    );

    // ---- CLA for 32-bit W-type add/sub ----
    wire [63:0] addw_full, subw_full;
    wire        addw_cout, subw_cout;

    CLA64 u_addw (
        .A({32'b0, A[31:0]}), .B({32'b0, B[31:0]}), .cin(1'b0),
        .S(addw_full), .cout(addw_cout)
    );

    CLA64 u_subw (
        .A({32'b0, A[31:0]}), .B({32'b0, ~B[31:0]}), .cin(1'b1),
        .S(subw_full), .cout(subw_cout)
    );

    wire [31:0] addw_result = addw_full[31:0];
    wire [31:0] subw_result = subw_full[31:0];

    // ---- Unified Shifters (Reduces Fanout and Area) ----
    // 1. Unified Left Shifter (SLL, SLLW)
    wire [63:0] sll_in_val = (ALUOp == `ALU_SLLW) ? {32'b0, A[31:0]} : A;
    wire [5:0]  sll_shift_amt = (ALUOp == `ALU_SLLW) ? {1'b0, B[4:0]} : B[5:0];
    wire [63:0] left_shift_out = sll_in_val << sll_shift_amt;

    // 2. Unified Right Shifter (SRL, SRA, SRLW, SRAW)
    // For SRAW, we must pad the top 32 bits of the 64-bit value with A[31] BEFORE shifting?
    // Wait, the RISC-V spec for SRAW says: operate on lower 32 bits, sign-extend the 32-bit result.
    // If we shift the lower 32 bits, the sign bit is A[31].
    // So we can extract the 32-bit value, sign extend it to 64-bits, then shift it!
    // For SRLW, we zero-extend the lower 32-bits to 64-bits, then shift.
    // So, prep the input:
    wire [63:0] right_shift_in = (ALUOp == `ALU_SRAW) ? {{32{A[31]}}, A[31:0]} :
                                 (ALUOp == `ALU_SRLW) ? {32'b0, A[31:0]} :
                                 A;
    
    wire [5:0] right_shift_amt = (ALUOp == `ALU_SRLW || ALUOp == `ALU_SRAW) ? {1'b0, B[4:0]} : B[5:0];
    
    // Choose arithmetic or logical right shift for the 64-bit value
    wire signed [63:0] right_shift_in_signed = right_shift_in;
    wire [63:0] sra_shift_out = right_shift_in_signed >>> right_shift_amt;
    wire [63:0] srl_shift_out = right_shift_in >> right_shift_amt;
    wire [63:0] right_shift_out = (ALUOp == `ALU_SRA || ALUOp == `ALU_SRAW) ? 
                                  sra_shift_out : srl_shift_out;

    always @(*) begin
        case (ALUOp)
            `ALU_ADD:    Result = add_result;
            `ALU_SUB:    Result = sub_result;
            `ALU_AND:    Result = A & B;
            `ALU_OR:     Result = A | B;
            `ALU_XOR:    Result = A ^ B;
            `ALU_SLL:    Result = left_shift_out;
            `ALU_SRL:    Result = right_shift_out;
            `ALU_SRA:    Result = right_shift_out;
            `ALU_SLT:    Result = {63'b0, A_signed < B_signed};
            `ALU_SLTU:   Result = {63'b0, A < B};
            `ALU_LUI:    Result = B;
            `ALU_AUIPC:  Result = add_result;   // PC + imm
            `ALU_ADDW:   Result = {{32{addw_result[31]}}, addw_result};
            `ALU_SUBW:   Result = {{32{subw_result[31]}}, subw_result};
            `ALU_SLLW:   Result = {{32{left_shift_out[31]}}, left_shift_out[31:0]};
            `ALU_SRLW:   Result = {{32{right_shift_out[31]}}, right_shift_out[31:0]};
            `ALU_SRAW:   Result = {{32{right_shift_out[31]}}, right_shift_out[31:0]};
            default:     Result = 64'b0;
        endcase
    end

endmodule
