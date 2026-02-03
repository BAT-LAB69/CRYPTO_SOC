`timescale 1ns/1ps

module top(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [255:0] seed, //private key 32 bytes
    input wire [255:0] msg, //message 32 bytes

    output reg [255:0] sig_r, //signature R 32 bytes
    output reg [255:0] sig_s, //signature S 32 bytes
    output reg done,
    output wire busy,

    // SHAKE128 interface
    output reg shake_start,
    output reg [2:0] shake_type, // 0: 256bit, 1: 512bit
    output reg [511:0] shake_din,
    input wire [511:0] shake_dout,
    input wire shake_done
);
    
    reg [255:0] pub_key_y;
    reg [255:0] s_scalar; // S_scalar sau khi clamp
    reg [255:0] prefix;   // prefix from hash(seed)
    
    reg [255:0] k_hash;
    reg [255:0] r_nonce;

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
    localparam [254:0] G_X = 255'h1a452a126a4647c81d3d9691b567d2876644f10730101d6801b7a26f631069b0;
    localparam [254:0] G_Y = 255'h5866666666666666666666666666666666666666666666666666666666666666;

    // Internal Top FSM
    typedef enum reg [4:0] {
        IDLE        = 5'd0,
        HASH_SEED   = 5'd1,
        WAIT_SEED   = 5'd2,
        GEN_PUBKEY  = 5'd3,
        INV_PUB_Z   = 5'd4,
        PREP_PUB_Y  = 5'd5,
        CALC_PUB_Y  = 5'd6,
        HASH_MSG    = 5'd7,
        WAIT_MSG    = 5'd8,
        REDUCE_R    = 5'd9,
        GEN_SIG_R   = 5'd10,
        INV_SIG_Z   = 5'd11,
        PREP_SIG_R  = 5'd12,
        CALC_SIG_R  = 5'd13,
        HASH_K      = 5'd14,
        WAIT_K      = 5'd15,
        REDUCE_K    = 5'd16,
        CALC_S      = 5'd17,
        FINISH      = 5'd18
    } state_t;

    state_t state;
    assign busy = (state != IDLE);

    // Mux for scalar multiplication input
    // When generating Public Key: Use s_scalar
    // When generating Signature R: Use r_nonce
    wire [255:0] current_scalar;
    assign current_scalar = (state == GEN_SIG_R || state == INV_SIG_Z || state == PREP_SIG_R || state == CALC_SIG_R) ? r_nonce : s_scalar;

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

    wire [254:0] multiplicated_t = 255'h67875f0fd78b766566ea4e8e64abe37d20f09f80775152f56dde8ab3a5b7dda3;

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
                        shake_din <= {256'b0, seed};
                        shake_type <= 3'd1; // 512-bit output required for Ed25519 (32-byte s, 32-byte prefix)
                        shake_start <= 1;
                        state <= WAIT_SEED;
                    end
                end

                WAIT_SEED: begin
                    if (shake_done) begin
                        s_scalar <= shake_dout[255:0];
                        // Ed25519 key clamping: clear bottom 3 bits, clear top bit, set bit 254
                        s_scalar[7:0] <= shake_dout[7:0] & 8'hf8;    // Clear bottom 3 bits
                        s_scalar[255:254] <= (shake_dout[255:240] & 16'h7fff) | 16'h4000; // Bit 254 set
                        
                        prefix <= shake_dout[511:256];
                        state <= GEN_PUBKEY;
                    end
                end

                GEN_PUBKEY: begin
                    sc_mult_start <= 1; // start P = scalar * G
                    state <= INV_PUB_Z; 
                end

                INV_PUB_Z: begin
                    if (sc_mult_done) begin
                        inv_din <= sc_mult_res_z;  
                        inv_start <= 1;           
                        state <= PREP_PUB_Y;
                    end
                end
                
                PREP_PUB_Y: if (inv_done) begin
                    // y = Y * Z^-1
                    mul_a <= sc_mult_res_y; 
                    mul_b <= inv_dout;      
                    mul_start <= 1;
                    state <= CALC_PUB_Y;
                end


                CALC_PUB_Y: if (mul_done) begin
                    pub_key_y <= mul_res;
                    // Hash msg: R = hash(prefix || msg)
                    // Wait, RFC says we need r = hash(prefix || msg) to form R
                    // Then pub_key is needed for later: k = hash(R || A || M)
                    shake_din <= {prefix, msg}; 
                    shake_type <= 3'd1; // 512 bit output for r
                    shake_start <= 1;
                    state <= WAIT_MSG;
                end

                WAIT_MSG: if (shake_done) begin
                    // RFC 8032: r = hash(prefix || msg) mod L
                    reducer_start <= 1;
                    state <= REDUCE_R;
                end

                REDUCE_R: if (reducer_done) begin
                    r_nonce <= {3'b0, reducer_dout};
                    state <= GEN_SIG_R;
                end

                GEN_SIG_R: begin
                    sc_mult_start <= 1; // R = r_nonce * G
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
                    mul_a <= sc_mult_res_y;
                    mul_b <= inv_dout;
                    mul_start <= 1;
                    state <= CALC_SIG_R;
                end

                CALC_SIG_R: if (mul_done) begin
                    sig_r <= mul_res;
                    shake_din <= {pub_key_y, mul_res}; // pub_key || R
                    shake_type <= 3'd1;
                    shake_start <= 1;
                    state <= WAIT_K;
                end

                WAIT_K: if (shake_done) begin
                    // RFC 8032: k = hash(R || A || msg) mod L
                    reducer_start <= 1;
                    state <= REDUCE_K;
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
                    // Zeroize sensitive
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