`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 09:59:32
// Design Name: 
// Module Name: StateControl
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

module StateControl(
        input CLK,
        input RST,
        input Start_in,
        input Done_flag,
        output reg State_start,
        output reg State_done
    );
    always @(posedge CLK or negedge RST) begin
        if (RST == 0) begin
            State_start <= 0;
            State_done <= 0;
        end  
        else         
        if (Start_in) begin
            State_start <= 1;
            if (Done_flag) begin
                State_done <=1;
                State_start <= 0;
            end 
        end 
        else
            State_start <= 0;
    end

endmodule
