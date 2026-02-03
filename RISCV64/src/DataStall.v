`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 09:59:51
// Design Name: 
// Module Name: DataStall
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

module DataStall(
        input [`WORD_BITS-1:0] ID_EXE_inst,
        input [`WORD_BITS-1:0] EXE_MEM_inst,
        input [`WORD_BITS-1:0] MEM_WB_inst,
        input [`ADDR_BITS-1:0] IF_ID_written_reg,
        input [`ADDR_BITS-1:0] IF_ID_read_reg1,
        input [`ADDR_BITS-1:0] IF_ID_read_reg2,
        input [`ADDR_BITS-1:0] IF_ID_read_reg3,
        input [`ADDR_BITS-1:0] ID_EXE_written_reg,
        input [`ADDR_BITS-1:0] EXE_MEM_written_reg,
        input [`ADDR_BITS-1:0] MEM_WB_written_reg,
        output reg PC_dstall,
        output reg IF_ID_dstall,
        output reg ID_EXE_dstall,
        output reg [1:0] ASel_stall_1,
        output reg ASel_stall_2,
        output reg [1:0] BSel_stall_1, 
        output reg [1:0] ASel_stall_3  
    );
    always @ (*) begin
        PC_dstall = 0;
        IF_ID_dstall = 0;
        ID_EXE_dstall = 0;
        ASel_stall_1 = 0;
        ASel_stall_2 = 0;
        BSel_stall_1 = 0;
        ASel_stall_3 = 3;
        ////////////////////////////////////////////////////////////////////////////////////////
        //Asel_stall_2 bang 1 khi co data stall
        //alu_a
        //khong phai la lenh branch hoac store vi khong write vao regfile
        //lenh hien tai can data tu EXE stage
        if (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg1 && ID_EXE_inst[6:0] != 7'b1100011 && ID_EXE_inst[6:0] != 7'b0100011) begin
            ASel_stall_1 = 0;
            ASel_stall_2 = 1;
            ASel_stall_3 = 0;
            if (ID_EXE_inst[6:0] == 7'b0000011) begin //lenh load trong truong hop can gia tri load tu dmem ngay sau lenh load => stall pc
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
            end
        end   
        //lenh hien tai can data tu MEM stage
        else if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg1 && EXE_MEM_inst[6:0] != 7'b1100011 && EXE_MEM_inst[6:0] != 7'b0100011) begin
            ASel_stall_1 = 1;
            ASel_stall_2 = 1;
            ASel_stall_3 = 1;
            if (EXE_MEM_inst[6:0] == 7'b0000011) begin //lenh load trong truong hop can gia tri load tu dmem ngay sau lenh load => stall pc
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
            end
        end    
        //lenh hien tai can data tu WB stage
        else if (MEM_WB_written_reg != 0 && MEM_WB_written_reg == IF_ID_read_reg1 && MEM_WB_inst[6:0] != 7'b1100011 && MEM_WB_inst[6:0] != 7'b0100011) begin
            ASel_stall_1 = 2;
            ASel_stall_2 = 1;
            ASel_stall_3 = 2;     
        end
        
        //Bsel_stall_1 bang 0 khi khong co data stall
        //alu_b
        //khong phai la lenh branch hoac store vi khong write vao regfile
        //lenh hien tai can data tu EXE stage
        if (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg2 && ID_EXE_inst[6:0] != 7'b1100011 && ID_EXE_inst[6:0] != 7'b0100011) begin
            BSel_stall_1 = 2;
            if (ID_EXE_inst[6:0] == 7'b0000011) begin //lenh load trong truong hop can gia tri load tu dmem ngay sau lenh load => stall pc
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
            end
        end
        else if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2 && EXE_MEM_inst[6:0] != 7'b1100011 && EXE_MEM_inst[6:0] != 7'b0100011) begin 
            BSel_stall_1 = 3;
            if (EXE_MEM_inst[6:0] == 7'b0000011) begin //lenh load trong truong hop can gia tri load tu dmem ngay sau lenh load => stall pc
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
            end
        end
        else if (MEM_WB_written_reg != 0 && MEM_WB_written_reg == IF_ID_read_reg2 && MEM_WB_inst[6:0] != 7'b1100011 && MEM_WB_inst[6:0] != 7'b0100011) begin
            BSel_stall_1 = 1;
        end    
    end
endmodule