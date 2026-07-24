`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 09:34:41 PM
// Design Name: 
// Module Name: dmem_data_size
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

module dmem_in(
    input [2:0] size,
    input dmem_write,
    input [`DATA_BITS-1:0] data_in,
    input [`DATA_BITS-1:0] addr,
    input [`DATA_BITS-1:0] counter,
    output reg [7:0] web,
    output reg [`DATA_BITS-1:0] data_out
    );
    
    always @ (*) begin
        if (dmem_write) begin
            case (size)
                3'b000: begin //byte
                    web = 8'h01 << addr[2:0];
                    data_out = data_in << 8*addr[2:0];       
                end 
                3'b001: begin //half word
                    web = 8'h03 << 2*addr[2:1];
                    data_out = data_in << 16*addr[2:1];
                end
                3'b010: begin //word
                    web = 8'h0f << 4*addr[2];
                    data_out = data_in << 32*addr[2];
                end 
                3'b011: begin
                    web = 8'hff; //double word
                    data_out = data_in;
                end
                3'b111: begin
                    case (counter[0])
                        0: begin
                            web = 8'h0f;
                            data_out = {32'b0, data_in[15:0], data_in[31:16]}; 
                        end
                        1: begin
                            web = 8'hf0; 
                            data_out = {data_in[15:0], data_in[31:16], 32'b0};
                        end
                        default: begin
                            web = 8'h0f;
                            data_out = {32'b0, data_in[15:0], data_in[31:16]};
                        end    
                    endcase
                end
                default: begin
                    web = 8'hff; //double word
                    data_out = data_in;
                end
            endcase
        end  
        else begin
           web = 8'h0;   
           data_out = data_in;  
       end
            
        
    end	
endmodule
