`include "defines.vh"

module REG_EXE_MEM (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,

    input  wire [63:0] pc_in,
    input  wire [63:0] alu_result_in,
    input  wire [63:0] rs2_data_in,
    input  wire [4:0]  rd_in,
    input  wire [31:0] inst_in,

    input  wire [1:0]  MemtoReg_in,
    input  wire        RegWrite_in,
    input  wire        MemWrite_in,
    input  wire [2:0]  size_in,

    output reg  [63:0] pc_out,
    output reg  [63:0] alu_result_out,
    output reg  [63:0] rs2_data_out,
    (* max_fanout = "10" *) output reg  [4:0]  rd_out,
    output reg  [31:0] inst_out,

    output reg  [1:0]  MemtoReg_out,
    (* max_fanout = "10" *) output reg         RegWrite_out,
    output reg         MemWrite_out,
    output reg  [2:0]  size_out
);

    always @(posedge clk) begin
        if (!rst) begin
            pc_out         <= `ZERO;
            alu_result_out <= `ZERO;
            rs2_data_out   <= `ZERO;
            rd_out         <= 5'b0;
            inst_out       <= `NOP_INST;
            MemtoReg_out   <= 2'b00;
            RegWrite_out   <= 1'b0;
            MemWrite_out   <= 1'b0;
            size_out       <= 3'd3;
        end
        else if (en) begin
            pc_out         <= pc_in;
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            rd_out         <= rd_in;
            inst_out       <= inst_in;
            MemtoReg_out   <= MemtoReg_in;
            RegWrite_out   <= RegWrite_in;
            MemWrite_out   <= MemWrite_in;
            size_out       <= size_in;
        end
    end

endmodule
