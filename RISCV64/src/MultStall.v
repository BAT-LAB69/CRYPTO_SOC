`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2025 10:24:56 PM
// Design Name: 
// Module Name: MulStall
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


module MulStall(
        input CLK,
        input RST,
        input [`WORD_BITS-1:0] Inst_ROM_in,
        input [`DATA_BITS-1:0] Addr_64,
        input [`WORD_BITS-1:0] IF_ID_addr,
        input [`WORD_BITS-1:0] IF_ID_inst,
        input PC_stall,
        output mulstall 
    );
    wire is_mul;
    reg stall_ff;
    wire branch_detect;
    assign branch_detect = (IF_ID_inst[6:0] == 7'b1100011) && (IF_ID_inst[14:12] == 3'b000 || IF_ID_inst[14:12] == 3'b001 ||
        IF_ID_inst[14:12] == 3'b100 || IF_ID_inst[14:12] == 3'b101 || IF_ID_inst[14:12] == 3'b110 || IF_ID_inst[14:12] == 3'b111); 
    assign is_mul = (Inst_ROM_in[31:25] == 7'b0000001) && (((Inst_ROM_in[6:0] == 7'b0111011) && (Inst_ROM_in[14:12] == 3'b000)) || 
        (((Inst_ROM_in[14:12] == 3'b000 || Inst_ROM_in[14:12] == 3'b001 || Inst_ROM_in[14:12] == 3'b010 || Inst_ROM_in[14:12] == 3'b011)) && 
        (Inst_ROM_in[6:0] == 7'b0110011)));
    assign mulstall = !branch_detect && is_mul && !stall_ff && !PC_stall && (IF_ID_addr != Addr_64);    
    


    always @ (posedge CLK or negedge RST) begin
        if (!RST)
            stall_ff <= 0;
        else if (mulstall)
            stall_ff <= 1;
        else
            stall_ff <= 0;    
    end
endmodule
