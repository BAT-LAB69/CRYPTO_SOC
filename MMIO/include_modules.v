`include "aes_top.v"  
`include "ed25519_top.v"
`include "hakara_256_v2.v"
`include "shake_top.v"
`include "bike_top.v"
`include "rsa.v"

ed25519_top(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [255:0] seed, //private key 32 bytes
    input wire [255:0] msg, //message up to 32 bytes
    input wire [6:0] msg_len, // Message length in bytes (0-32)

    output reg [255:0] sig_r, //signature R 32 bytes
    output reg [255:0] sig_s, //signature S 32 bytes
    output reg done,
    output wire busy,

    // Bypass / Domain Separation Interface
    input wire i_bypass_en,
    input wire [255:0] i_ext_s,
    input wire [255:0] i_ext_prefix,

    // SHAKE128 interface (External)
    output reg shake_start,
    output reg [2:0] shake_type, // 0: 256bit, 1: 512bit
    output reg [1023:0] shake_din,
    input wire [511:0] shake_dout,
    input wire shake_done,
    output reg [6:0] shake_len // Input length in bytes
);

haraka_256_v2(
input wire [255:0] in,
    output wire [255:0] out
);


bike_top #(
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8,
    parameter MAX_IT = 1,
    parameter THRESHOLD = 2
)(
    input  wire           clk,
    input  wire           rst,
    input  wire           start,

    input  wire [W*POS_W-1:0] h0_pos_flat,
    input  wire [W*POS_W-1:0] h1_pos_flat,

    input  wire [R-1:0]   c0,
    input  wire [R-1:0]   c1,

    output wire [511:0]   shared_key,
    output wire           done
);


rsa #( 
    parameter WIDTH = 32, 
    parameter E_BITS = 32 
)( 
    input  wire                   clk, 
    input  wire                   rst, 
    input  wire                   start, 
 
    input  wire [WIDTH-1:0]       M, 
    input  wire [E_BITS-1:0]      E, 
    input  wire [WIDTH-1:0]       N, 
    input  wire [WIDTH-1:0]       N_INV, 
    input  wire [WIDTH-1:0]       R2_MOD_N, // R^2 mod N 
 
    output reg  [WIDTH-1:0]       C, 
    output reg                    done 
); 

shake_top(
    input wire clk,
    input wire rst,

    input wire start,
    input wire [2:0] out_len_type, //0: 256-bit output, 1:512-bit output 
    input wire mode, // 0: SHAKE128, 1: SHAKE256
    input wire [1023:0] din,
    input wire [6:0] byte_len, // Added for dynamic padding

    output wire [511:0] dout,
    output wire done,
    output wire busy
);
