`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2025 10:07:39 AM
// Design Name: 
// Module Name: pqc_addr
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


module pqc_addr(
        input [6:0] Opcode,
        input [2:0] Funct3,
        input [6:0] Funct7,
        input ntt_valid,
        input pwam_valid,
        output reg [1:0] dmem_addr_sel,
        output reg [1:0] dmem_data_sel
    );
    always @ (*) begin
        dmem_addr_sel = 0;
        dmem_data_sel = 0;
        if (Opcode == 7'b0001011 && Funct3 == 3'b011)
            case (Funct7)
                7'b0000000: begin
                    dmem_addr_sel = 1;
                    dmem_data_sel = 1;
                end
                7'b0000001: begin
                    dmem_addr_sel = 1;
                    dmem_data_sel = 1;
                end
                7'b0000010: begin
                    dmem_data_sel = 1;
                end
                7'b0000100, 7'b0000011: begin
                    dmem_addr_sel = 2;
                    dmem_data_sel = ntt_valid ? 2 : 0;
                end
                7'b0000111, 7'b0000101, 7'b0000110: begin
                    dmem_addr_sel = 3;
                    dmem_data_sel = pwam_valid ? 3 : 0;
                end
                default: begin
                    dmem_addr_sel = 0;
                    dmem_data_sel = 0;
                end
            endcase
    end 
endmodule
