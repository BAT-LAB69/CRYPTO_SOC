`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2025 10:50:37 AM
// Design Name: 
// Module Name: pwam_controller
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


module pwam_control(
        input CLK,
        input RST,
        input pwam_we,
        input pwam_ready,
        input pwam_valid,
        output reg pwam_start,
        output reg [63:0] counter_q,
        output reg pwam_dmem_write,
        output pwam_wea,
        output pwam_web,
        output reg [1:0] pwam_addr_sel,
        output reg pwam_counter
    );
    
    
    
    reg [3:0] state, next_state;
    reg pwam_counter_sclr;
    reg pwam_counter_ce;
    reg pwam_wea_valid, pwam_web_valid;
    
    assign pwam_wea = pwam_wea_valid && pwam_we;
    assign pwam_web = pwam_web_valid && pwam_we;
    
    always @(posedge CLK) begin
        if (!RST) pwam_dmem_write <= 1'b0;
        else      pwam_dmem_write <= pwam_valid;
    end
    
    always @(posedge CLK) begin
        if (!RST) counter_q <= 64'h0;
        else begin 
            if (pwam_counter_sclr) counter_q <= 7'h0;
            else if (pwam_counter_ce) counter_q <= counter_q + 1'h1;
            else counter_q <= counter_q;
        end
    end
    
    always @(posedge CLK) begin         //Counter
        if (!RST) state <= 3'h0;
        else      state <= next_state;
    end
    
    always @(*) case (state)
        4'h0: next_state = (pwam_we) ? state + 1'h1 : state;
        4'h1: next_state = (counter_q == 64'h7e) ? (state + 1'h1) : state;
        4'h2: next_state = (counter_q == 64'h7f) ? (state + 1'h1) : state;
        4'h3: next_state = (counter_q == 64'h7e) ? (state + 1'h1) : state;
        4'h4: next_state = (counter_q == 64'h7f) ? (state + 1'h1) : state;
        4'h5: next_state = (counter_q == 64'h7e) ? (state + 1'h1) : state;
        4'h6: next_state = (counter_q == 64'h7f) ? (state + 1'h1) : state;
        4'h7: next_state = state + 1'h1;
        4'h8: next_state = (counter_q == 64'h14) ? (state + 1'h1) : state;
        4'h9: next_state = state + 1'h1;
        4'ha: next_state = (counter_q == 64'h7f) ? (state + 1'h1) : state;
        default: next_state = 4'h0;
    endcase
    
    always @(*) case (state)
        4'h0: begin                 //bat dau
            pwam_counter_ce   = 1'h0;
            pwam_counter_sclr = 1'h1;
            pwam_start = 0;
            pwam_wea_valid = 1;
            pwam_web_valid = 0;
            pwam_addr_sel = 0;
            pwam_counter = 0;
        end
        4'h1: begin                 //store din vao bram
            pwam_counter_ce   = 1'h1;
            pwam_counter_sclr = 1'h0;
            pwam_start = 0;
            pwam_wea_valid = 1;
            pwam_web_valid = 0; 
            pwam_addr_sel = 3;      
            pwam_counter = 1;    
        end
        4'h2: begin                 //store din vao bram
            pwam_counter_ce   = 1'h0;
            pwam_counter_sclr = 1'h1;
            pwam_start = 0;
            pwam_wea_valid = 1;
            pwam_web_valid = 0; 
            pwam_addr_sel = 3;       
            pwam_counter = 1;   
        end
        4'h3: begin                 //store din vao bram
            pwam_counter_ce   = 1'h1;
            pwam_counter_sclr = 1'h0;
            pwam_start = 0;
            pwam_wea_valid = 1;
            pwam_web_valid = 0; 
            pwam_addr_sel = 0;      
            pwam_counter = 1;    
        end
        4'h4: begin                 //store din vao bram
            pwam_counter_ce   = 1'h0;
            pwam_counter_sclr = 1'h1;
            pwam_start = 0;
            pwam_wea_valid = 0;
            pwam_web_valid = 1;   
            pwam_addr_sel = 0;       
            pwam_counter = 1;   
        end
        4'h5: begin                 //store din vao bram
            pwam_counter_ce   = 1'h1;
            pwam_counter_sclr = 1'h0;
            pwam_start = 0;
            pwam_wea_valid = 0;
            pwam_web_valid = 1;  
            pwam_addr_sel = 1;      
            pwam_counter = 1;    
        end
        4'h6: begin                 //store din vao bram
            pwam_counter_ce   = 1'h0;
            pwam_counter_sclr = 1'h1;
            pwam_start = 0;
            pwam_wea_valid = 0;
            pwam_web_valid = 0;  
            pwam_addr_sel = 1;       
            pwam_counter = 1;   
        end    
        4'h7: begin                 //doi ntt xu ly
            pwam_counter_ce   = 1'h0;
            pwam_counter_sclr = 1'h1;
            pwam_start = 1;
            pwam_wea_valid = 0;
            pwam_web_valid = 0;  
            pwam_addr_sel = 1;
            pwam_counter = 1;  
        end
        4'h8: begin                 //doi ntt xu ly
            pwam_counter_ce   = 1'h1;
            pwam_counter_sclr = 1'h0;
            pwam_start = 0;
            pwam_wea_valid = 0;
            pwam_web_valid = 0; 
            pwam_addr_sel = 2;
            pwam_counter = 1;  
        end
        4'h9: begin                 //store dout vao dmem
            pwam_counter_ce   = 1'h0;
            pwam_counter_sclr = 1'h1;
            pwam_start = 0;
            pwam_wea_valid = 0;
            pwam_web_valid = 0;
            pwam_addr_sel = 2; 
            pwam_counter = 1;   
        end
        4'ha: begin                 //store dout vao dmem
            pwam_counter_ce   = 1'h1;
            pwam_counter_sclr = 1'h0;
            pwam_start = 0;
            pwam_wea_valid = 0;
            pwam_web_valid = 0;
            pwam_addr_sel = 2; 
            pwam_counter = 1;   
        end
        default: begin
            pwam_counter_ce   = 1'h0;
            pwam_counter_sclr = 1'h0;
            pwam_start = 0;
            pwam_wea_valid = 0;
            pwam_web_valid = 0; 
            pwam_addr_sel = 0; 
            pwam_counter = 0;  
        end
    endcase
endmodule



