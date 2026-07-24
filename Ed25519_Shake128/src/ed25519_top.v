`timescale 1ns/1ps

module ed25519_top(
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
    /* Internal SHAKE Removed for System Integrated Mode */
    
    reg [255:0] pub_key_y;
    reg [255:0] s_scalar; // S_scalar sau khi clamp
    reg [255:0] prefix;   // prefix from hash(seed)
    
    reg [255:0] k_hash;
    reg [255:0] r_nonce;
    reg [255:0] temp_scalar_rev;
    
    reg  sc_mult_start;
    wire sc_mult_done;
    wire [254:0] sc_mult_res_x, sc_mult_res_y, sc_mult_res_z, sc_mult_res_t;
    
    reg  inv_start;
    reg  [254:0] inv_din;
    wire [254:0] inv_dout;
    wire inv_done;
    wire inv_busy;

    reg  [254:0] mul_a, mul_b;
    wire [254:0] mul_res;
    // Sequential multiplier signals
    reg  mul_start;
    wire mul_done;
    wire mul_busy;

    // Reducer signals (shared for r_nonce and k_hash)
    reg  reducer_start;
    wire reducer_done;
    wire [252:0] reducer_dout;

    // Base Point G Constants (y = 4/5)
    // Corrected to Big Endian (MSB...LSB)
    // Standard Ed25519 base point
    localparam [254:0] G_X = 255'h216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a;
    localparam [254:0] G_Y = 255'h6666666666666666666666666666666666666666666666666666666666666658;


    // Internal Top FSM
    localparam IDLE        = 5'd0;
    localparam HASH_SEED   = 5'd1;
    localparam WAIT_SEED   = 5'd2;
    localparam GEN_PUBKEY  = 5'd3;
    localparam INV_PUB_Z   = 5'd4;
    localparam PREP_PUB_Y  = 5'd5;
    localparam CALC_PUB_Y  = 5'd6;
    // Added states for Sign Bit (X)
    localparam PREP_PUB_X  = 5'd19;
    localparam CALC_PUB_X  = 5'd20;
    
    localparam HASH_MSG    = 5'd7;
    localparam WAIT_MSG    = 5'd8;
    localparam REDUCE_R    = 5'd9;
    localparam GEN_SIG_R   = 5'd10;
    localparam INV_SIG_Z   = 5'd11;
    localparam PREP_SIG_R  = 5'd12;
    localparam CALC_SIG_R  = 5'd13;
    // Added states for Sign Bit (X)
    localparam PREP_SIG_X  = 5'd21;
    localparam CALC_SIG_X  = 5'd22;

    localparam HASH_K      = 5'd14;
    localparam WAIT_K      = 5'd15;
    localparam REDUCE_K    = 5'd16;
    localparam CALC_S      = 5'd17;
    localparam FINISH      = 5'd18;
    localparam FINISH_ZERO = 5'd23; // Delay zeroization by 1 cycle
    localparam WAIT_PUB_START = 5'd24;
    localparam WAIT_SIG_START = 5'd25;

    reg [4:0] state;
    assign busy = (state != IDLE);
    
    // Aux register for Affine X
    reg [254:0] x_affine;
    
    // Store Z^-1 for both X and Y affine calculations
    reg [254:0] z_inv_cache;
    
    // Wait counter for SHAKE start/done synchronization
    reg [2:0] shake_wait_cnt;

    // Mux for scalar multiplication input
    // assign current_scalar = (state == GEN_SIG_R || state == WAIT_SIG_START || state == INV_SIG_Z || state == PREP_SIG_R || state == CALC_SIG_R || state == PREP_SIG_X || state == CALC_SIG_X) ? r_nonce : s_scalar;
    wire [255:0] current_scalar;
    reg [255:0] current_scalar_reg;
    assign current_scalar = current_scalar_reg;
    
    always @(*) begin
        if (state == GEN_SIG_R || state == WAIT_SIG_START || state == INV_SIG_Z || state == PREP_SIG_R || state == CALC_SIG_R || state == PREP_SIG_X || state == CALC_SIG_X) begin
            current_scalar_reg = r_nonce;
        end else begin
            current_scalar_reg = s_scalar;
        end
    end
    // G_T = G_X * G_Y mod P (for extended twisted Edwards coordinates)
    wire [254:0] multiplicated_t = 255'h67875f0fd78b766566ea4e8e64abe37d20f09f80775152f56dde8ab3a5b7dda3;


    scala_mul_25519 scalar_unit (
        .clk(clk), .rst(rst_n), .start(sc_mult_start), 
        .scalar(current_scalar), 
        .base_x(G_X), .base_y(G_Y), .base_z(255'd1), .base_t(multiplicated_t),
        .res_x(sc_mult_res_x), .res_y(sc_mult_res_y), .res_z(sc_mult_res_z), .res_t(sc_mult_res_t),
        .done(sc_mult_done), .busy()
    );

    inv_25519 inv_unit (
        .clk(clk), .rst(rst_n), .start(inv_start), .a(inv_din), .res(inv_dout), 
        .done(inv_done), .busy(inv_busy)
    );

    mul_25519 mul_unit (
        .clk(clk), .rst(rst_n), .start(mul_start),
        .a(mul_a), .b(mul_b),
        .res(mul_res), .done(mul_done), .busy(mul_busy)
    );

    reg mod_l_start;
    wire [252:0] final_s;
    wire mod_l_done;

    arithmetic l_unit (
        .clk(clk), .rst(rst_n), .start(mod_l_start), .k_in(k_hash), .s_in(s_scalar), .r_in(r_nonce),
        .s_out(final_s), .done(mod_l_done), .busy()
    );

    reducer hash_reducer (
        .clk(clk), .rst(rst_n), .start(reducer_start),
        .din(shake_dout),
        .dout(reducer_dout), .done(reducer_done), .busy()
    );

    // Function to reverse bytes of a 256-bit vector
    function [255:0] reverse_bytes;
        input [255:0] in;
        integer i;
        begin
            for (i=0; i<32; i=i+1) begin
                reverse_bytes[i*8 +: 8] = in[(31-i)*8 +: 8];
            end
        end
    endfunction

    // Function to swap bytes within 64-bit words
    function [255:0] endian_swap_64;
        input [255:0] in;
        integer i, j;
        reg [63:0] tmp;
        begin
            for (i=0; i<4; i=i+1) begin // 4 words of 64 bits
                tmp = in[i*64 +: 64];
                for (j=0; j<8; j=j+1) begin
                    endian_swap_64[i*64 + j*8 +: 8] = tmp[(7-j)*8 +: 8];
                end
            end
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done <= 0;
            shake_start <= 0;
            reducer_start <= 0;
            sc_mult_start <= 0;
            inv_start <= 0;
            mod_l_start <= 0;
            mul_start <= 0;
            // shake_wait_cnt <= 0; // Optional, set in states
            inv_start <= 0;
            mod_l_start <= 0;
            mul_start <= 0;
        end else begin
            shake_start <= 0;
            reducer_start <= 0;
            inv_start <= 0;
            mod_l_start <= 0;
            mul_start <= 0;

            case (state)
                IDLE: begin
                    done <= 0;
                    sc_mult_start <= 0;
                    if (start) begin
                        if (i_bypass_en) begin
                            // Bypass Seed Hashing
                            s_scalar <= i_ext_s; 
                            prefix <= i_ext_prefix;
                            state <= GEN_PUBKEY;
                        end else begin
                            // Default Mode: Hash Seed
                            // Reverse seed bytes because input is Big Endian
                            shake_din <= {768'b0, reverse_bytes(seed)}; 
                            
                            shake_len <= 7'd32; // 32 bytes
                            shake_type <= 3'd1; // 512-bit output required for Ed25519 (32-byte s, 32-byte prefix)
                            shake_type <= 3'd1; // 512-bit output required for Ed25519 (32-byte s, 32-byte prefix)
                            shake_start <= 1;
                            shake_wait_cnt <= 0;
                            state <= WAIT_SEED;
                        end
                    end
                end

                WAIT_SEED: begin
                    // Wait for start to propagate and done to clear (approx 2-3 cycles)
                    if (shake_wait_cnt < 4) begin
                         shake_wait_cnt <= shake_wait_cnt + 1;
                    end else if (shake_done) begin
                        s_scalar <= {
                            1'b0, 1'b1, // s[255]=0, s[254]=1
                            shake_dout[253:8],
                            (shake_dout[7:0] & 8'hf8) // s[0] clamped
                        };
                        
                        prefix <= shake_dout[511:256]; 
                        state <= GEN_PUBKEY;
                    end
                end

                GEN_PUBKEY: begin
                    sc_mult_start <= 1; // start P = scalar * G
                    state <= INV_PUB_Z; 
                end

                INV_PUB_Z: begin
                    sc_mult_start <= 0; // Prevent re-triggering
                    if (sc_mult_done) begin
                        inv_din <= sc_mult_res_z;  
                        inv_start <= 1;           
                        state <= PREP_PUB_Y;
                    end
                end
                
                PREP_PUB_Y: if (inv_done) begin
                    // y = Y * Z^-1
                    z_inv_cache <= inv_dout; // Cache Z^-1 for reuse
                    mul_a <= sc_mult_res_y; 
                    mul_b <= inv_dout; // Z^-1     
                    mul_start <= 1;
                    state <= CALC_PUB_Y;
                end


                CALC_PUB_Y: if (mul_done) begin
                    pub_key_y <= {1'b0, mul_res}; // Store Y, sign bit 0 initially
                    state <= PREP_PUB_X;
                end
                
                PREP_PUB_X: begin
                     // x = X * Z^-1
                     mul_a <= sc_mult_res_x;
                     mul_b <= z_inv_cache; // Use cached Z^-1
                     mul_start <= 1;
                     state <= CALC_PUB_X;
                end

                CALC_PUB_X: if (mul_done) begin
                    x_affine <= mul_res;
                    pub_key_y[255] <= mul_res[0]; // Set sign bit from X
                    
                    // Fix: Shift reversed msg back to LSB based on msg_len
                    // reverse_bytes puts data at MSB (e.g. 72 00 ... 00)
                    // We need it at LSB for SHAKE (e.g. 00 ... 72)
                    shake_din <= {512'b0, (reverse_bytes(msg) >> ((32 - msg_len) << 3)), prefix}; 
                    shake_len <= 7'd32 + msg_len; // prefix (32 bytes) + message length
                    
                    shake_type <= 3'd1; 
                    shake_start <= 1;
                    shake_wait_cnt <= 0;
                    state <= WAIT_MSG;
                end


                WAIT_MSG: begin
                    if (shake_wait_cnt < 4) shake_wait_cnt <= shake_wait_cnt + 1;
                    else if (shake_done) begin
                        // RFC 8032: r = hash(prefix || msg) mod L
                        reducer_start <= 1;
                        state <= REDUCE_R;
                    end
                end

                REDUCE_R: if (reducer_done) begin
                    r_nonce <= {3'b0, reducer_dout};
                    state <= GEN_SIG_R;
                end

                GEN_SIG_R: begin
                    sc_mult_start <= 1; // R = r_nonce * G
                    state <= WAIT_SIG_START;
                end
                
                WAIT_SIG_START: begin
                    sc_mult_start <= 0;
                    state <= INV_SIG_Z;
                end
                
                INV_SIG_Z: begin
                    if (sc_mult_done) begin
                         inv_din <= sc_mult_res_z;
                         inv_start <= 1;
                         state <= PREP_SIG_R;
                    end
                end
                
                PREP_SIG_R: if (inv_done) begin
                    // R_y = Y * Z^-1
                    z_inv_cache <= inv_dout; // Cache NEW Z^-1 for R
                    mul_a <= sc_mult_res_y;
                    mul_b <= inv_dout;
                    mul_start <= 1;
                    state <= CALC_SIG_R;
                end

                CALC_SIG_R: if (mul_done) begin
                    sig_r <= {1'b0, mul_res}; // Just Y initially
                    state <= PREP_SIG_X;
                end
                
                PREP_SIG_X: begin
                    // R_x = X * Z^-1
                    mul_a <= sc_mult_res_x;
                    mul_b <= z_inv_cache; // Use cached Z^-1 for R
                    mul_start <= 1;
                    state <= CALC_SIG_X;
                end

                CALC_SIG_X: if (mul_done) begin
                    sig_r[255] <= mul_res[0]; // Set sign bit
                    x_affine <= mul_res;
                    
                    // Hash k: k = hash(R || A || M)
                    // Input Order: {M, A, R}
                    // Reverse all components to ensure LSB-0 stream order
                    // Note: mul_res[0] is X-sign bit (bit 255 of R). 
                    // Hash k: k = hash(R || A || M)
                    // Input: {msg, A, R} -> but order in memory:
                    // shake_din LSB is R (sig_r).
                    // Then A (pub_key).
                    // Then msg.
                    // We need msg to be byte-correct LSB-first: "af 82".
                    // Current msg input (256'haf82) has 82 at LSB.
                    // So we must use the same fix: (reverse_bytes(msg) >> shift).
                    
                    shake_din <= {256'b0, (reverse_bytes(msg) >> ((32 - msg_len) << 3)), pub_key_y, mul_res[0], sig_r[254:0]}; 
                    shake_len <= 7'd64 + msg_len; // R (32) + A (32) + msg_len
                    shake_type <= 3'd1;
                    shake_start <= 1;
                    shake_wait_cnt <= 0;
                    state <= WAIT_K;
                end

                WAIT_K: begin
                    if (shake_wait_cnt < 4) shake_wait_cnt <= shake_wait_cnt + 1;
                    else if (shake_done) begin
                        // RFC 8032: k = hash(R || A || msg) mod L
                        reducer_start <= 1;
                        state <= REDUCE_K;
                    end
                end

                REDUCE_K: if (reducer_done) begin
                    k_hash <= {3'b0, reducer_dout};
                    mod_l_start <= 1;
                    state <= CALC_S;
                end

                CALC_S: begin
                    if (mod_l_done) begin
                        sig_s <= {3'b0, final_s};
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    done <= 1;
                    state <= FINISH_ZERO;
                end
                
                FINISH_ZERO: begin

                    // Zeroize sensitive data one cycle after done=1
                    // This allows testbench to read values before they're cleared
                    s_scalar <= 256'b0;
                    r_nonce <= 256'b0;
                    k_hash <= 256'b0;
                    prefix <= 256'b0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule