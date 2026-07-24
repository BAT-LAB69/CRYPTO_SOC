`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2024 10:44:35
// Design Name: 
// Module Name: Buffer
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

module Buffer(
        input CLK,
		input RST,
		input WE,  
		input Buffer_WE,
		input [4:0] W_addr,
		input [`DATA_BITS - 1:0] W_data,
		input [4:0] R_addr,
		output [`DATA_BITS-1:0] R_data,

		input [`DATA_BITS-1:0] W_data_0,
		input [`DATA_BITS-1:0] W_data_1,
		input [`DATA_BITS-1:0] W_data_2,
		input [`DATA_BITS-1:0] W_data_3,
		input [`DATA_BITS-1:0] W_data_4,
		input [`DATA_BITS-1:0] W_data_5,
		input [`DATA_BITS-1:0] W_data_6,
		input [`DATA_BITS-1:0] W_data_7,
		input [`DATA_BITS-1:0] W_data_8,
		input [`DATA_BITS-1:0] W_data_9,
		input [`DATA_BITS-1:0] W_data_10,
		input [`DATA_BITS-1:0] W_data_11,
		input [`DATA_BITS-1:0] W_data_12,
		input [`DATA_BITS-1:0] W_data_13,
		input [`DATA_BITS-1:0] W_data_14,
		input [`DATA_BITS-1:0] W_data_15,
		input [`DATA_BITS-1:0] W_data_16,
		input [`DATA_BITS-1:0] W_data_17,
		input [`DATA_BITS-1:0] W_data_18,
		input [`DATA_BITS-1:0] W_data_19,
		input [`DATA_BITS-1:0] W_data_20,
        input [`DATA_BITS-1:0] W_data_21,
        input [`DATA_BITS-1:0] W_data_22,
        input [`DATA_BITS-1:0] W_data_23,
        input [`DATA_BITS-1:0] W_data_24,

		output [`DATA_BITS-1:0] R_data_0,
		output [`DATA_BITS-1:0] R_data_1,
		output [`DATA_BITS-1:0] R_data_2,
		output [`DATA_BITS-1:0] R_data_3,
		output [`DATA_BITS-1:0] R_data_4,
		output [`DATA_BITS-1:0] R_data_5,
		output [`DATA_BITS-1:0] R_data_6,
		output [`DATA_BITS-1:0] R_data_7,
		output [`DATA_BITS-1:0] R_data_8,
		output [`DATA_BITS-1:0] R_data_9,
		output [`DATA_BITS-1:0] R_data_10,
		output [`DATA_BITS-1:0] R_data_11,
		output [`DATA_BITS-1:0] R_data_12,
		output [`DATA_BITS-1:0] R_data_13,
		output [`DATA_BITS-1:0] R_data_14,
		output [`DATA_BITS-1:0] R_data_15,
		output [`DATA_BITS-1:0] R_data_16,
		output [`DATA_BITS-1:0] R_data_17,
		output [`DATA_BITS-1:0] R_data_18,
		output [`DATA_BITS-1:0] R_data_19,
		output [`DATA_BITS-1:0] R_data_20,
		output [`DATA_BITS-1:0] R_data_21,
		output [`DATA_BITS-1:0] R_data_22,
		output [`DATA_BITS-1:0] R_data_23,
		output [`DATA_BITS-1:0] R_data_24
    );
    reg [`DATA_BITS-1:0] register [0:31];  
    integer i;
    
    always @ (posedge CLK or negedge RST) begin
        if (!RST)
            for (i = 0; i < 32; i = i + 1)
                register[i] <= 0;
        else begin
            if (WE)
                register[W_addr] <= W_data;
            if (Buffer_WE) begin
                register[0]  <= W_data_0;
                register[1]  <= W_data_1;
                register[2]  <= W_data_2;
                register[3]  <= W_data_3;
                register[4]  <= W_data_4;
                register[5]  <= W_data_5;
                register[6]  <= W_data_6;
                register[7]  <= W_data_7;
                register[8]  <= W_data_8;
                register[9]  <= W_data_9;
                register[10]  <= W_data_10;
                register[11]  <= W_data_11;
                register[12]  <= W_data_12;
                register[13]  <= W_data_13;
                register[14]  <= W_data_14;
                register[15]  <= W_data_15;
                register[16]  <= W_data_16;
                register[17]  <= W_data_17;
                register[18]  <= W_data_18;
                register[19]  <= W_data_19;
                register[20]  <= W_data_20;
                register[21]  <= W_data_21;
                register[22]  <= W_data_22;
                register[23]  <= W_data_23;
                register[24]  <= W_data_24;
            end   
        end
    end
    
    assign R_data = register[R_addr];
    
    assign R_data_0 = register[0];
    assign R_data_1 = register[1];
    assign R_data_2 = register[2];
    assign R_data_3 = register[3];
    assign R_data_4 = register[4];
    assign R_data_5 = register[5];
    assign R_data_6 = register[6];
    assign R_data_7 = register[7];
    assign R_data_8 = register[8];
    assign R_data_9 = register[9];
    assign R_data_10 = register[10];
    assign R_data_11 = register[11];
    assign R_data_12 = register[12];
    assign R_data_13 = register[13];
    assign R_data_14 = register[14];
    assign R_data_15 = register[15];
    assign R_data_16 = register[16];
    assign R_data_17 = register[17];
    assign R_data_18 = register[18];
    assign R_data_19 = register[19];
    assign R_data_20 = register[20];
    assign R_data_21 = register[21];
    assign R_data_22 = register[22];
    assign R_data_23 = register[23];
    assign R_data_24 = register[24];
endmodule
