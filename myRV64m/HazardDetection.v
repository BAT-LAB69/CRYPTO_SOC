`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// HazardDetection - Load-Use Stall + MulDiv Stall
// Stalls pipeline when:
//   1. Load-use hazard (LOAD in EX, dependent instruction in ID)
//   2. MulDiv unit is busy
//////////////////////////////////////////////////////////////////////////////////

module HazardDetection (
    input  wire [6:0] ID_EXE_opcode,
    input  wire [4:0] ID_EXE_rd,
    input  wire [4:0] IF_ID_rs1,
    input  wire [4:0] IF_ID_rs2,
    input  wire       muldiv_busy,
    input  wire       muldiv_stall,  // idex_is_muldiv && !muldiv_complete

    output reg        PC_stall,
    output reg        IF_ID_stall,
    output reg        ID_EXE_flush
);

    always @(*) begin
        PC_stall     = 1'b0;
        IF_ID_stall  = 1'b0;
        ID_EXE_flush = 1'b0;

        // MulDiv stall: freeze pipeline while MulDiv is computing
        if (muldiv_stall) begin
            PC_stall     = 1'b1;
            IF_ID_stall  = 1'b1;
            // Don't flush ID/EX during muldiv - instruction still executing
        end
        // Load-use hazard
        else if ((ID_EXE_opcode == `OP_I_TYPE_LOAD) && (ID_EXE_rd != 5'b0)) begin
            if ((ID_EXE_rd == IF_ID_rs1) || (ID_EXE_rd == IF_ID_rs2)) begin
                PC_stall     = 1'b1;
                IF_ID_stall  = 1'b1;
                ID_EXE_flush = 1'b1;
            end
        end
    end

endmodule
