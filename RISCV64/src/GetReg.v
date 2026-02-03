`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:29:41
// Design Name: 
// Module Name: GetReg
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

module GetReg(
        input [`WORD_BITS-1:0] inst_in,
        output reg [`ADDR_BITS-1:0] written_reg,
        output reg [`ADDR_BITS-1:0] read_reg1,
        output reg [`ADDR_BITS-1:0] read_reg2,
        output reg [`ADDR_BITS-1:0] read_reg3
    );
    always @ (*) begin
        written_reg = `ADDR_BITS_ZERO;
        read_reg1 = `ADDR_BITS_ZERO;
        read_reg2 = `ADDR_BITS_ZERO;
        read_reg3 = `ADDR_BITS_ZERO;
        case (inst_in[6:0]) 
            7'b0110111, 7'b0010111, 7'b1101111: begin // LUI, AUIPC, JAL
                written_reg = inst_in[11:7];
            end
            // JALR
            // L
            // I
            7'b1100111,
            7'b0000011,
            7'b0010011: begin
                written_reg = inst_in[11:7];
                read_reg1 = inst_in[19:15];
            end
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            // SB, SH, SW
            7'b1100011,
            7'b0100011: begin 
                read_reg1 = inst_in[19:15];
                read_reg2 = inst_in[24:20];
            end
             // R, CustomOpcode-Rtype
            7'b0110011,
            7'b0001011: begin
                written_reg = inst_in[11:7];
                read_reg1 = inst_in[19:15];
                read_reg2 = inst_in[24:20];
            end
            7'b0101011: begin //3rs, 1rd instruction
                written_reg = inst_in[11:7];
                read_reg1 = inst_in[19:15];
                read_reg2 = inst_in[24:20];
                read_reg3 = inst_in[31:27];
            end
            default: begin
                written_reg = inst_in[11:7];
                read_reg1 = inst_in[19:15];
                read_reg2 = inst_in[24:20];
                read_reg3 = inst_in[31:27];
            end
        endcase
    end
endmodule
