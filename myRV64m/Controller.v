`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// Controller - Main Control Unit (RV64M)
// Decodes instruction into control signals.
// Branch decision REMOVED from ID — moved to EX stage.
// M-extension: outputs is_muldiv + muldiv_op for MulDiv unit.
//////////////////////////////////////////////////////////////////////////////////

module Controller (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    // No BrEq/BrLT inputs - branch resolved in EX

    output reg  [1:0] ALUSrc_A,
    output reg        ALUSrc_B,
    output reg  [1:0] MemtoReg,
    output reg        RegWrite,
    output reg        MemWrite,
    output reg  [`ALU_CTRL_BITS-1:0] ALUOp,
    output reg  [2:0] size,

    // Branch info (passed to EX via ID/EX register)
    output reg        is_branch,
    output reg        is_jal,
    output reg        is_jalr,

    // M-extension
    output reg        is_muldiv,
    output reg  [`MULDIV_OP_BITS-1:0] muldiv_op
);

    always @(*) begin
        // Defaults
        ALUSrc_A  = 2'b00;
        ALUSrc_B  = 1'b0;
        MemtoReg  = 2'b00;
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        ALUOp     = `ALU_DEFAULT;
        size      = 3'd3;
        is_branch = 1'b0;
        is_jal    = 1'b0;
        is_jalr   = 1'b0;
        is_muldiv = 1'b0;
        muldiv_op = 4'd0;

        case (opcode)
            // R-TYPE (64-bit)
            `OP_R_TYPE: begin
                RegWrite = 1'b1;
                if (funct7 == `FUNCT7_MULDIV) begin
                    // M-extension
                    is_muldiv = 1'b1;
                    ALUOp = `ALU_ADD; // dummy, MulDiv handles computation
                    case (funct3)
                        3'b000: muldiv_op = `MD_MUL;
                        3'b001: muldiv_op = `MD_MULH;
                        3'b010: muldiv_op = `MD_MULHSU;
                        3'b011: muldiv_op = `MD_MULHU;
                        3'b100: muldiv_op = `MD_DIV;
                        3'b101: muldiv_op = `MD_DIVU;
                        3'b110: muldiv_op = `MD_REM;
                        3'b111: muldiv_op = `MD_REMU;
                        default: muldiv_op = `MD_MUL;
                    endcase
                end
                else begin
                    case (funct7)
                        7'b0000000: begin
                            case (funct3)
                                3'b000: ALUOp = `ALU_ADD;
                                3'b001: ALUOp = `ALU_SLL;
                                3'b010: ALUOp = `ALU_SLT;
                                3'b011: ALUOp = `ALU_SLTU;
                                3'b100: ALUOp = `ALU_XOR;
                                3'b101: ALUOp = `ALU_SRL;
                                3'b110: ALUOp = `ALU_OR;
                                3'b111: ALUOp = `ALU_AND;
                                default: ALUOp = `ALU_DEFAULT;
                            endcase
                        end
                        7'b0100000: begin
                            case (funct3)
                                3'b000: ALUOp = `ALU_SUB;
                                3'b101: ALUOp = `ALU_SRA;
                                default: ALUOp = `ALU_DEFAULT;
                            endcase
                        end
                        default: ALUOp = `ALU_DEFAULT;
                    endcase
                end
            end

            // R-TYPE-W (32-bit)
            `OP_R_TYPE_W: begin
                RegWrite = 1'b1;
                ALUSrc_A = 2'b01;
                if (funct7 == `FUNCT7_MULDIV) begin
                    is_muldiv = 1'b1;
                    ALUOp = `ALU_ADD;
                    case (funct3)
                        3'b000: muldiv_op = `MD_MULW;
                        3'b100: muldiv_op = `MD_DIVW;
                        3'b101: muldiv_op = `MD_DIVUW;
                        3'b110: muldiv_op = `MD_REMW;
                        3'b111: muldiv_op = `MD_REMUW;
                        default: muldiv_op = `MD_MULW;
                    endcase
                end
                else begin
                    case (funct7)
                        7'b0000000: begin
                            case (funct3)
                                3'b000: ALUOp = `ALU_ADDW;
                                3'b001: ALUOp = `ALU_SLLW;
                                3'b101: ALUOp = `ALU_SRLW;
                                default: ALUOp = `ALU_DEFAULT;
                            endcase
                        end
                        7'b0100000: begin
                            case (funct3)
                                3'b000: ALUOp = `ALU_SUBW;
                                3'b101: ALUOp = `ALU_SRAW;
                                default: ALUOp = `ALU_DEFAULT;
                            endcase
                        end
                        default: ALUOp = `ALU_DEFAULT;
                    endcase
                end
            end

            // I-TYPE ALU
            `OP_I_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc_B = 1'b1;
                case (funct3)
                    3'b000: ALUOp = `ALU_ADD;
                    3'b001: ALUOp = `ALU_SLL;
                    3'b010: ALUOp = `ALU_SLT;
                    3'b011: ALUOp = `ALU_SLTU;
                    3'b100: ALUOp = `ALU_XOR;
                    3'b101: ALUOp = (funct7[6:1] == 6'b010000) ? `ALU_SRA : `ALU_SRL;
                    3'b110: ALUOp = `ALU_OR;
                    3'b111: ALUOp = `ALU_AND;
                    default: ALUOp = `ALU_DEFAULT;
                endcase
            end

            // I-TYPE-W
            `OP_I_TYPE_W: begin
                RegWrite = 1'b1;
                ALUSrc_B = 1'b1;
                ALUSrc_A = 2'b01;
                case (funct3)
                    3'b000: ALUOp = `ALU_ADDW;
                    3'b001: ALUOp = `ALU_SLLW;
                    3'b101: ALUOp = (funct7 == 7'b0100000) ? `ALU_SRAW : `ALU_SRLW;
                    default: ALUOp = `ALU_DEFAULT;
                endcase
            end

            // LOAD
            `OP_I_TYPE_LOAD: begin
                ALUOp    = `ALU_ADD;
                MemtoReg = 2'b01;
                RegWrite = 1'b1;
                ALUSrc_B = 1'b1;
                case (funct3)
                    3'b000: size = 3'd0;  // LB
                    3'b001: size = 3'd1;  // LH
                    3'b010: size = 3'd2;  // LW
                    3'b011: size = 3'd3;  // LD
                    3'b100: size = 3'd4;  // LBU
                    3'b101: size = 3'd5;  // LHU
                    3'b110: size = 3'd6;  // LWU
                    default: size = 3'd3;
                endcase
            end

            // STORE
            `OP_S_TYPE: begin
                ALUOp    = `ALU_ADD;
                MemWrite = 1'b1;
                ALUSrc_B = 1'b1;
                case (funct3)
                    3'b000: size = 3'd0;  // SB
                    3'b001: size = 3'd1;  // SH
                    3'b010: size = 3'd2;  // SW
                    3'b011: size = 3'd3;  // SD
                    default: size = 3'd3;
                endcase
            end

            // BRANCH — only set flag, decision made in EX
            `OP_B_TYPE: begin
                is_branch = 1'b1;
            end

            // JAL
            `OP_J_TYPE: begin
                is_jal   = 1'b1;
                MemtoReg = 2'b11;
                RegWrite = 1'b1;
            end

            // JALR
            `OP_I_TYPE_JALR: begin
                is_jalr  = 1'b1;
                MemtoReg = 2'b11;
                RegWrite = 1'b1;
            end

            // LUI
            `OP_U_TYPE_LUI: begin
                ALUOp    = `ALU_LUI;
                ALUSrc_A = 2'b10;
                ALUSrc_B = 1'b1;
                RegWrite = 1'b1;
            end

            // AUIPC
            `OP_U_TYPE_AUIPC: begin
                ALUOp    = `ALU_AUIPC;
                ALUSrc_A = 2'b10;
                ALUSrc_B = 1'b1;
                RegWrite = 1'b1;
            end

            default: begin
                ALUOp = `ALU_DEFAULT;
            end
        endcase
    end

endmodule
