`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 10:04:40
// Design Name: 
// Module Name: REG_IF_ID
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

module REG_IF_ID(
        input clk,
        input rst, 
        input CE,
        input IF_ID_dstall,
        input IF_ID_cstall,    
        input [`WORD_BITS-1:0] inst_in,
        input [`DATA_BITS-1:0] PC,
        input ntt_we,       
        output reg [`WORD_BITS-1:0] IF_ID_inst_in,
        output reg [`DATA_BITS-1:0] IF_ID_PC,
        output reg IF_ID_ntt_we,
        input [`DATA_BITS-1:0] counter,
        output reg [`DATA_BITS-1:0] IF_ID_counter,
        input pwam_wea,
        output reg IF_ID_pwam_wea,
        input pwam_web,
        output reg IF_ID_pwam_web,
        input keccak_we,
        output reg IF_ID_keccak_we
    );
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            IF_ID_inst_in <= 32'h00000000;
            IF_ID_PC <= `ZERO;
            IF_ID_ntt_we <= 0;
            IF_ID_counter <=`ZERO;
            IF_ID_pwam_wea <= 0;
            IF_ID_pwam_web <= 0;
        end
        else begin
            if (CE && !IF_ID_dstall) begin
                if (IF_ID_cstall) begin
                    IF_ID_inst_in <= `NOP_INST;
                    IF_ID_PC <= `ZERO;  
                    IF_ID_ntt_we <= 0;     
                    IF_ID_counter <=`ZERO;
                    IF_ID_pwam_wea <= 0;
                    IF_ID_pwam_web <= 0;
                    IF_ID_keccak_we <= 0;
                end
                else begin
                    IF_ID_inst_in <= inst_in;
                    IF_ID_PC <= PC;    
                    IF_ID_ntt_we <= ntt_we;  
                    IF_ID_counter <=counter;   
                    IF_ID_pwam_wea <= pwam_wea;
                    IF_ID_pwam_web <= pwam_web;
                    IF_ID_keccak_we <= keccak_we;
                end         
            end
                            
        end
        // else: if stall, then nothing changes here
    end
endmodule