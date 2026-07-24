`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 10:05:25
// Design Name: 
// Module Name: REG_MEM_WB
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

module REG_MEM_WB(
        input clk,
        input rst,
        input CE,
        // Input
        input [`WORD_BITS-1:0] inst_in,
//        input [`DATA_BITS-1:0] PC,
        input [`DATA_BITS-1:0] ALU_out,
        input [1:0] DatatoReg,
        input RegWrite,
        input [`DATA_BITS-1:0] EXE_MEM_wb,
        input ntt_we,
        // Output
        output reg [`WORD_BITS-1:0] MEM_WB_inst_in,
//        output reg [`DATA_BITS-1:0] MEM_WB_PC,
        output reg [`DATA_BITS-1:0] MEM_WB_ALU_out,
        output reg [1:0] MEM_WB_DatatoReg,
//        output reg MEM_WB_W_D,
        output reg MEM_WB_RegWrite,
        output reg [`DATA_BITS-1:0] MEM_WB_wb,
        output reg MEM_WB_ntt_we,
        input ntt_start,
        output reg MEM_WB_ntt_start,
        input [2:0] size,
        output reg [2:0] MEM_WB_size,
        input [`DATA_BITS-1:0] DMEM_addr_in,
        output reg [`DATA_BITS-1:0] MEM_WB_DMEM_addr_in,
        input mem_w,
        output reg MEM_WB_mem_w,
        input pwam_start,
        output reg MEM_WB_pwam_start,
        input pwam_wea,
        output reg MEM_WB_pwam_wea,
        input pwam_web,
        output reg MEM_WB_pwam_web,
        input keccak_start,
        output reg MEM_WB_keccak_start,
        input keccak_we,
        output reg MEM_WB_keccak_we
    );
    always @ (posedge clk or negedge rst) begin
        if (~rst) begin            
//            MEM_WB_PC           <= 0;
            MEM_WB_ALU_out      <= 0;
            MEM_WB_DatatoReg    <= 0;
//            MEM_WB_W_D          <= 0;
            MEM_WB_RegWrite     <= 0;
            MEM_WB_inst_in      <= 32'h00000013;
            MEM_WB_wb     <= 0;
            MEM_WB_ntt_we <= 0;
            MEM_WB_ntt_start <= 0;
            MEM_WB_size <= 0;
            MEM_WB_mem_w <= 0;
            MEM_WB_DMEM_addr_in <= `ZERO;
            MEM_WB_pwam_wea <= 0;
            MEM_WB_pwam_web <= 0;
            MEM_WB_pwam_start <= 0; 
            MEM_WB_keccak_we <= 0;
            MEM_WB_keccak_start <= 0; 
        end
        else if (!CE) begin
//            MEM_WB_PC           <= 0;
            MEM_WB_ALU_out      <= 0;
            MEM_WB_DatatoReg    <= 0;
//            MEM_WB_W_D          <= 0;
            MEM_WB_RegWrite     <= 0;
            MEM_WB_inst_in      <= 32'h00000013;
            MEM_WB_wb     <= 0;
            MEM_WB_ntt_we <= 0;
            MEM_WB_ntt_start <= 0;
            MEM_WB_size <= 0;
            MEM_WB_mem_w <= 0;
            MEM_WB_DMEM_addr_in <= `ZERO;
            MEM_WB_pwam_wea <= 0;
            MEM_WB_pwam_web <= 0;
            MEM_WB_pwam_start <= 0; 
            MEM_WB_keccak_we <= 0;
            MEM_WB_keccak_start <= 0; 
        end
        else if (CE) begin
            
//            MEM_WB_PC           <= PC;
            MEM_WB_ALU_out      <= ALU_out;
            MEM_WB_DatatoReg    <= DatatoReg;
//            MEM_WB_W_D          <= W_D;
            MEM_WB_RegWrite     <= RegWrite;
            MEM_WB_inst_in      <= inst_in;
            MEM_WB_wb           <= EXE_MEM_wb;
            MEM_WB_ntt_we <= ntt_we;
            MEM_WB_ntt_start <= ntt_start;
            MEM_WB_size <= size;
            MEM_WB_mem_w <= mem_w;
            MEM_WB_DMEM_addr_in <= DMEM_addr_in;
            MEM_WB_pwam_wea <= pwam_wea;
            MEM_WB_pwam_web <= pwam_web;
            MEM_WB_pwam_start <= pwam_start; 
            MEM_WB_keccak_we <= keccak_we;
            MEM_WB_keccak_start <= keccak_start; 
        end
    end
endmodule
