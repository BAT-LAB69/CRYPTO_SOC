`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 08:23:34 PM
// Design Name: 
// Module Name: ntt_control
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


module ntt_control(
    input CLK,
    input RST,
    input ntt_we,
    input ntt_valid,
    input ntt_ready,
    output reg ntt_start,
//    output reg ntt_dmem_wt,
    output reg [63:0] counter_q,
    output ntt_we_real,
    output reg ntt_dmem_write
    );
    
//    reg ntt_we_delayed;
    reg [2:0] state, next_state;
    //reg [6:0] counter_q;
    reg ntt_counter_sclr;
    reg ntt_counter_ce;
    reg ntt_we_valid;
    
    assign ntt_we_real = ntt_we_valid && ntt_we;
    
    always @(posedge CLK) begin
        if (!RST) ntt_dmem_write <= 1'b0;
        else      ntt_dmem_write <= ntt_valid;
    end
    
    always @(posedge CLK) begin
        if (!RST) counter_q <= 64'h0;
        else begin 
            if (ntt_counter_sclr) counter_q <= 64'h0;
            else if (ntt_counter_ce) counter_q <= counter_q + 1'h1;
            else counter_q <= counter_q;
        end
    end
    
    always @(posedge CLK) begin         //Counter
        if (!RST) state <= 3'h0;
        else      state <= next_state;
    end
    
//    always @(posedge CLK) begin         //Counter
//        if (!RST) ntt_we_delayed <= 3'h0;
//        else      ntt_we_delayed <= ntt_we;
//    end
    
    always @(*) case (state)
        3'h0: next_state = ntt_we ? (state + 1'h1) : state;
        3'h1: next_state = (counter_q == 64'h7e) ? (state + 1'h1) : state;
        3'h2: next_state = (counter_q == 64'h7f) ? (state + 1'h1) : state;
        3'h3: next_state = state + 1'h1;
        3'h4: next_state = (counter_q == 64'h3D8) ? (state + 1'h1) : state;
        3'h5: next_state = state + 1'h1;
        3'h6: next_state = (counter_q == 64'h7f) ? (state + 1'h1) : state;
        default: next_state = 3'h0;
    endcase
    
    always @(*) case (state)
        3'h0: begin                 //bat dau
//            ntt_dmem_wt = 0;
            ntt_counter_ce   = 1'h0;
            ntt_counter_sclr = 1'h1;
            ntt_start = 0;
            ntt_we_valid = 1;
        end
        3'h1: begin                 //store din vao bram
//            ntt_dmem_wt = 0;
            ntt_counter_ce   = 1'h1;
            ntt_counter_sclr = 1'h0;
            ntt_start = 0;
            ntt_we_valid = 1;
        end
        3'h2: begin                 //store din vao bram
//            ntt_dmem_wt = 0;
            ntt_counter_ce   = 1'h1;
            ntt_counter_sclr = 1'h0;
            ntt_start = 0;
            ntt_we_valid = 0;
        end
        3'h3: begin                 //doi ntt xu ly
//            ntt_dmem_wt = 0;
            ntt_counter_ce   = 1'h0;
            ntt_counter_sclr = 1'h1;
            ntt_start = 1;
            ntt_we_valid = 0;
        end
        3'h4: begin                 //doi ntt xu ly
//            ntt_dmem_wt = 0;
            ntt_counter_ce   = 1'h1;
            ntt_counter_sclr = 1'h0;
            ntt_start = 0;
            ntt_we_valid = 0;
        end
        3'h5: begin                 //doi ntt xu ly
//            ntt_dmem_wt = 0;
            ntt_counter_ce   = 1'h0;
            ntt_counter_sclr = 1'h1;
            ntt_start = 0;
            ntt_we_valid = 0;
        end
        3'h6: begin                 //store dout vao dmem
//            ntt_dmem_wt = 1;
            ntt_counter_ce   = 1'h1;
            ntt_counter_sclr = 1'h0;
            ntt_start = 0;
            ntt_we_valid = 0;
        end
        default: begin
//            ntt_dmem_wt = 0;
            ntt_counter_ce   = 1'h0;
            ntt_counter_sclr = 1'h0;
            ntt_start = 0;
            ntt_we_valid = 1;
        end
    endcase

    
endmodule
