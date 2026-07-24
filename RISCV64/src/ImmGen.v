`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:30:45
// Design Name: 
// Module Name: ImmGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "common.vh"

module ImmGen(
    input [`XLEN-1:0] inst_32,
    output reg [`DATA_BITS-1:0] imm_64
    );
    
    always @ (*) begin
        imm_64 = 0;
        case (inst_32[6:0]) 
            // L
            7'b0000011: begin
                imm_64 = {{52{inst_32[31]}}, inst_32[31:20]};
            end
            // I
            7'b0010011,7'b0011011: begin
                case (inst_32[14:12])
                    // slli, srli, srai: unsigned
                    3'b001, 3'b101: begin
                        imm_64 = {58'b0, inst_32[25:20]};
                    end
                    // other I instructions
                    default: begin
                        imm_64 = {{52{inst_32[31]}}, inst_32[31:20]};
                    end
                endcase
            end
            // SB, SH, SW
            7'b0100011: begin 
                imm_64 = {{52{inst_32[31]}}, inst_32[31:25], inst_32[11:7]};
            end
            // Branch
            7'b1100011: begin
                imm_64 = {{51{inst_32[31]}}, inst_32[31], inst_32[7], inst_32[30:25], inst_32[11:8], 1'b0};
            end
            7'b0001011:
                imm_64 = {{52{inst_32[31]}}, inst_32[31:20]};
            7'b0110111, 7'b0010111: //LUI, AUIPC
                imm_64 = {{32{inst_32[31]}},inst_32[31:12], 12'b0};
            default: imm_64 = 0;
        endcase
    end

endmodule

