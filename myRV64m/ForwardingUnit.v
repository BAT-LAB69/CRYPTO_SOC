`include "defines.vh"

module ForwardingUnit (
    input  wire [4:0] ID_EXE_rs1,
    input  wire [4:0] ID_EXE_rs2,

    input  wire [4:0] EXE_MEM_rd,
    input  wire       EXE_MEM_RegWrite,

    input  wire [4:0] MEM_WB_rd,
    input  wire       MEM_WB_RegWrite,

    output reg  [1:0] ForwardA,
    output reg  [1:0] ForwardB
);

    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // Forward A - Priority: EX/MEM > MEM/WB
        if (EXE_MEM_RegWrite && (EXE_MEM_rd != 5'b0) && (EXE_MEM_rd == ID_EXE_rs1)) begin
            ForwardA = 2'b10;
        end
        else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EXE_rs1)) begin
            ForwardA = 2'b01;
        end

        // Forward B - Priority: EX/MEM > MEM/WB
        if (EXE_MEM_RegWrite && (EXE_MEM_rd != 5'b0) && (EXE_MEM_rd == ID_EXE_rs2)) begin
            ForwardB = 2'b10;
        end
        else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EXE_rs2)) begin
            ForwardB = 2'b01;
        end
    end

endmodule
