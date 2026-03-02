`include "defines.vh"

module ImmGen (
    input  wire [31:0] inst,
    output reg  [63:0] imm
);

    always @(*) begin
        imm = 64'b0;
        case (inst[6:0])
            `OP_I_TYPE_LOAD: begin
                imm = {{52{inst[31]}}, inst[31:20]};
            end

            `OP_I_TYPE, `OP_I_TYPE_W: begin
                case (inst[14:12])
                    3'b001, 3'b101: begin
                        imm = {58'b0, inst[25:20]};
                    end
                    default: begin
                        imm = {{52{inst[31]}}, inst[31:20]};
                    end
                endcase
            end

            `OP_I_TYPE_JALR: begin
                imm = {{52{inst[31]}}, inst[31:20]};
            end

            `OP_S_TYPE: begin
                imm = {{52{inst[31]}}, inst[31:25], inst[11:7]};
            end

            `OP_B_TYPE: begin
                imm = {{51{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end

            `OP_U_TYPE_LUI, `OP_U_TYPE_AUIPC: begin
                imm = {{32{inst[31]}}, inst[31:12], 12'b0};
            end

            `OP_J_TYPE: begin
                imm = {{43{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end

            default: imm = 64'b0;
        endcase
    end

endmodule
