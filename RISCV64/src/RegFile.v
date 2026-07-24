`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:11:47
// Design Name: 
// Module Name: RegFile
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

module RegFile(
    input CLK,
    input RST,
    input RegWrite,
    input [`ADDR_BITS-1:0] R_addr_A,
    input [`ADDR_BITS-1:0] R_addr_B,
    input [`ADDR_BITS-1:0] W_addr,
    input [`DATA_BITS-1:0] W_data,
    output [`DATA_BITS-1:0] R_data_A,
    output [`DATA_BITS-1:0] R_data_B,
    output [`DATA_BITS-1:0] Buffer_Base_Address,
    output [`DATA_BITS-1:0] Buffer_Load_Amount,
    output [`DATA_BITS-1:0] DMEM_Base_Address
    );
    
    integer i;
    reg [`DATA_BITS-1:0] register [0:31];
    
    always @ (posedge CLK or negedge RST)
        if (!RST)
            for (i = 0; i < `WORD_BITS; i = i + 1)
                register[i] <= 0;
        else 
            if (RegWrite && (W_addr != 0))
                register[W_addr] <= W_data;
                    
    assign R_data_A = register[R_addr_A];
	assign R_data_B = register[R_addr_B];
    assign Buffer_Base_Address = register[29];
    assign Buffer_Load_Amount = register[30];
    assign DMEM_Base_Address = register[31];
endmodule

