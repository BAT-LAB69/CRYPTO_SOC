`include "aes_gcm_top.v"  
`include "ed25519_top.v"
`include "shake_top.v"
`include "bike_top.v"
`include "rsa.v"

module aes_gcm_mm #(
    parameter BASE_ADDR = 32'h4000_0000
)(
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        we,
    input  wire        valid,
    output reg  [31:0] rdata,
    output reg         ready
);

    wire sel = (addr[31:12] == BASE_ADDR[31:12]);

    reg start_reg;

    reg [255:0] key_reg;
    reg [95:0]  nonce_reg;
    reg [127:0] pt1_reg, pt2_reg, pt3_reg;
    reg [223:0] aad_reg;

    wire [127:0] ct1, ct2, ct3, tag;
    wire done;

    always @(posedge clk) begin
        ready <= 0;

        if(valid && sel) begin
            ready <= 1;

            if(we) begin
                case(addr[11:0])

                    12'h000: start_reg <= wdata[0];

                    // KEY (8 words)
                    12'h008: key_reg[31:0]   <= wdata;
                    12'h00C: key_reg[63:32]  <= wdata;
                    12'h010: key_reg[95:64]  <= wdata;
                    12'h014: key_reg[127:96] <= wdata;
                    12'h018: key_reg[159:128]<= wdata;
                    12'h01C: key_reg[191:160]<= wdata;
                    12'h020: key_reg[223:192]<= wdata;
                    12'h024: key_reg[255:224]<= wdata;

                    default: ;
                endcase
            end else begin
                case(addr[11:0])
                    12'h004: rdata <= {31'b0, done};

                    // Ciphertext1
                    12'h100: rdata <= ct1[31:0];
                    12'h104: rdata <= ct1[63:32];
                    12'h108: rdata <= ct1[95:64];
                    12'h10C: rdata <= ct1[127:96];

                    default: rdata <= 0;
                endcase
            end
        end
    end

    aes_gcm_top core (
        .clk(clk),
        .rst(rst),
        .start(start_reg),
        .key(key_reg),
        .nonce(nonce_reg),
        .plaintext1(pt1_reg),
        .plaintext2(pt2_reg),
        .plaintext3(pt3_reg),
        .aad(aad_reg),
        .ciphertext1(ct1),
        .ciphertext2(ct2),
        .ciphertext3(ct3),
        .tag(tag),
        .done(done)
    );

endmodule

module ed25519_shake128_mm #(
    parameter BASE_ADDR = 32'h4000_1000
)(
    input  wire        clk,
    input  wire        rst,

    // Simple 32-bit memory mapped bus
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        we,
    input  wire        valid,
    output reg  [31:0] rdata,
    output reg         ready
);

    // Address select (4KB region)
    wire sel = (addr[31:12] == BASE_ADDR[31:12]);


    reg start_reg;

    reg [255:0] seed_reg;
    reg [255:0] msg_reg;
    reg [6:0]   msg_len_reg;

    wire [255:0] sig_r;
    wire [255:0] sig_s;
    wire done;
    wire busy;

    // Auto clear start after 1 cycle
    always @(posedge clk or posedge rst) begin
        if (rst)
            start_reg <= 0;
        else if (start_reg)
            start_reg <= 0;
    end

    // ======================================================
    // Bus Access
    // ======================================================

    always @(posedge clk) begin
        ready <= 0;

        if(valid && sel) begin
            ready <= 1;

            if(we) begin
                case(addr[11:0])

                    // CTRL
                    12'h000: start_reg <= wdata[0];

                    // =====================
                    // SEED (8 words)
                    // =====================
                    12'h008: seed_reg[31:0]    <= wdata;
                    12'h00C: seed_reg[63:32]   <= wdata;
                    12'h010: seed_reg[95:64]   <= wdata;
                    12'h014: seed_reg[127:96]  <= wdata;
                    12'h018: seed_reg[159:128] <= wdata;
                    12'h01C: seed_reg[191:160] <= wdata;
                    12'h020: seed_reg[223:192] <= wdata;
                    12'h024: seed_reg[255:224] <= wdata;

                    // =====================
                    // MSG (8 words)
                    // =====================
                    12'h040: msg_reg[31:0]    <= wdata;
                    12'h044: msg_reg[63:32]   <= wdata;
                    12'h048: msg_reg[95:64]   <= wdata;
                    12'h04C: msg_reg[127:96]  <= wdata;
                    12'h050: msg_reg[159:128] <= wdata;
                    12'h054: msg_reg[191:160] <= wdata;
                    12'h058: msg_reg[223:192] <= wdata;
                    12'h05C: msg_reg[255:224] <= wdata;

                    // MSG LEN
                    12'h060: msg_len_reg <= wdata[6:0];

                    default: ;
                endcase
            end
            else begin
                case(addr[11:0])

                    // STATUS
                    12'h004: rdata <= {30'b0, busy, done};

                    // =====================
                    // SIG_R (8 words)
                    // =====================
                    12'h100: rdata <= sig_r[31:0];
                    12'h104: rdata <= sig_r[63:32];
                    12'h108: rdata <= sig_r[95:64];
                    12'h10C: rdata <= sig_r[127:96];
                    12'h110: rdata <= sig_r[159:128];
                    12'h114: rdata <= sig_r[191:160];
                    12'h118: rdata <= sig_r[223:192];
                    12'h11C: rdata <= sig_r[255:224];

                    // =====================
                    // SIG_S (8 words)
                    // =====================
                    12'h140: rdata <= sig_s[31:0];
                    12'h144: rdata <= sig_s[63:32];
                    12'h148: rdata <= sig_s[95:64];
                    12'h14C: rdata <= sig_s[127:96];
                    12'h150: rdata <= sig_s[159:128];
                    12'h154: rdata <= sig_s[191:160];
                    12'h158: rdata <= sig_s[223:192];
                    12'h15C: rdata <= sig_s[255:224];

                    default: rdata <= 32'h0;
                endcase
            end
        end
    end

    ed25519_shake128 core (
        .clk(clk),
        .rst_n(~rst),
        .start(start_reg),
        .seed(seed_reg),
        .msg(msg_reg),
        .msg_len(msg_len_reg),
        .sig_r(sig_r),
        .sig_s(sig_s),
        .done(done),
        .busy(busy)
    );

endmodule

module bike_mm #(
    parameter BASE_ADDR = 32'h4000_2000,
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8
)(
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        we,
    input  wire        valid,
    output reg  [31:0] rdata,
    output reg         ready
);

    // ======================================================
    // Local parameters
    // ======================================================

    localparam C_WORDS = (R + 31) / 32;   // number of 32-bit words
    localparam KEY_WORDS = 16;            // 512-bit shared_key

    wire sel = (addr[31:12] == BASE_ADDR[31:12]);

    // ======================================================
    // Registers
    // ======================================================

    reg start_reg;

    reg [W*POS_W-1:0] h0_reg;
    reg [W*POS_W-1:0] h1_reg;

    reg [R-1:0] c0_reg;
    reg [R-1:0] c1_reg;

    wire [511:0] shared_key;
    wire done;

    integer i;


    always @(posedge clk or posedge rst) begin
        if (rst)
            start_reg <= 1'b0;
        else if (start_reg)
            start_reg <= 1'b0;
    end

   
    always @(posedge clk) begin
        ready <= 1'b0;
        rdata <= 32'h0;

        if (valid && sel) begin
            ready <= 1'b1;

            // ================= WRITE =================
            if (we) begin
                case (addr[11:0])

                    // CTRL
                    12'h000: start_reg <= wdata[0];

                    default: begin

                        // H0 positions
                        for (i = 0; i < W; i = i + 1)
                            if (addr[11:0] == (12'h008 + i*4))
                                h0_reg[i*POS_W +: POS_W] <= wdata[POS_W-1:0];

                        // H1 positions
                        for (i = 0; i < W; i = i + 1)
                            if (addr[11:0] == (12'h020 + i*4))
                                h1_reg[i*POS_W +: POS_W] <= wdata[POS_W-1:0];

                        // C0 polynomial
                        for (i = 0; i < C_WORDS; i = i + 1)
                            if (addr[11:0] == (12'h040 + i*4))
                                c0_reg[i*32 +: 32] <= wdata;

                        // C1 polynomial
                        for (i = 0; i < C_WORDS; i = i + 1)
                            if (addr[11:0] == (12'h080 + i*4))
                                c1_reg[i*32 +: 32] <= wdata;

                    end
                endcase
            end

            // ================= READ =================
            else begin
                case (addr[11:0])

                    12'h004: rdata <= {31'b0, done};

                    default: begin

                        // Read shared key
                        for (i = 0; i < KEY_WORDS; i = i + 1)
                            if (addr[11:0] == (12'h100 + i*4))
                                rdata <= shared_key[i*32 +: 32];

                    end
                endcase
            end
        end
    end


    bike_top #(
        .R(R),
        .W(W),
        .POS_W(POS_W)
    ) core (
        .clk(clk),
        .rst(rst),
        .start(start_reg),
        .h0_pos_flat(h0_reg),
        .h1_pos_flat(h1_reg),
        .c0(c0_reg),
        .c1(c1_reg),
        .shared_key(shared_key),
        .done(done)
    );

endmodule


module rsa_mm #(
    parameter BASE_ADDR = 32'h4000_3000,
    parameter WIDTH     = 32,
    parameter E_BITS    = 32
)(
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        we,
    input  wire        valid,
    output reg  [31:0] rdata,
    output reg         ready
);

    wire sel = (addr[31:12] == BASE_ADDR[31:12]);


    reg start_reg;

    reg [WIDTH-1:0]  M_reg;
    reg [E_BITS-1:0] E_reg;
    reg [WIDTH-1:0]  N_reg;
    reg [WIDTH-1:0]  N_INV_reg;
    reg [WIDTH-1:0]  R2_reg;

    wire [WIDTH-1:0] C_wire;
    wire done_wire;

    // Optional: latch done to avoid missing short pulse
    reg done_reg;

  
    always @(posedge clk or posedge rst) begin
        if (rst)
            start_reg <= 1'b0;
        else if (start_reg)
            start_reg <= 1'b0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            done_reg <= 1'b0;
        else begin
            if (done_wire)
                done_reg <= 1'b1;
            else if (valid && sel && !we && addr[11:0] == 12'h004)
                done_reg <= 1'b0;  // clear when STATUS is read
        end
    end

  
    always @(posedge clk) begin
        ready <= 1'b0;
        rdata <= 32'h0;

        if (valid && sel) begin
            ready <= 1'b1;

            // ================= WRITE =================
            if (we) begin
                case (addr[11:0])

                    12'h000: start_reg <= wdata[0];
                    12'h008: M_reg     <= wdata;
                    12'h00C: E_reg     <= wdata;
                    12'h010: N_reg     <= wdata;
                    12'h014: N_INV_reg <= wdata;
                    12'h018: R2_reg    <= wdata;

                    default: ;
                endcase
            end

            // ================= READ =================
            else begin
                case (addr[11:0])

                    12'h004: rdata <= {31'b0, done_reg};
                    12'h100: rdata <= C_wire;

                    default: rdata <= 32'h0;
                endcase
            end
        end
    end

    rsa #(
        .WIDTH(WIDTH),
        .E_BITS(E_BITS)
    ) core (
        .clk(clk),
        .rst(rst),
        .start(start_reg),
        .M(M_reg),
        .E(E_reg),
        .N(N_reg),
        .N_INV(N_INV_reg),
        .R2_MOD_N(R2_reg),
        .C(C_wire),
        .done(done_wire)
    );

endmodule