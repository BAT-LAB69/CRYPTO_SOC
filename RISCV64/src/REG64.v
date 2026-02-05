`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 10:01:01
// Design Name: 
// Module Name: REG64
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

module REG64(
    input CLK,
    input RST,
    input CE,
    input PC_dstall,
    input [`DATA_BITS-1:0] Data_in,
    input ntt_stall,
    output reg [`DATA_BITS-1:0] Data_out,
    input pwam_stall,
    input mulstall,
    input keccak_stall
    );
    
    always @ (posedge CLK or negedge RST)
        if (RST == 0 || CE == 0)
            Data_out <= `ZERO;
        else if (PC_dstall == 0 && ntt_stall == 0 && pwam_stall == 0 && mulstall == 0 && keccak_stall == 0) begin
            if (RST == 0)
                Data_out <= `ZERO;
            else if (CE)
                Data_out <= Data_in;
        end
endmodule
