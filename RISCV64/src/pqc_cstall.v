`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2025 08:31:44 AM
// Design Name: 
// Module Name: pqc_cstall
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


module pqc_cstall(
        input [6:0] Opcode,
        input [2:0] Funct3,
        input [6:0] Funct7,
        input pwam_done,
        input ntt_done,
        input keccak_done,
        output reg pwam_stall,//indicates that pwam is still running
        output reg pwam_we,
        output reg pwam_mode,
        output reg ntt_stall,//indicates that ntt is still running
        output reg ntt_we,
        output reg keccak_stall,//indicates that ntt is still running
        output reg keccak_we
    );
    
    always @ (*) begin
        ntt_we  = 0;
        pwam_we = 0;
        keccak_we = 0;
        pwam_mode = 0;
        if (Opcode == 7'b0001011 && Funct3 == 3'b011) begin
            case (Funct7)
                7'b0000100, 7'b0000011: 
                    ntt_we = !ntt_done; 
            
                7'b0000111: begin
                    pwam_we = !pwam_done;
                    pwam_mode = 0;
                end
                
                7'b0000101: begin
                    pwam_we = !pwam_done;
                    pwam_mode = 1;
                end
                
                7'b0000000: 
                    keccak_we = !keccak_done; 
                
                default: begin
                    ntt_we  = 0;
                    pwam_we = 0;
                    pwam_mode = 1;
                    keccak_we = 0;
                end
                    
            endcase 
        end               
    end
    
    always @ (*) begin
        ntt_stall = 0; 
        if (ntt_we)
            ntt_stall = 1;
        else if (ntt_done)
            ntt_stall = 0;    
    end    
    
    always @ (*) begin
        pwam_stall = 0; 
        if (pwam_we)
            pwam_stall = 1;
        else if (pwam_done)
            pwam_stall = 0;    
    end  
    
    always @ (*) begin
        keccak_stall = 0; 
        if (keccak_we)
            keccak_stall = 1;
        else if (keccak_done)
            keccak_stall = 0;    
    end   

    
    
endmodule
