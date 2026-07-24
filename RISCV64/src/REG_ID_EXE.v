`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 10:05:07
// Design Name: 
// Module Name: REG_ID_EXE
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

module REG_ID_EXE(
        input clk,
        input rst,
        input CE,
        input ID_EXE_dstall,
        input [`WORD_BITS-1:0] inst_in,
        input [`DATA_BITS-1:0] PC,
        input [`DATA_BITS-1:0] ALU_A,
        input [`DATA_BITS-1:0] ALU_B,
        input [`ALU_CTRL_BITS-1:0] ALU_Control,
        input [`DATA_BITS-1:0] Data_out,
        input mem_w,
        input [2:0] size,
        input W_D,
        input [1:0] DatatoReg,
        input RegWrite,
        input [`DATA_BITS-1:0] DMEM_Custom_Address,
        input [`DATA_BITS-1:0] Buffer_data_out,
        input [`DATA_BITS-1:0] DMEM_Custom_Address_ntt,
        
        input [`ADDR_BITS-1:0] written_reg,
//        input [`ADDR_BITS-1:0] read_reg1,
//        input [`ADDR_BITS-1:0] read_reg2,
//        input [`ADDR_BITS-1:0] read_reg3,
        input ntt_we,
        
        output reg [`WORD_BITS-1:0] ID_EXE_inst_in,
        output reg [`DATA_BITS-1:0] ID_EXE_PC = 0,
        output reg [`DATA_BITS-1:0] ID_EXE_ALU_A,
        output reg [`DATA_BITS-1:0] ID_EXE_ALU_B,
        output reg [`ALU_CTRL_BITS-1:0] ID_EXE_ALU_Control,
        output reg [`DATA_BITS-1:0] ID_EXE_Data_out,
        output reg ID_EXE_mem_w,
        output reg [2:0] ID_EXE_size,
        output reg [1:0] ID_EXE_DatatoReg,
        output reg ID_EXE_W_D,
        output reg ID_EXE_RegWrite,
        output reg [`DATA_BITS-1:0] ID_EXE_DMEM_Custom_Address,
        output reg [`DATA_BITS-1:0] ID_EXE_DMEM_Custom_Address_ntt,
        output reg [`DATA_BITS-1:0] ID_EXE_Buffer_data_out,
        
        output reg [`ADDR_BITS-1:0] ID_EXE_written_reg,
        output reg ID_EXE_ntt_we,
        input ntt_start,
        output reg ID_EXE_ntt_start,
        input [`DATA_BITS-1:0] counter,
        output reg [`DATA_BITS-1:0] ID_EXE_counter,
        input [`DATA_BITS-1:0] DMEM_Custom_Address_pwam,
        output reg [`DATA_BITS-1:0] ID_EXE_DMEM_Custom_Address_pwam,
        input pwam_start,
        output reg ID_EXE_pwam_start,
        input pwam_wea,
        output reg ID_EXE_pwam_wea,
        input pwam_web,
        output reg ID_EXE_pwam_web,
        input [1:0] dmem_addr_sel,
        output reg [1:0] ID_EXE_dmem_addr_sel,
        input [1:0] dmem_data_sel,
        output reg [1:0] ID_EXE_dmem_data_sel,
        input alu_sel,
        output reg ID_EXE_alu_sel,
        input keccak_start,
        output reg ID_EXE_keccak_start,
        input keccak_we,
        output reg ID_EXE_keccak_we
    );
    always @ (posedge clk or negedge rst) begin
        if (~rst) begin
            ID_EXE_inst_in      <= `NOP_INST;
            ID_EXE_PC           <= `ZERO;
            ID_EXE_ALU_A        <= `ZERO;
            ID_EXE_ALU_B        <= `ZERO;
            ID_EXE_ALU_Control  <= `ALU_CTRL_BITS'b000000;
            ID_EXE_Data_out     <= `ZERO;
            ID_EXE_mem_w        <= 1'b0;
            ID_EXE_size         <= 3'b011;
            ID_EXE_DatatoReg    <= 2'b00;
            ID_EXE_W_D          <= 1'b0;
            ID_EXE_RegWrite     <= 1'b0;
            ID_EXE_DMEM_Custom_Address  <= `ZERO;
            ID_EXE_DMEM_Custom_Address_ntt  <= `ZERO;
            ID_EXE_Buffer_data_out <= `ZERO;
            
            ID_EXE_written_reg  <= `ADDR_BITS'b00000;
            ID_EXE_ntt_we <= 0;
            ID_EXE_ntt_start <= 0;         
            ID_EXE_counter <= `ZERO;  
            ID_EXE_DMEM_Custom_Address_pwam <= `ZERO; 
            ID_EXE_pwam_wea <= 0;
            ID_EXE_pwam_web <= 0;
            ID_EXE_pwam_start <= 0; 
            ID_EXE_dmem_addr_sel <= 0;
            ID_EXE_dmem_data_sel <= 0;
            ID_EXE_alu_sel <= 0;
            ID_EXE_keccak_we <= 0;
            ID_EXE_keccak_start <= 0; 
        end
        else if (ID_EXE_dstall) begin
            ID_EXE_inst_in      <= `NOP_INST;
            ID_EXE_PC           <= `ZERO;
            ID_EXE_ALU_A        <= `ZERO;
            ID_EXE_ALU_B        <= `ZERO;
            ID_EXE_ALU_Control  <= `ALU_CTRL_BITS'b000000;
            ID_EXE_Data_out     <= `ZERO;
            ID_EXE_mem_w        <= 1'b0;
            ID_EXE_size         <= 3'b011;
            ID_EXE_DatatoReg    <= 2'b00;
            ID_EXE_W_D          <= 1'b0;
            ID_EXE_RegWrite     <= 1'b0;
            ID_EXE_DMEM_Custom_Address  <= `ZERO;
            ID_EXE_DMEM_Custom_Address_ntt  <= `ZERO;
            ID_EXE_Buffer_data_out <= `ZERO;
            
            ID_EXE_written_reg  <= `ADDR_BITS'b00000;
            ID_EXE_ntt_we <= 0;
            ID_EXE_ntt_start <= 0;   
            ID_EXE_counter <= `ZERO;  
            ID_EXE_DMEM_Custom_Address_pwam <= `ZERO; 
            ID_EXE_pwam_wea <= 0;
            ID_EXE_pwam_web <= 0;
            ID_EXE_pwam_start <= 0; 
            ID_EXE_dmem_addr_sel <= 0;
            ID_EXE_dmem_data_sel <= 0;
            ID_EXE_alu_sel <= 0;
            ID_EXE_keccak_we <= 0;
            ID_EXE_keccak_start <= 0; 
        end
        else if (CE) begin
            ID_EXE_inst_in      <= inst_in;
            ID_EXE_PC           <= PC;
            ID_EXE_ALU_A        <= ALU_A;
            ID_EXE_ALU_B        <= ALU_B;
            ID_EXE_ALU_Control  <= ALU_Control;
            ID_EXE_Data_out     <= Data_out;
            ID_EXE_mem_w        <= mem_w;
            ID_EXE_size         <= size;
            ID_EXE_DatatoReg    <= DatatoReg;
            ID_EXE_RegWrite     <= RegWrite;
            ID_EXE_W_D          <= W_D;
            ID_EXE_DMEM_Custom_Address  <= DMEM_Custom_Address;
            ID_EXE_DMEM_Custom_Address_ntt  <= DMEM_Custom_Address_ntt;
            ID_EXE_Buffer_data_out <= Buffer_data_out;
            
            ID_EXE_written_reg  <= written_reg;
            ID_EXE_ntt_we <= ntt_we;
            ID_EXE_ntt_start <= ntt_start;
            ID_EXE_counter <= counter;
            ID_EXE_DMEM_Custom_Address_pwam <= DMEM_Custom_Address_pwam; 
            ID_EXE_pwam_wea <= pwam_wea;
            ID_EXE_pwam_web <= pwam_web;
            ID_EXE_pwam_start <= pwam_start; 
            ID_EXE_dmem_addr_sel <= dmem_addr_sel;
            ID_EXE_dmem_data_sel <= dmem_data_sel;
            ID_EXE_alu_sel <= alu_sel;
            ID_EXE_keccak_we <= keccak_we;
            ID_EXE_keccak_start <= keccak_start; 
        end
        else begin
            ID_EXE_inst_in      <= `NOP_INST;
            ID_EXE_PC           <= `ZERO;
            ID_EXE_ALU_A        <= `ZERO;
            ID_EXE_ALU_B        <= `ZERO;
            ID_EXE_ALU_Control  <= `ALU_CTRL_BITS'b000000;
            ID_EXE_Data_out     <= `ZERO;
            ID_EXE_mem_w        <= 1'b0;
            ID_EXE_size         <= 3'b011;
            ID_EXE_DatatoReg    <= 2'b00;
            ID_EXE_RegWrite     <= 1'b0;
            ID_EXE_W_D          <= 1'b0;
            ID_EXE_DMEM_Custom_Address  <= `ZERO;
            ID_EXE_DMEM_Custom_Address_ntt  <= `ZERO;
            ID_EXE_Buffer_data_out <= `ZERO;
            
            ID_EXE_written_reg  <= `ADDR_BITS'b00000;
//            ID_EXE_read_reg1    <= `ADDR_BITS'b00000;
//            ID_EXE_read_reg2    <= `ADDR_BITS'b00000;
//            ID_EXE_read_reg3    <= `ADDR_BITS'b00000;
            ID_EXE_ntt_we <= 0;
            ID_EXE_ntt_start <= 0;
            ID_EXE_counter <= `ZERO;
            ID_EXE_DMEM_Custom_Address_pwam <= `ZERO; 
            ID_EXE_pwam_wea <= 0;
            ID_EXE_pwam_web <= 0;
            ID_EXE_pwam_start <= 0; 
            ID_EXE_dmem_addr_sel <= 0; 
            ID_EXE_dmem_data_sel <= 0;
            ID_EXE_alu_sel <= 0;
            ID_EXE_keccak_we <= 0;
            ID_EXE_keccak_start <= 0; 
        end
    end   
endmodule