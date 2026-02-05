`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 02:51:53 AM
// Design Name: 
// Module Name: shake_aes_top
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


module shake_aes_top(
input  wire         i_clk,
    input  wire         i_rst_n,
    
 
    input  wire [127:0] i_ext_plaintext, 
    input  wire [127:0] i_ext_iv,
    
    
    input  wire [63:0]  i_shake_data,
    input  wire         i_shake_valid,
    input  wire         i_shake_last,
    input  wire         i_shake_ack, 
    
   
    input  wire         i_btn_press,   
    output wire [127:0] o_aes_out,     
    
    
    output wire         o_shake_ready, 
    output wire         o_shake_valid, 
    output wire         o_squeeze_mode,
    output wire [127:0] o_debug_key    
);

 
    wire [127:0] shake_gen_data;
    wire [127:0] mux_to_aes_p, mux_to_aes_k, mux_to_aes_iv;

   
    shake128_top u_shake_gen (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_data     (i_shake_data),
        .i_valid    (i_shake_valid),
        .i_last     (i_shake_last),
        .o_ready    (o_shake_ready),  
        .o_data     (shake_gen_data),  
        .o_valid    (o_shake_valid),   
        .i_ack      (i_shake_ack),
        .o_squeeze_mode (o_squeeze_mode) // 
    );

   
    MUX u_input_gate (
        .i_plaintext (i_ext_plaintext), 
        .i_iv        (i_ext_iv),       
        .i_key       (shake_gen_data),  
        .press       (i_btn_press),
        .o_plaintext (mux_to_aes_p),
        .o_key       (mux_to_aes_k),
        .o_iv        (mux_to_aes_iv)
    );

   
    aes_enc_top u_aes_cbc (
        .in  (mux_to_aes_p),
        .iv  (mux_to_aes_iv),
        .key (mux_to_aes_k),
        .out (o_aes_out) 
    );

 
    assign o_debug_key = mux_to_aes_k; 
endmodule
