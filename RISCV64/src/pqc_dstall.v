`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2025 09:34:31 AM
// Design Name: 
// Module Name: pqc_dstall
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

module pqc_dstall(
        input [`WORD_BITS-1:0] IF_ID_inst,
        input [`WORD_BITS-1:0] ID_EXE_inst,
        input [`WORD_BITS-1:0] EXE_MEM_inst,
        input [`WORD_BITS-1:0] MEM_WB_inst,
        output reg [1:0] reg29_sel,
        output reg [1:0] reg30_sel,
        output reg [1:0] reg31_sel
    );
    
    always @ (*) begin
        reg29_sel = 0;
        reg30_sel = 0;
        reg31_sel = 0;
        if (IF_ID_inst[6:0] == 7'b0001011 && IF_ID_inst[14:12] == 7'b011) begin
            case (IF_ID_inst[31:25])
//                7'b0000000, 7'b0000001: begin
//                    if (ID_EXE_inst[6:0] == 7'b0010011 && ID_EXE_inst[14:12] == 7'b000) begin
//                        case (ID_EXE_inst[11:7])
//                            5'b11101: reg29_sel = 1;
//                            5'b11110: reg30_sel = 1;
//                            5'b11111: reg31_sel = 1;
//                            default: ;   
//                        endcase
//                    end
//                    if (EXE_MEM_inst[6:0] == 7'b0010011 && EXE_MEM_inst[14:12] == 7'b000) begin
//                        case (EXE_MEM_inst[11:7])
//                            5'b11101: reg29_sel = 2;
//                            5'b11110: reg30_sel = 2;
//                            5'b11111: reg31_sel = 2; 
//                            default: ;       
//                        endcase
//                    end
//                    if (MEM_WB_inst[6:0] == 7'b0010011 && MEM_WB_inst[14:12] == 7'b000) begin
//                        case (MEM_WB_inst[11:7])
//                            5'b11101: reg29_sel = 3;
//                            5'b11110: reg30_sel = 3;
//                            5'b11111: reg31_sel = 3;
//                            default: ;   
//                        endcase
//                    end
//                end
                7'b0000000, 7'b0000011, 7'b0000100: begin
                    if (ID_EXE_inst[6:0] == 7'b0010011 && (ID_EXE_inst[14:12] == 7'b000 || ID_EXE_inst[14:12] == 7'b001) && ID_EXE_inst[11:7] == 5'b11111)
                        reg31_sel = 1;
                    else if (EXE_MEM_inst[6:0] == 7'b0010011 && (EXE_MEM_inst[14:12] == 7'b000 || EXE_MEM_inst[14:12] == 7'b001) && EXE_MEM_inst[11:7] == 5'b11111)
                        reg31_sel = 2;
                    else if (MEM_WB_inst[6:0] == 7'b0010011 && (MEM_WB_inst[14:12] == 7'b000 || MEM_WB_inst[14:12] == 7'b001) && MEM_WB_inst[11:7] == 5'b11111)
                        reg31_sel = 3;
                end        
                7'b0000111, 7'b0000110, 7'b0000101: begin
                    if (ID_EXE_inst[6:0] == 7'b0010011 && (ID_EXE_inst[14:12] == 7'b000 || ID_EXE_inst[14:12] == 7'b001)) begin
                        case (ID_EXE_inst[11:7])
                            5'b11101: reg29_sel = 1;
                            5'b11110: reg30_sel = 1;
                            5'b11111: reg31_sel = 1;
                            default: ;   
                        endcase
                    end
                    if (EXE_MEM_inst[6:0] == 7'b0010011 && (EXE_MEM_inst[14:12] == 7'b000 || EXE_MEM_inst[14:12] == 7'b001)) begin
                        case (EXE_MEM_inst[11:7])
                            5'b11101: reg29_sel = 2;
                            5'b11110: reg30_sel = 2;
                            5'b11111: reg31_sel = 2;  
                            default: ;   
                        endcase
                    end
                    if (MEM_WB_inst[6:0] == 7'b0010011 && (MEM_WB_inst[14:12] == 7'b000 || MEM_WB_inst[14:12] == 7'b001)) begin
                        case (MEM_WB_inst[11:7])
                            5'b11101: reg29_sel = 3;
                            5'b11110: reg30_sel = 3;
                            5'b11111: reg31_sel = 3;
                            default: ;   
                        endcase
                    end
                end
                default: ;   
            endcase
    end
end
endmodule
