`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 07:11:53 PM
// Design Name: 
// Module Name: dmem_out
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

module dmem_out(
    input [2:0] size,
    input dmem_write,
    input [`DATA_BITS-1:0] data_in,
    input [`DATA_BITS-1:0] addr,
    input [`DATA_BITS-1:0] counter,
    output reg [`DATA_BITS-1:0] data_out
    );
    
    always @ (*) begin
        if (dmem_write) begin
            data_out = data_in;
        end
        else begin
            case (size)
                3'b000: //byte
                    case (addr[2:0])
                        3'b000: data_out = {{56{data_in[7]}}, data_in[7:0]}; 
                        3'b001: data_out = {{56{data_in[15]}}, data_in[15:8]}; 
                        3'b010: data_out = {{56{data_in[23]}}, data_in[23:16]}; 
                        3'b011: data_out = {{56{data_in[31]}}, data_in[31:24]}; 
                        3'b100: data_out = {{56{data_in[39]}}, data_in[39:32]}; 
                        3'b101: data_out = {{56{data_in[47]}}, data_in[47:40]}; 
                        3'b110: data_out = {{56{data_in[55]}}, data_in[55:48]}; 
                        3'b111: data_out = {{56{data_in[63]}}, data_in[63:56]};
                        default: data_out = {{56{data_in[7]}}, data_in[7:0]}; 
                    endcase    
                3'b001: //half word
                    case (addr[2:1])
                        2'b00: data_out = {{48{data_in[15]}}, data_in[15:0]}; 
                        2'b01: data_out = {{48{data_in[31]}}, data_in[31:16]}; 
                        2'b10: data_out = {{48{data_in[47]}}, data_in[47:32]}; 
                        2'b11: data_out = {{48{data_in[63]}}, data_in[63:48]}; 
                        default: data_out = {{48{data_in[15]}}, data_in[15:0]}; 
                    endcase
                3'b010: //word
                    case (addr[2])
                        0: data_out = {{32{data_in[31]}}, data_in[31:0]}; 
                        1: data_out = {{32{data_in[63]}}, data_in[63:32]};
                        default: data_out = {{32{data_in[31]}}, data_in[31:0]};
                    endcase
                3'b011: //dword
                    data_out = data_in;
                3'b100: //byte unsign
                    case (addr[2:0])
                        3'b000: data_out = {{56'b0}, data_in[7:0]}; 
                        3'b001: data_out = {{56'b0}, data_in[15:8]}; 
                        3'b010: data_out = {{56'b0}, data_in[23:16]}; 
                        3'b011: data_out = {{56'b0}, data_in[31:24]}; 
                        3'b100: data_out = {{56'b0}, data_in[39:32]}; 
                        3'b101: data_out = {{56'b0}, data_in[47:40]}; 
                        3'b110: data_out = {{56'b0}, data_in[55:48]}; 
                        3'b111: data_out = {{56'b0}, data_in[63:56]};
                        default: data_out = {{56'b0}, data_in[7:0]}; 
                    endcase
   
                3'b101: //half word unsign
                    case (addr[2:1])
                        2'b00: data_out = {{48'b0}, data_in[15:0]}; 
                        2'b01: data_out = {{48'b0}, data_in[31:16]}; 
                        2'b10: data_out = {{48'b0}, data_in[47:32]}; 
                        2'b11: data_out = {{48'b0}, data_in[63:48]}; 
                        default: data_out = {{48'b0}, data_in[15:0]}; 
                    endcase
                3'b110: //word unsign
                    case (addr[2])
                        0: data_out = {{32'b0}, data_in[31:0]}; 
                        1: data_out = {{32'b0}, data_in[63:32]};
                        default: data_out = {{32'b0}, data_in[31:0]}; 
                    endcase
                3'b111: //word unsign
                    case (counter[0])
                        0: data_out = {32'b0, data_in[15:0], data_in[31:16]}; 
                        1: data_out = {32'b0, data_in[47:32], data_in[63:48]}; 
                        default: data_out = {32'b0, data_in[15:0], data_in[31:16]}; 
                    endcase    
                default:
                    data_out = data_in;
            endcase
        end
    end
endmodule
