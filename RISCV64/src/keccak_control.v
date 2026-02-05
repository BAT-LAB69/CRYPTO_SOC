`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2025 10:59:12 AM
// Design Name: 
// Module Name: buffer_controller
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


module keccak_controller(
        input CLK,
        input RST,
        input keccak_we,
        input keccak_valid,
        input keccak_ready,
        output reg keccak_start,
        output reg [63:0] counter_q,
        output keccak_we_real,
        output reg keccak_dmem_write,
        output reg keccak_counter
    );

    reg [2:0] state, next_state;
    //reg [6:0] counter_q;
    reg keccak_counter_sclr;
    reg keccak_counter_ce;
    reg keccak_we_valid;
    
    assign keccak_we_real = keccak_we_valid && keccak_we;
    
    always @(posedge CLK) begin
        if (!RST) keccak_dmem_write <= 1'b0;
        else      keccak_dmem_write <= keccak_valid;
    end
    
    always @(posedge CLK) begin
        if (!RST) counter_q <= 64'h0;
        else begin 
            if (keccak_counter_sclr) counter_q <= 64'h0;
            else if (keccak_counter_ce) counter_q <= counter_q + 1'h1;
            else counter_q <= counter_q;
        end
    end
    
    always @(posedge CLK) begin         //Counter
        if (!RST) state <= 3'h0;
        else      state <= next_state;
    end
    
    
    always @(*) case (state)
        3'h0: next_state = keccak_we ? (state + 1'h1) : state;
        3'h1: next_state = (counter_q == 64'h17) ? (state + 1'h1) : state;
        3'h2: next_state = state + 1'h1;
        3'h3: next_state = state + 1'h1;
        3'h4: next_state = (counter_q == 64'h31) ? (state + 1'h1) : state;
        3'h5: next_state = state + 1'h1;
        3'h6: next_state = (counter_q == 64'h17) ? (state + 1'h1) : state;
        default: next_state = 3'h0;
    endcase
    
    always @(*) case (state)
        3'h0: begin                 //bat dau
//            keccak_dmem_wt = 0;
            keccak_counter_ce   = 1'h0;
            keccak_counter_sclr = 1'h1;
            keccak_start = 0;
            keccak_we_valid = 1;
            keccak_counter = 1;
        end
        3'h1: begin                 //store din vao bram
//            keccak_dmem_wt = 0;
            keccak_counter_ce   = 1'h1;
            keccak_counter_sclr = 1'h0;
            keccak_start = 0;
            keccak_we_valid = 1;
            keccak_counter = 0;
        end
        3'h2: begin                 //store din vao bram
//            keccak_dmem_wt = 0;
            keccak_counter_ce   = 1'h1;
            keccak_counter_sclr = 1'h0;
            keccak_start = 1;
            keccak_we_valid = 0;
            keccak_counter = 0;
        end
        3'h3: begin                 //doi keccak xu ly
//            keccak_dmem_wt = 0;
            keccak_counter_ce   = 1'h0;
            keccak_counter_sclr = 1'h1;
            keccak_start = 0;
            keccak_we_valid = 0;
            keccak_counter = 0;
        end
        3'h4: begin                 //doi keccak xu ly
//            keccak_dmem_wt = 0;
            keccak_counter_ce   = 1'h1;
            keccak_counter_sclr = 1'h0;
            keccak_start = 0;
            keccak_we_valid = 0;
            keccak_counter = 0;
        end
        3'h5: begin                 //doi keccak xu ly
//            keccak_dmem_wt = 0;
            keccak_counter_ce   = 1'h0;
            keccak_counter_sclr = 1'h1;
            keccak_start = 0;
            keccak_we_valid = 0;
            keccak_counter = 0;
        end
        3'h6: begin                 //store dout vao dmem
//            keccak_dmem_wt = 1;
            keccak_counter_ce   = 1'h1;
            keccak_counter_sclr = 1'h0;
            keccak_start = 0;
            keccak_we_valid = 0;
            keccak_counter = 0;
        end
        3'h7: begin                 //store dout vao dmem
//            keccak_dmem_wt = 1;
            keccak_counter_ce   = 1'h0;
            keccak_counter_sclr = 1'h0;
            keccak_start = 0;
            keccak_we_valid = 0;
            keccak_counter = 0;
        end
        default: begin
//            keccak_dmem_wt = 0;
            keccak_counter_ce   = 1'h0;
            keccak_counter_sclr = 1'h0;
            keccak_start = 0;
            keccak_we_valid = 1;
            keccak_counter = 1;
        end
    endcase
endmodule
