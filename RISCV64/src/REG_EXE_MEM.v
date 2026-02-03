`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 10:05:58
// Design Name: 
// Module Name: REG_EXE_MEM
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

module REG_EXE_MEM(
        input clk,
        input rst,
        input CE,
        // Input
        input [`WORD_BITS-1:0] inst_in,
        input [`DATA_BITS-1:0] PC,
        input [`DATA_BITS-1:0] ALU_out,
        input [`DATA_BITS-1:0] Data_out,
        input mem_w,
        input [2:0] size,
        input [1:0] DatatoReg,
        input RegWrite,
        input W_D,
//        input [`DATA_BITS-1:0] Buffer_Base_Address,
//        input [`DATA_BITS-1:0] Buffer_Load_Amount,
//        input [`DATA_BITS-1:0] DMEM_Base_Address,
        input [`DATA_BITS-1:0] DMEM_Custom_Address,
        input [`DATA_BITS-1:0] DMEM_Custom_Address_ntt,
        input [`DATA_BITS-1:0] Buffer_data_out,
        
        input [`ADDR_BITS-1:0] written_reg,
//        input [`ADDR_BITS-1:0] read_reg1,
//        input [`ADDR_BITS-1:0] read_reg2,
//        input [`ADDR_BITS-1:0] read_reg3,  
        input ntt_we, 
        // Output
        output reg [`WORD_BITS-1:0] EXE_MEM_inst_in,
        output reg [`DATA_BITS-1:0] EXE_MEM_PC = 0,
        output reg [`DATA_BITS-1:0] EXE_MEM_ALU_out,
        output reg [`DATA_BITS-1:0] EXE_MEM_Data_out,
        output reg EXE_MEM_mem_w,
        output reg [2:0] EXE_MEM_size,
        output reg [1:0] EXE_MEM_DatatoReg,
        output reg EXE_MEM_RegWrite,
        output reg EXE_MEM_W_D,
        output reg [`DATA_BITS-1:0] EXE_MEM_DMEM_Custom_Address,
        output reg [`DATA_BITS-1:0] EXE_MEM_DMEM_Custom_Address_ntt,
        output reg [`DATA_BITS-1:0] EXE_MEM_Buffer_data_out,
        
        output reg [`ADDR_BITS-1:0] EXE_MEM_written_reg,
//        output reg [`ADDR_BITS-1:0] EXE_MEM_read_reg1,
//        output reg [`ADDR_BITS-1:0] EXE_MEM_read_reg2,
//        output reg [`ADDR_BITS-1:0] EXE_MEM_read_reg3,
        output reg EXE_MEM_ntt_we,
        input ntt_start,
        output reg EXE_MEM_ntt_start,
        input ntt_valid,
        output reg EXE_MEM_ntt_valid,
        input [`DATA_BITS-1:0] ntt_dout,
        output reg [`DATA_BITS-1:0] EXE_MEM_ntt_dout,
        input [`DATA_BITS-1:0] counter,
        output reg [`DATA_BITS-1:0] EXE_MEM_counter,
        input [`DATA_BITS-1:0] DMEM_Custom_Address_pwam,
        output reg [`DATA_BITS-1:0] EXE_MEM_DMEM_Custom_Address_pwam,
        input pwam_start,
        output reg EXE_MEM_pwam_start,
        input pwam_wea,
        output reg EXE_MEM_pwam_wea,
        input pwam_web,
        output reg EXE_MEM_pwam_web,
        input [`DATA_BITS-1:0] pwam_dout,
        output reg [`DATA_BITS-1:0] EXE_MEM_pwam_dout,
        input pwam_valid,
        output reg EXE_MEM_pwam_valid,
        input [1:0] dmem_addr_sel,
        output reg [1:0] EXE_MEM_dmem_addr_sel,
        input [1:0] dmem_data_sel,
        output reg [1:0] EXE_MEM_dmem_data_sel,
        input keccak_start,
        output reg EXE_MEM_keccak_start,
        input keccak_we,
        output reg EXE_MEM_keccak_we,
        input keccak_valid,
        output reg EXE_MEM_keccak_valid
    );
    always @ (posedge clk or negedge rst) begin
        if (~rst) begin
            EXE_MEM_inst_in     <= `NOP_INST;
            EXE_MEM_PC          <= `ZERO;
            EXE_MEM_ALU_out     <= `ZERO;
            EXE_MEM_Data_out    <= `ZERO;
            EXE_MEM_mem_w       <= 1'b0;
            EXE_MEM_size        <= 3'b011;
            EXE_MEM_DatatoReg   <= 2'b00;
            EXE_MEM_W_D         <= 1'b0;
            EXE_MEM_RegWrite    <= 1'b0;
            EXE_MEM_DMEM_Custom_Address <= `ZERO;
            EXE_MEM_DMEM_Custom_Address_ntt <= `ZERO;
            EXE_MEM_Buffer_data_out <= `ZERO;
            
            EXE_MEM_written_reg <= `ADDR_BITS'b00000;
//            EXE_MEM_read_reg1   <= `ADDR_BITS'b00000;
//            EXE_MEM_read_reg2   <= `ADDR_BITS'b00000;
//            EXE_MEM_read_reg3   <= `ADDR_BITS'b00000;
            
            EXE_MEM_ntt_we <= 0;
            EXE_MEM_ntt_start <= 0; 
            EXE_MEM_ntt_valid <= 0;
            EXE_MEM_ntt_dout <= `ZERO;
            EXE_MEM_counter <= `ZERO;
            EXE_MEM_DMEM_Custom_Address_pwam <= `ZERO; 
            EXE_MEM_pwam_wea <= 0;
            EXE_MEM_pwam_web <= 0;
            EXE_MEM_pwam_start <= 0; 
            EXE_MEM_pwam_dout <= `ZERO; 
            EXE_MEM_pwam_valid <= 0;
            EXE_MEM_dmem_addr_sel <= 0;
            EXE_MEM_dmem_data_sel <= 0;
            EXE_MEM_keccak_we <= 0;
            EXE_MEM_keccak_start <= 0; 
            EXE_MEM_keccak_valid <= 0; 
        end
        else if (!CE) begin
            EXE_MEM_inst_in     <= `NOP_INST;
            EXE_MEM_PC          <= `ZERO;
            EXE_MEM_ALU_out     <= `ZERO;
            EXE_MEM_Data_out    <= `ZERO;
            EXE_MEM_mem_w       <= 1'b0;
            EXE_MEM_size        <= 3'b011;
            EXE_MEM_DatatoReg   <= 2'b00;
            EXE_MEM_W_D         <= 1'b0;
            EXE_MEM_RegWrite    <= 1'b0;
            EXE_MEM_DMEM_Custom_Address <= `ZERO;
            EXE_MEM_DMEM_Custom_Address_ntt <= `ZERO;
            EXE_MEM_Buffer_data_out <= `ZERO;
            
            EXE_MEM_written_reg <= `ADDR_BITS'b00000;
//            EXE_MEM_read_reg1   <= `ADDR_BITS'b00000;
//            EXE_MEM_read_reg2   <= `ADDR_BITS'b00000;
//            EXE_MEM_read_reg3   <= `ADDR_BITS'b00000;
            
            EXE_MEM_ntt_we <= 0;
            EXE_MEM_ntt_start <= 0; 
            EXE_MEM_ntt_valid <= 0;
            EXE_MEM_ntt_dout <= `ZERO;
            EXE_MEM_counter <= `ZERO;
            EXE_MEM_DMEM_Custom_Address_pwam <= `ZERO; 
            EXE_MEM_pwam_wea <= 0;
            EXE_MEM_pwam_web <= 0;
            EXE_MEM_pwam_start <= 0; 
            EXE_MEM_pwam_dout <= `ZERO; 
            EXE_MEM_pwam_valid <= 0;
            EXE_MEM_dmem_addr_sel <= 0;
            EXE_MEM_dmem_data_sel <= 0;
            EXE_MEM_keccak_we <= 0;
            EXE_MEM_keccak_start <= 0; 
            EXE_MEM_keccak_valid <= 0; 
        end
        else if (CE) begin
            EXE_MEM_inst_in     <= inst_in;
            EXE_MEM_PC          <= PC;
            EXE_MEM_ALU_out     <= ALU_out;
            EXE_MEM_Data_out    <= Data_out;
            EXE_MEM_mem_w       <= mem_w;
            EXE_MEM_size        <= size;
            EXE_MEM_DatatoReg   <= DatatoReg;
            EXE_MEM_W_D         <= W_D;
            EXE_MEM_RegWrite    <= RegWrite;
            EXE_MEM_DMEM_Custom_Address <= DMEM_Custom_Address;
            EXE_MEM_DMEM_Custom_Address_ntt <= DMEM_Custom_Address_ntt;
            EXE_MEM_Buffer_data_out <= Buffer_data_out;
            
            EXE_MEM_written_reg <= written_reg;
//            EXE_MEM_read_reg1   <= read_reg1;
//            EXE_MEM_read_reg2   <= read_reg2;
//            EXE_MEM_read_reg3   <= read_reg3;
            EXE_MEM_ntt_we <= ntt_we;
            EXE_MEM_ntt_start <= ntt_start;
            EXE_MEM_ntt_valid <= ntt_valid;
            EXE_MEM_ntt_dout <= ntt_dout;
            EXE_MEM_counter <= counter;
            EXE_MEM_DMEM_Custom_Address_pwam <= DMEM_Custom_Address_pwam; 
            EXE_MEM_pwam_wea <= pwam_wea;
            EXE_MEM_pwam_web <= pwam_web;
            EXE_MEM_pwam_start <= pwam_start; 
            EXE_MEM_pwam_dout <= pwam_dout; 
            EXE_MEM_pwam_valid <= pwam_valid;
            EXE_MEM_dmem_addr_sel <= dmem_addr_sel;
            EXE_MEM_dmem_data_sel <= dmem_data_sel;
            EXE_MEM_keccak_we <= keccak_we;
            EXE_MEM_keccak_start <= keccak_start; 
            EXE_MEM_keccak_valid <= keccak_valid; 
        end
    end
endmodule
