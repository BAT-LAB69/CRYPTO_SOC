`include "defines.vh"

module REG_ID_EXE (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        flush,

    input  wire [63:0] pc_in,
    input  wire [63:0] rs1_data_in,
    input  wire [63:0] rs2_data_in,
    input  wire [63:0] imm_in,
    input  wire [4:0]  rd_in,
    input  wire [4:0]  rs1_addr_in,
    input  wire [4:0]  rs2_addr_in,
    input  wire [31:0] inst_in,

    input  wire [1:0]  ALUSrc_A_in,
    input  wire        ALUSrc_B_in,
    input  wire [1:0]  MemtoReg_in,
    input  wire        RegWrite_in,
    input  wire        MemWrite_in,
    input  wire [`ALU_CTRL_BITS-1:0] ALUOp_in,
    input  wire [2:0]  size_in,

    // Branch info (new for EX-stage branch)
    input  wire        is_branch_in,
    input  wire        is_jal_in,
    input  wire        is_jalr_in,
    input  wire [2:0]  branch_funct3_in,

    // M-extension
    input  wire        is_muldiv_in,
    input  wire [`MULDIV_OP_BITS-1:0] muldiv_op_in,

    (* max_fanout = "50" *) output reg  [63:0] pc_out,
    (* max_fanout = "50" *) output reg  [63:0] rs1_data_out,
    (* max_fanout = "50" *) output reg  [63:0] rs2_data_out,
    (* max_fanout = "50" *) output reg  [63:0] imm_out,
    (* max_fanout = "10" *) output reg  [4:0]  rd_out,

    // Sliced RS1/RS2 address for 4-way Forwarding Muxes
    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs1_addr_out_0,
    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs1_addr_out_1,
    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs1_addr_out_2,
    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs1_addr_out_3,

    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs2_addr_out_0,
    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs2_addr_out_1,
    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs2_addr_out_2,
    (* DONT_TOUCH = "TRUE" *) output reg  [4:0]  rs2_addr_out_3,

    (* max_fanout = "50" *) output reg  [31:0] inst_out,

    (* max_fanout = "16" *) output reg  [1:0]  ALUSrc_A_out,
    (* max_fanout = "16" *) output reg         ALUSrc_B_out,
    output reg  [1:0]  MemtoReg_out,
    output reg         RegWrite_out,
    output reg         MemWrite_out,
    output reg  [`ALU_CTRL_BITS-1:0] ALUOp_out,
    output reg  [2:0]  size_out,

    output reg         is_branch_out,
    output reg         is_jal_out,
    output reg         is_jalr_out,
    output reg  [2:0]  branch_funct3_out,

    output reg         is_muldiv_out,
    output reg  [`MULDIV_OP_BITS-1:0] muldiv_op_out
);

    always @(posedge clk) begin
        if (!rst || flush) begin
            pc_out        <= `ZERO;
            rs1_data_out  <= `ZERO;
            rs2_data_out  <= `ZERO;
            imm_out       <= `ZERO;
            rd_out        <= 5'b0;
            rs1_addr_out_0 <= 5'b0;
            rs1_addr_out_1 <= 5'b0;
            rs1_addr_out_2 <= 5'b0;
            rs1_addr_out_3 <= 5'b0;
            rs2_addr_out_0 <= 5'b0;
            rs2_addr_out_1 <= 5'b0;
            rs2_addr_out_2 <= 5'b0;
            rs2_addr_out_3 <= 5'b0;
            inst_out      <= `NOP_INST;
            ALUSrc_A_out  <= 2'b00;
            ALUSrc_B_out  <= 1'b0;
            MemtoReg_out  <= 2'b00;
            RegWrite_out  <= 1'b0;
            MemWrite_out  <= 1'b0;
            ALUOp_out     <= `ALU_DEFAULT;
            size_out      <= 3'd3;
            is_branch_out <= 1'b0;
            is_jal_out    <= 1'b0;
            is_jalr_out   <= 1'b0;
            branch_funct3_out <= 3'b0;
            is_muldiv_out <= 1'b0;
            muldiv_op_out <= 4'd0;
        end
        else if (en) begin
            pc_out        <= pc_in;
            rs1_data_out  <= rs1_data_in;
            rs2_data_out  <= rs2_data_in;
            imm_out       <= imm_in;
            rd_out        <= rd_in;
            rs1_addr_out_0 <= rs1_addr_in;
            rs1_addr_out_1 <= rs1_addr_in;
            rs1_addr_out_2 <= rs1_addr_in;
            rs1_addr_out_3 <= rs1_addr_in;
            rs2_addr_out_0 <= rs2_addr_in;
            rs2_addr_out_1 <= rs2_addr_in;
            rs2_addr_out_2 <= rs2_addr_in;
            rs2_addr_out_3 <= rs2_addr_in;
            inst_out      <= inst_in;
            ALUSrc_A_out  <= ALUSrc_A_in;
            ALUSrc_B_out  <= ALUSrc_B_in;
            MemtoReg_out  <= MemtoReg_in;
            RegWrite_out  <= RegWrite_in;
            MemWrite_out  <= MemWrite_in;
            ALUOp_out     <= ALUOp_in;
            size_out      <= size_in;
            is_branch_out <= is_branch_in;
            is_jal_out    <= is_jal_in;
            is_jalr_out   <= is_jalr_in;
            branch_funct3_out <= branch_funct3_in;
            is_muldiv_out <= is_muldiv_in;
            muldiv_op_out <= muldiv_op_in;
        end
    end

endmodule
