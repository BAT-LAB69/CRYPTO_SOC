`timescale 1ns/1ps

module ed25519_shake128(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [255:0] seed, //private key 32 bytes
    input wire [255:0] msg, //message up to 32 bytes
    input wire [6:0] msg_len, // Message length in bytes (0-32)

    output wire [255:0] sig_r, //signature R 32 bytes
    output wire [255:0] sig_s, //signature S 32 bytes
    output wire done,
    output wire busy
);

    // Internal signals connecting Ed25519 and SHAKE128
    wire shake_start;
    wire [2:0] shake_type;
    wire [1023:0] shake_din;
    wire [6:0] shake_len; // 32 or 64 bytes
    
    wire [511:0] shake_dout;
    wire shake_done;
    wire shake_busy;

    // Instantiate Ed25519 Core
    // Note: ed25519_top.v must have external SHAKE ports exposed
    ed25519_top u_ed_core (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .seed(seed),
        .msg(msg),
        .msg_len(msg_len),
        .sig_r(sig_r),
        .sig_s(sig_s),
        .done(done),
        .busy(busy),
        
        // Bypass signals (disabled)
        .i_bypass_en(1'b0),
        .i_ext_s(256'b0),
        .i_ext_prefix(256'b0),
        
        // SHAKE Interface
        .shake_start(shake_start),
        .shake_type(shake_type),
        .shake_din(shake_din),
        .shake_len(shake_len),
        .shake_dout(shake_dout),
        .shake_done(shake_done)
    );

    // Instantiate Generic SHAKE Top (Configured as SHAKE128)
    shake_top u_shake_core (
        .clk(clk),
        .rst(rst_n),
        .start(shake_start),
        .out_len_type(shake_type), // 0: 256-bit, 1: 512-bit output
        .mode(1'b0),               // 0: SHAKE128 (Ed25519 standard), 1: SHAKE256 (BIKE)
        .din(shake_din),
        .byte_len(shake_len),
        .dout(shake_dout),
        .done(shake_done),
        .busy(shake_busy)
    );

endmodule
