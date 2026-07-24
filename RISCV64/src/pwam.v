`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2025 10:59:25 AM
// Design Name: 
// Module Name: pwam
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

module pwam(
    input  wire        clk,
    input  wire        srst,
    input  wire        start,
    input  wire 	   wea,
    input  wire [31:0] dina, 
    input  wire 	   web,
    input  wire [31:0] dinb,
    output reg        valid,
    output reg [31:0] dout,
    output reg        ready,
    output reg        done,
    input wire          mode
    );
    
    reg         ram0_we;
    reg  [ 7:0] ram0_a, ram0_dpra;
    reg  [31:0] ram0_d;
    wire [31:0] ram0_qspo, ram0_qdpo;
    reg         ram1_we;
    reg  [ 7:0] ram1_a, ram1_dpra;
    reg  [31:0] ram1_d;
    wire [31:0] ram1_qspo, ram1_qdpo;
    reg         counter0_ce, counter0_sclr;
    reg  [ 7:0] counter0_q;
    reg         counter1_ce, counter1_sclr;
    reg  [ 7:0] counter1_q;
    reg         pwm_en;
    wire [15:0] pwm0_ra, pwm0_rb;
    reg  [15:0] sum0, sum1;
    wire [15:0] red0, red1;
    reg  [ 3:0] state, next_state;
    reg         counter2_ce, counter2_sclr;
    reg  [ 5:0] counter2_q;
    reg         valid_output, ready_output;
    reg         done_output;
    wire  [31:0] dout_output; 
    reg   [31:0] dout_delay;   
    reg         counter3_ce, counter3_sclr;
    reg  [ 7:0] counter3_q;  
    reg ram1_a_sel;
    
    dist_mem_gen_0     RAM_0    (.clk(clk), .we(ram0_we), .a(ram0_a), .d(ram0_d), .dpra(ram0_dpra), .qspo(ram0_qspo), .qdpo(ram0_qdpo));
    dist_mem_gen_0     RAM_1    (.clk(clk), .we(ram1_we), .a(ram1_a), .d(ram1_d), .dpra(ram1_dpra), .qspo(ram1_qspo), .qdpo(ram1_qdpo));
    pwm                PWM_0    (.clk(clk), .srst(srst), .en(pwm_en), .a(ram0_qspo), .b(ram0_qdpo), .ra(pwm0_ra), .rb(pwm0_rb));
    bart_red           Bred_0   (.clk(clk), .srst(srst), .din(sum0), .dout(red0));
    bart_red           Bred_1   (.clk(clk), .srst(srst), .din(sum1), .dout(red1));
    
    assign dout_output  = {red0, red1};
//    assign valid = valid_output;
//    assign ready = ready_output;
//    assign done = done_output;
    assign pwm0_b = (mode == 0) ? ram1_qspo : ram0_qdpo;
    
    always @(posedge clk) begin
        if (srst) dout <= 0;
        else dout <= dout_delay;
    end
    
    always @(posedge clk) begin
        if (srst) dout_delay <= 0;
        else dout_delay <= dout_output;
    end
    
    always @(posedge clk) begin
        if (srst) valid <= 0;
        else valid <= valid_output;
    end
    
    always @(posedge clk) begin
        if (srst) ready <= 0;
        else ready <= ready_output;
    end
    
    always @(posedge clk) begin
        if (srst) done <= 0;
        else done <= done_output;
    end
    
    always @(posedge clk) begin
        if (srst) counter0_q <= 8'h0;
        else begin
            if (counter0_sclr) counter0_q <= 8'h0;
            else if (counter0_ce | wea) counter0_q <= counter0_q + 1'h1;
            else counter0_q <= counter0_q;
        end
    end
    
    always @(posedge clk) begin
        if (srst) counter1_q <= 8'h0;
        else begin
            if (counter1_sclr) counter1_q <= 8'h0;
            else if (counter1_ce | web) counter1_q <= counter1_q + 1'h1;
            else counter1_q <= counter1_q;
        end
    end
    
    always @(posedge clk) begin
        if (srst) counter2_q <= 6'h0;
        else begin
            if (counter2_sclr) counter2_q <= 6'h0;
            else if (counter2_ce) counter2_q <= counter2_q + 1'h1;
            else counter2_q <= counter2_q;
        end
    end
    
    always @(posedge clk) begin
        if (srst) counter3_q <= 6'h0;
        else begin
            if (counter3_sclr) counter3_q <= 6'h0;
            else if (counter3_ce) counter3_q <= counter3_q + 1'h1;
            else counter3_q <= counter3_q;
        end
    end
    
    always @(posedge clk) begin
        if (srst) ram0_we <= 1'h0;
        else ram0_we <= wea;
    end
    
    always @(posedge clk) begin
        if (srst) ram0_a <= 8'h0;
        else ram0_a <= counter0_q;
    end
    
    always @(posedge clk) begin
        if (srst) ram0_dpra <= 8'h0;
        else ram0_dpra <= counter0_q + 8'h80;
    end
    
    always @(posedge clk) begin
        if (srst) ram0_d <= 32'h0;
        else ram0_d <= dina;
    end
    
    always @(posedge clk) begin
        if (srst) ram1_we <= 1'h0;
        else ram1_we <= web;
    end
    
    always @(posedge clk) begin
        if (srst) ram1_a <= 8'h0;
        else ram1_a <= (!ram1_a_sel) ? counter1_q : counter3_q;
    end
    
    always @(posedge clk) begin
        if (srst) ram1_dpra <= 8'h0;
        else ram1_dpra <= (!ram1_a_sel) ? (counter1_q + 8'h80) : (counter3_q + 1);
    end
    
    always @(posedge clk) begin
        if (srst) ram1_d <= 32'h0;
        else ram1_d <= dinb;
    end
    
    always @(posedge clk) begin
        if (srst) sum0 <= 16'h0;
        else sum0 <= (!ram1_a_sel) ? (pwm0_ra) : (pwm0_ra + ram1_qspo[31:16]);
    end
    
    always @(posedge clk) begin
        if (srst) sum1 <= 16'h0;
        else sum1 <= (!ram1_a_sel) ? (pwm0_rb) : (pwm0_rb + ram1_qspo[15:0]);
    end
    
    always @(*) case (state)
        4'h0: next_state = start ? (state + 1'h1) : state;
        4'h1: next_state = (counter2_q == 6'h01) ? (state + 1'h1) : state;
        4'h2: next_state = (counter2_q == 6'h0a) ? (state + 1'h1) : state;
        4'h3: next_state = (counter2_q == 6'h10) ? (state + 1'h1) : state;
        4'h4: next_state = (counter2_q == 8'h11) ? (state + 1'h1) : state;
        4'h5: next_state = (counter0_q == 8'h7f) ? (state + 1'h1) : state;
        4'h6: next_state = (counter2_q == 8'h10) ? (state + 1'h1) : state;
        4'h7: next_state = state + 1'h1;
        default: next_state = 3'h0;
    endcase
    
    always @(posedge clk) begin
        if (srst) state <= 3'h0;
        else state <= next_state;
    end
    
    always @(*) case (state)
        4'h1: begin
            counter0_ce   = 1'h1;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h1;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h0;
            counter2_ce   = 1'h1;
            counter2_sclr = 1'h0;
            valid_output  = 1'h0;
            done_output   = 1'h0;
            ready_output  = 1'h0;
            counter3_ce   = 1'h0;
            counter3_sclr = 1'h1;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        4'h2: begin
            counter0_ce   = 1'h1;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h1;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h1;
            counter2_ce   = 1'h1;
            counter2_sclr = 1'h0;
            valid_output  = 1'h0;
            done_output   = 1'h0;
            ready_output  = 1'h0;
            counter3_ce   = 1'h0;
            counter3_sclr = 1'h1;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        4'h3: begin
            counter0_ce   = 1'h1;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h1;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h1;
            counter2_ce   = 1'h1;
            counter2_sclr = 1'h0;
            valid_output  = 1'h0;
            done_output   = 1'h0;
            ready_output  = 1'h0;
            counter3_ce   = 1'h1;
            counter3_sclr = 1'h0;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        4'h4: begin
            counter0_ce   = 1'h1;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h1;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h1;
            counter2_ce   = 1'h1;
            counter2_sclr = 1'h0;
            valid_output  = 1'h0;
            ready_output  = 1'h1;
            done_output   = 1'h0;
            counter3_ce   = 1'h1;
            counter3_sclr = 1'h0;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        4'h5: begin
            counter0_ce   = 1'h1;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h1;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h1;
            counter2_ce   = 1'h1;
            counter2_sclr = 1'h0;
            valid_output  = 1'h1;
            done_output   = 1'h0;
            ready_output  = 1'h0;
            counter3_ce   = 1'h1;
            counter3_sclr = 1'h0;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        4'h6: begin
            counter0_ce   = 1'h0;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h0;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h0;
            counter2_ce   = 1'h1;
            counter2_sclr = 1'h0;
            valid_output  = 1'h1;
            done_output   = 1'h0;
            ready_output  = 1'h0;
            counter3_ce   = 1'h1;
            counter3_sclr = 1'h0;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        4'h7: begin
            counter0_ce   = 1'h0;
            counter0_sclr = 1'h1;
            counter1_ce   = 1'h0;
            counter1_sclr = 1'h1;
            pwm_en        = 1'h0;
            counter2_ce   = 1'h0;
            counter2_sclr = 1'h1;
            valid_output  = 1'h1;
            done_output   = 1'h0;
            ready_output  = 1'h0;
            counter3_ce   = 1'h1;
            counter3_sclr = 1'h0;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        4'h8: begin
            counter0_ce   = 1'h0;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h0;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h0;
            counter2_ce   = 1'h0;
            counter2_sclr = 1'h0;
            valid_output  = 1'h0;
            done_output   = 1'h1;
            ready_output  = 1'h0;
            counter3_ce   = 1'h1;
            counter3_sclr = 1'h0;
            ram1_a_sel = (mode == 0) ? 1'b0 : 1;
        end
        default: begin
            counter0_ce   = 1'h0;
            counter0_sclr = 1'h0;
            counter1_ce   = 1'h0;
            counter1_sclr = 1'h0;
            pwm_en        = 1'h0;
            counter2_ce   = 1'h0;
            counter2_sclr = 1'h0;
            valid_output  = 1'h0;
            ready_output  = 1'h0;
            done_output   = 1'h0;
            counter3_ce   = 1'h0;
            counter3_sclr = 1'h1;
            ram1_a_sel = 1'b0;
        end
    endcase

endmodule