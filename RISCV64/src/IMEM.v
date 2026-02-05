`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:27:32
// Design Name: 
// Module Name: IMEM
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

module IMEM(
        input [`WORD_BITS-1:0] Inst_in,
        input [`DATA_BITS-1:0] Addr_64,
        input CLK,
        input IMEM_WE,
        output [`WORD_BITS-1:0] Inst_out
    );
    
    reg [`BRAM_WIDTH-1:0] imem [0:`BRAM_INST_DEPTH-1];
    
    integer i;
    initial begin
        for (i = 0; i < `BRAM_INST_DEPTH; i = i + 1) begin
            imem[i] = {`BRAM_WIDTH{1'b0}};
        end
    end
    
    always @ (posedge CLK)
        if (IMEM_WE)
            imem[Addr_64[13:2]] <= Inst_in;
    assign Inst_out = imem[Addr_64[13:2]];
endmodule
