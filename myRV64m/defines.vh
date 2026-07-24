//////////////////////////////////////////////////////////////////////////////////
//                   RISC-V RV64M Processor - Global Defines                    //
//////////////////////////////////////////////////////////////////////////////////

// Data widths
`define DATA_BITS       64
`define WORD_BITS       32
`define ADDR_BITS       5

// Constants
`define ZERO            64'h0000000000000000
`define NOP_INST        32'h00000013    // addi x0, x0, 0

// Memory parameters
`define IMEM_DEPTH      4096
`define DMEM_DEPTH      8192

//////////////////////////////////////////////////////////////////////////////////
//                          INSTRUCTION OPCODES                                 //
//////////////////////////////////////////////////////////////////////////////////
`define OP_R_TYPE       7'b0110011
`define OP_R_TYPE_W     7'b0111011
`define OP_I_TYPE       7'b0010011
`define OP_I_TYPE_W     7'b0011011
`define OP_I_TYPE_LOAD  7'b0000011
`define OP_I_TYPE_JALR  7'b1100111
`define OP_S_TYPE       7'b0100011
`define OP_B_TYPE       7'b1100011
`define OP_U_TYPE_LUI   7'b0110111
`define OP_U_TYPE_AUIPC 7'b0010111
`define OP_J_TYPE       7'b1101111

// M-extension funct7
`define FUNCT7_MULDIV   7'b0000001

//////////////////////////////////////////////////////////////////////////////////
//                             ALU CONTROL CODES                                //
//////////////////////////////////////////////////////////////////////////////////
`define ALU_CTRL_BITS   5
`define ALU_ADD         5'b00000
`define ALU_SUB         5'b00001
`define ALU_SLL         5'b00010
`define ALU_SLT         5'b00011
`define ALU_SLTU        5'b00100
`define ALU_XOR         5'b00101
`define ALU_SRL         5'b00110
`define ALU_SRA         5'b00111
`define ALU_OR          5'b01000
`define ALU_AND         5'b01001
`define ALU_LUI         5'b01010
`define ALU_AUIPC       5'b01011
`define ALU_ADDW        5'b01100
`define ALU_SUBW        5'b01101
`define ALU_SLLW        5'b01110
`define ALU_SRLW        5'b01111
`define ALU_SRAW        5'b10000
`define ALU_DEFAULT     5'b11111

//////////////////////////////////////////////////////////////////////////////////
//                          MULDIV OPERATION CODES                              //
//////////////////////////////////////////////////////////////////////////////////
`define MULDIV_OP_BITS  4
`define MD_MUL          4'd0
`define MD_MULH         4'd1
`define MD_MULHSU       4'd2
`define MD_MULHU        4'd3
`define MD_DIV          4'd4
`define MD_DIVU         4'd5
`define MD_REM          4'd6
`define MD_REMU         4'd7
`define MD_MULW         4'd8
`define MD_DIVW         4'd9
`define MD_DIVUW        4'd10
`define MD_REMW         4'd11
`define MD_REMUW        4'd12
