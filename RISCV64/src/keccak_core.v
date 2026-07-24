`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2025 08:40:50 AM
// Design Name: 
// Module Name: keccak_core
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

module keccak_core(
    input  wire        CLK,
    input  wire        RST,
    input  wire        start,
    input  wire 	   we,
    input  wire [63:0] din,
    output reg        valid,
    output reg [63:0] dout,
    output reg        ready,
    output reg        done
    );
    
    reg [`DATA_BITS-1:0] Buffer_data_in_0;
    reg [`DATA_BITS-1:0] Buffer_data_in_1;
    reg [`DATA_BITS-1:0] Buffer_data_in_2;
    reg [`DATA_BITS-1:0] Buffer_data_in_3;
    reg [`DATA_BITS-1:0] Buffer_data_in_4;
    reg [`DATA_BITS-1:0] Buffer_data_in_5;
    reg [`DATA_BITS-1:0] Buffer_data_in_6;
    reg [`DATA_BITS-1:0] Buffer_data_in_7;
    reg [`DATA_BITS-1:0] Buffer_data_in_8;
    reg [`DATA_BITS-1:0] Buffer_data_in_9;
    reg [`DATA_BITS-1:0] Buffer_data_in_10;
    reg [`DATA_BITS-1:0] Buffer_data_in_11;
    reg [`DATA_BITS-1:0] Buffer_data_in_12;
    reg [`DATA_BITS-1:0] Buffer_data_in_13;
    reg [`DATA_BITS-1:0] Buffer_data_in_14;
    reg [`DATA_BITS-1:0] Buffer_data_in_15;
    reg [`DATA_BITS-1:0] Buffer_data_in_16;
    reg [`DATA_BITS-1:0] Buffer_data_in_17;
    reg [`DATA_BITS-1:0] Buffer_data_in_18;
    reg [`DATA_BITS-1:0] Buffer_data_in_19;
    reg [`DATA_BITS-1:0] Buffer_data_in_20;
    reg [`DATA_BITS-1:0] Buffer_data_in_21;
    reg [`DATA_BITS-1:0] Buffer_data_in_22;
    reg [`DATA_BITS-1:0] Buffer_data_in_23;
    reg [`DATA_BITS-1:0] Buffer_data_in_24;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_0;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_1;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_2;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_3;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_4;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_5;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_6;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_7;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_8;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_9;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_10;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_11;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_12;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_13;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_14;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_15;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_16;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_17;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_18;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_19;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_20;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_21;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_22;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_23;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_out_24;
    wire [`DATA_BITS-1:0] Buffer_data_in_0_constant;
        wire [`DATA_BITS-1:0] ALU_Buffer_data_in_0;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_1;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_2;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_3;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_4;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_5;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_6;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_7;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_8;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_9;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_10;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_11;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_12;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_13;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_14;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_15;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_16;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_17;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_18;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_19;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_20;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_21;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_22;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_23;
    wire [`DATA_BITS-1:0] ALU_Buffer_data_in_24;
    
    wire [`DATA_BITS-1:0] dout_output;
    reg [4:0] round;
    wire [63:0] constant;
    reg Buffer_WE;
    
    
    
    reg  [ 3:0] state, next_state;
    reg         counter_ce, counter_sclr;
    reg  [ 5:0] counter_q;
    
    round_constant RC (
        .round(round),
        .constant(constant)
    ); 
    
    Buffer _buffer (
        .CLK(CLK),
        .RST(RST),
        .WE(we), //enable receiving data from dmem in lbuf instruction
        .Buffer_WE(Buffer_WE), //enable receiving multiple datas from alu buffer at once
        .W_addr(counter_q[4:0]),
        .W_data(din),
        .R_addr(counter_q[4:0]),
        .R_data(dout_output),
        .W_data_0(Buffer_data_in_0_constant),
        .W_data_1(Buffer_data_in_1),
        .W_data_2(Buffer_data_in_2),
        .W_data_3(Buffer_data_in_3),
        .W_data_4(Buffer_data_in_4),
        .W_data_5(Buffer_data_in_5),
        .W_data_6(Buffer_data_in_6),
        .W_data_7(Buffer_data_in_7),
        .W_data_8(Buffer_data_in_8),
        .W_data_9(Buffer_data_in_9),
        .W_data_10(Buffer_data_in_10),
        .W_data_11(Buffer_data_in_11),
        .W_data_12(Buffer_data_in_12),
        .W_data_13(Buffer_data_in_13),
        .W_data_14(Buffer_data_in_14),
        .W_data_15(Buffer_data_in_15),
        .W_data_16(Buffer_data_in_16),
        .W_data_17(Buffer_data_in_17),
        .W_data_18(Buffer_data_in_18),
        .W_data_19(Buffer_data_in_19),
        .W_data_20(Buffer_data_in_20),
        .W_data_21(Buffer_data_in_21),
        .W_data_22(Buffer_data_in_22),
        .W_data_23(Buffer_data_in_23),
        .W_data_24(Buffer_data_in_24),
        .R_data_0(ALU_Buffer_data_in_0),
        .R_data_1(ALU_Buffer_data_in_1),
        .R_data_2(ALU_Buffer_data_in_2),
        .R_data_3(ALU_Buffer_data_in_3),
        .R_data_4(ALU_Buffer_data_in_4),
        .R_data_5(ALU_Buffer_data_in_5),
        .R_data_6(ALU_Buffer_data_in_6),
        .R_data_7(ALU_Buffer_data_in_7),
        .R_data_8(ALU_Buffer_data_in_8),
        .R_data_9(ALU_Buffer_data_in_9),
        .R_data_10(ALU_Buffer_data_in_10),
        .R_data_11(ALU_Buffer_data_in_11),
        .R_data_12(ALU_Buffer_data_in_12),
        .R_data_13(ALU_Buffer_data_in_13),
        .R_data_14(ALU_Buffer_data_in_14),
        .R_data_15(ALU_Buffer_data_in_15),
        .R_data_16(ALU_Buffer_data_in_16),
        .R_data_17(ALU_Buffer_data_in_17),
        .R_data_18(ALU_Buffer_data_in_18),
        .R_data_19(ALU_Buffer_data_in_19),
        .R_data_20(ALU_Buffer_data_in_20),
        .R_data_21(ALU_Buffer_data_in_21),
        .R_data_22(ALU_Buffer_data_in_22),
        .R_data_23(ALU_Buffer_data_in_23),
        .R_data_24(ALU_Buffer_data_in_24)
    );  
              
    ALU_buffer _alu_buffer (
        .Data_in_0(ALU_Buffer_data_in_0),
        .Data_in_1(ALU_Buffer_data_in_1),
        .Data_in_2(ALU_Buffer_data_in_2),
        .Data_in_3(ALU_Buffer_data_in_3),
        .Data_in_4(ALU_Buffer_data_in_4),
        .Data_in_5(ALU_Buffer_data_in_5),
        .Data_in_6(ALU_Buffer_data_in_6),
        .Data_in_7(ALU_Buffer_data_in_7),
        .Data_in_8(ALU_Buffer_data_in_8),
        .Data_in_9(ALU_Buffer_data_in_9),
        .Data_in_10(ALU_Buffer_data_in_10),
        .Data_in_11(ALU_Buffer_data_in_11),
        .Data_in_12(ALU_Buffer_data_in_12),
        .Data_in_13(ALU_Buffer_data_in_13),
        .Data_in_14(ALU_Buffer_data_in_14),
        .Data_in_15(ALU_Buffer_data_in_15),
        .Data_in_16(ALU_Buffer_data_in_16),
        .Data_in_17(ALU_Buffer_data_in_17),
        .Data_in_18(ALU_Buffer_data_in_18),
        .Data_in_19(ALU_Buffer_data_in_19),
        .Data_in_20(ALU_Buffer_data_in_20),
        .Data_in_21(ALU_Buffer_data_in_21),
        .Data_in_22(ALU_Buffer_data_in_22),
        .Data_in_23(ALU_Buffer_data_in_23),
        .Data_in_24(ALU_Buffer_data_in_24),
        .Data_out_0 (ALU_Buffer_data_out_0),
        .Data_out_1 (ALU_Buffer_data_out_1),
        .Data_out_2 (ALU_Buffer_data_out_2),
        .Data_out_3 (ALU_Buffer_data_out_3),
        .Data_out_4 (ALU_Buffer_data_out_4),
        .Data_out_5 (ALU_Buffer_data_out_5),
        .Data_out_6 (ALU_Buffer_data_out_6),
        .Data_out_7 (ALU_Buffer_data_out_7),
        .Data_out_8 (ALU_Buffer_data_out_8),
        .Data_out_9 (ALU_Buffer_data_out_9),
        .Data_out_10(ALU_Buffer_data_out_10),
        .Data_out_11(ALU_Buffer_data_out_11),
        .Data_out_12(ALU_Buffer_data_out_12),
        .Data_out_13(ALU_Buffer_data_out_13),
        .Data_out_14(ALU_Buffer_data_out_14),
        .Data_out_15(ALU_Buffer_data_out_15),
        .Data_out_16(ALU_Buffer_data_out_16),
        .Data_out_17(ALU_Buffer_data_out_17),
        .Data_out_18(ALU_Buffer_data_out_18),
        .Data_out_19(ALU_Buffer_data_out_19),
        .Data_out_20(ALU_Buffer_data_out_20),
        .Data_out_21(ALU_Buffer_data_out_21),
        .Data_out_22(ALU_Buffer_data_out_22),
        .Data_out_23(ALU_Buffer_data_out_23),
        .Data_out_24(ALU_Buffer_data_out_24)
        );      
        
    always @(posedge CLK) begin
        if (!RST) begin
            Buffer_data_in_0 <= 0;
            Buffer_data_in_1  <= 0;
            Buffer_data_in_2  <= 0;
            Buffer_data_in_3  <= 0;
            Buffer_data_in_4  <= 0;
            Buffer_data_in_5  <= 0;
            Buffer_data_in_6  <= 0;
            Buffer_data_in_7  <= 0;
            Buffer_data_in_8  <= 0;
            Buffer_data_in_9  <= 0;
            Buffer_data_in_10 <= 0;
            Buffer_data_in_11 <= 0;
            Buffer_data_in_12 <= 0;
            Buffer_data_in_13 <= 0;
            Buffer_data_in_14 <= 0;
            Buffer_data_in_15 <= 0;
            Buffer_data_in_16 <= 0;
            Buffer_data_in_17 <= 0;
            Buffer_data_in_18 <= 0;
            Buffer_data_in_19 <= 0;
            Buffer_data_in_20 <= 0;
            Buffer_data_in_21 <= 0;
            Buffer_data_in_22 <= 0;
            Buffer_data_in_23 <= 0;
            Buffer_data_in_24 <= 0;
        end  
        else begin
            Buffer_data_in_0 <= ALU_Buffer_data_out_0;
            Buffer_data_in_1  <= ALU_Buffer_data_out_1;
            Buffer_data_in_2  <= ALU_Buffer_data_out_2;
            Buffer_data_in_3  <= ALU_Buffer_data_out_3;
            Buffer_data_in_4  <= ALU_Buffer_data_out_4;
            Buffer_data_in_5  <= ALU_Buffer_data_out_5;
            Buffer_data_in_6  <= ALU_Buffer_data_out_6;
            Buffer_data_in_7  <= ALU_Buffer_data_out_7;
            Buffer_data_in_8  <= ALU_Buffer_data_out_8;
            Buffer_data_in_9  <= ALU_Buffer_data_out_9;
            Buffer_data_in_10 <= ALU_Buffer_data_out_10;
            Buffer_data_in_11 <= ALU_Buffer_data_out_11;
            Buffer_data_in_12 <= ALU_Buffer_data_out_12;
            Buffer_data_in_13 <= ALU_Buffer_data_out_13;
            Buffer_data_in_14 <= ALU_Buffer_data_out_14;
            Buffer_data_in_15 <= ALU_Buffer_data_out_15;
            Buffer_data_in_16 <= ALU_Buffer_data_out_16;
            Buffer_data_in_17 <= ALU_Buffer_data_out_17;
            Buffer_data_in_18 <= ALU_Buffer_data_out_18;
            Buffer_data_in_19 <= ALU_Buffer_data_out_19;
            Buffer_data_in_20 <= ALU_Buffer_data_out_20;
            Buffer_data_in_21 <= ALU_Buffer_data_out_21;
            Buffer_data_in_22 <= ALU_Buffer_data_out_22;
            Buffer_data_in_23 <= ALU_Buffer_data_out_23;
            Buffer_data_in_24 <= ALU_Buffer_data_out_24;
        end    
    end
    
    assign Buffer_data_in_0_constant = Buffer_data_in_0 ^ constant;
    
    always @(*) case (state)
        4'h0: next_state = start ? (state + 1'h1) : state;
        4'h1: next_state = state + 1'h1;
        4'h2: next_state = (round == 5'h17) ? (state + 1'h1) : 4'h1;
        4'h3: next_state = state + 1'h1;
        4'h4: next_state = (counter_q == 5'h19) ? (state + 1'h1) : state;
        default: next_state = 3'h0;
    endcase
    
    always @(posedge CLK) begin
        if (!RST) dout <= 3'h0;
        else dout <= dout_output;
    end
    
    always @(posedge CLK) begin
        if (!RST) state <= 3'h0;
        else state <= next_state;
    end
    
    reg round_sclr, round_ce;
    
    always @(posedge CLK) begin
        if (!RST) round <= 5'h0;
        else begin 
            if (round_sclr) round <= 6'h0;
            else if (round_ce) round <= round + 1'h1;
            else round <= round;
        end
    end
    
//    reg we_delay;
    
//    always @(posedge CLK) begin         //Counter
//        if (!RST) we_delay <= 0;
//        else      we_delay <= we;
//    end
    
    always @(posedge CLK) begin
        if (!RST) counter_q <= 8'h0;
        else begin 
            if (counter_sclr) counter_q <= 6'h0;
            else if (counter_ce | we) counter_q <= counter_q + 1'h1;
            else counter_q <= counter_q;
        end
    end
    
    always @(*) case (state)
        4'h1: begin
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            Buffer_WE    = 1'h0;
            done         = 1'h0;
            valid        = 1'h0;
            round_ce     = 1'h0;
            round_sclr   = 1'h0;
        end
        4'h2: begin
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
            Buffer_WE    = 1'h1;
            done         = 1'h0;
            valid        = 1'h0;
            round_ce     = 1'h1;
            round_sclr   = 1'h0;
        end
        4'h3: begin
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            Buffer_WE    = 1'h0;
            done         = 1'h0;
            valid        = 1'h0;
            round_ce     = 1'h0;
            round_sclr   = 1'h0;
        end
        4'h4: begin
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            Buffer_WE    = 1'h0;
            done         = 1'h0;
            valid        = 1'h1;
            round_ce     = 1'h0;
            round_sclr   = 1'h0;
        end
        4'h5: begin
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
            Buffer_WE    = 1'h0;
            done         = 1'h1;
            valid        = 1'h0;
            round_ce     = 1'h0;
            round_sclr   = 1'h0;
        end
        default: begin
            counter_ce   = 1'h0;
            counter_sclr = 1'h0;
            Buffer_WE    = 1'h0;
            done         = 1'h0;
            valid        = 1'h0;
            round_ce     = 1'h0;
            round_sclr   = 1'h1;
        end
    endcase
    
endmodule
