`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 10:00:08
// Design Name: 
// Module Name: ControlStall
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

module ControlStall(
        input [1:0] Branch,
        output reg IF_ID_cstall 
    );
    always @ (*) begin
        IF_ID_cstall = 1'b0;
        if (Branch[1:0] != 2'b00) begin
            IF_ID_cstall = 1'b1;
        end
    end
endmodule
