`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2024 15:17:43
// Design Name: 
// Module Name: Buffer_Stall
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

module Buffer_Stall(
    input CLK,
    input RST,
    input [`DATA_BITS-1:0] Buffer_Load_Amount,
    input [`WORD_BITS-1:0] IF_ID_inst_out,
    input [`WORD_BITS-1:0] ID_EXE_inst_in,
    input [`WORD_BITS-1:0] MEM_WB_inst_in,
    input [`WORD_BITS-1:0] EXE_MEM_inst_in,
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [6:0] Funct7,                         
    output reg Buffer_Stall,                    //stall until lbuf/ sbuf done loading/ storing data
    output reg sha3_stall,                      //stall until sha3 finish loading data from sha3_alu to buffer
    output  reg lbuf_stall,                     //stall until lbuf finish loading data from dmem to buffer on the last data
    output wire [`DATA_BITS-1:0] buffer_offset  //offset for dmem and buffer address
    );
    
    reg [1:0] state, next_state;
    reg [`DATA_BITS-1:0] counter;
    reg counter_sclr;
    reg counter_ce;
    wire lbuf_en, sbuf_en;
    
    always @ (*) begin
        Buffer_Stall = 0;
        if ((Opcode == 7'b0001011 && Funct3 == 3'b011 && (Funct7 == 7'b0000000 || Funct7 == 7'b0000001)))
            if (counter < Buffer_Load_Amount - 2)
                Buffer_Stall = 1;
            else   
                Buffer_Stall = 0;  
    end
    
    assign lbuf_en = (Opcode == 7'b0001011 && Funct3 == 3'b011 && Funct7 == 7'b0000000);
    assign sbuf_en = (Opcode == 7'b0001011 && Funct3 == 3'b011 && Funct7 == 7'b0000001);
    assign buffer_offset = counter;
    
    always @(posedge CLK) begin
        if (!RST) counter <= 2'h0;
        else begin 
            if (counter_sclr) counter <= 2'h0;
            else if (counter_ce) counter <= counter + 1'h1;
            else counter <= counter;
        end
    end
    
    always @(posedge CLK) begin         //Counter
        if (!RST) state <= 3'h0;
        else      state <= next_state;
    end
    
    
    always @(*) case (state)
        2'h0: next_state = (lbuf_en) ? (state + 2) : (sbuf_en ? (state + 1'h1) : state);
        2'h1: next_state = (!sha3_stall) ? (state + 1'h1) : state;
        2'h2: next_state = (counter == 23) ? (state + 1'h1) : state;
        default: next_state = 2'h0;
    endcase
    
    always @(*) case (state)
        2'h0: begin                 //bat dau
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
        end
        2'h1: begin                 //bat dau
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
        end
        2'h2: begin                 //store din vao bram
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
        end
        default: begin
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
        end
    endcase
   

    always @ (*) begin
        lbuf_stall = 0;
        if (!(IF_ID_inst_out[6:0] == 7'b0001011 && IF_ID_inst_out[14:12] == 3'b011 
            && (IF_ID_inst_out[31:25] == 7'b0000000 || IF_ID_inst_out[31:25] == 7'b0000001)) && MEM_WB_inst_in == 32'h0000300b)
            lbuf_stall = 1;
        else   
            lbuf_stall = 0;  
    end
    
    
    always @ (*) begin
        sha3_stall = 0;
        if ((ID_EXE_inst_in[6:0] == 7'b0001011 && ID_EXE_inst_in[14:12] == 3'b011 && ID_EXE_inst_in[31:25] == 7'b0000010) 
            || (EXE_MEM_inst_in[6:0] == 7'b0001011 && EXE_MEM_inst_in[14:12] == 3'b011 && EXE_MEM_inst_in[31:25] == 7'b0000010))
            sha3_stall = 1;
        else   
            sha3_stall = 0;  
    end
    
      
endmodule
