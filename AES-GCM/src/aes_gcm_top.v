`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: aes_gcm_top
// Description: AES-256-GCM Encrypt / Decrypt (NIST SP 800-38D)
//              Key:        256 bit
//              Nonce:       96 bit
//              Plaintext:  512 bit (4 x 128-bit blocks)
//              AAD:        160 bit
//              Ciphertext: 512 bit (4 x 128-bit blocks)
//              Tag:        128 bit
//////////////////////////////////////////////////////////////////////////////////

module aes_gcm_top(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire        mode,            // NEW: 0 = encrypt, 1 = decrypt
    input  wire [255:0] key,
    input  wire [95:0]  nonce,
    input  wire [127:0] plaintext1,
    input  wire [127:0] plaintext2,
    input  wire [127:0] plaintext3,
    input  wire [127:0] plaintext4,
    input  wire [159:0] aad,
    input  wire [127:0] tag_received,   // NEW: tag nhan duoc (dung khi decrypt)

    output reg  [127:0] ciphertext1,
    output reg  [127:0] ciphertext2,
    output reg  [127:0] ciphertext3,
    output reg  [127:0] ciphertext4,
    output reg  [127:0] tag,
    output reg         done,
    output reg         tag_match        // NEW: 1 = tag hop le (dung khi decrypt)
);

    localparam IDLE        = 4'd0;
    localparam COMPUTE_H   = 4'd1;
    localparam COMPUTE_Y0  = 4'd2;
    localparam COMPUTE_Y1  = 4'd3;
    localparam COMPUTE_Y2  = 4'd4;
    localparam COMPUTE_Y3  = 4'd5;
    localparam COMPUTE_Y4  = 4'd6;
    localparam GHASH_AAD1  = 4'd7;
    localparam GHASH_AAD2  = 4'd8;
    localparam GHASH_CT1   = 4'd9;
    localparam GHASH_CT2   = 4'd10;
    localparam GHASH_CT3   = 4'd11;
    localparam GHASH_CT4   = 4'd12;
    localparam GHASH_LEN   = 4'd13;
    localparam FINALIZE    = 4'd14;
    localparam DONE_STATE  = 4'd15;

    reg [3:0] state;
    reg [127:0] h_key;
    reg [127:0] tag_mask;
    reg [127:0] ct1_temp, ct2_temp, ct3_temp, ct4_temp;
    reg [127:0] ghash_accumulator;
    reg mode_reg;                       // NEW: latch mode khi start

    wire [127:0] aad_block1 = aad[159:32];
    wire [127:0] aad_block2 = {aad[31:0], 96'h0};
    wire [127:0] len_block  = {64'd160, 64'd512};

    // NEW: GHASH can ciphertext - khi decrypt, ciphertext la INPUT (plaintext port)
    //      khi encrypt, ciphertext la OUTPUT (ct_temp sau XOR)
    wire [127:0] ghash_ct1 = mode_reg ? plaintext1 : ct1_temp;
    wire [127:0] ghash_ct2 = mode_reg ? plaintext2 : ct2_temp;
    wire [127:0] ghash_ct3 = mode_reg ? plaintext3 : ct3_temp;
    wire [127:0] ghash_ct4 = mode_reg ? plaintext4 : ct4_temp;

    reg         aes_start;
    reg         aes_issued;
    wire        aes_done;
    wire        aes_busy;
    reg  [127:0] aes_in;
    wire [127:0] aes_out;

    aes_encr aes_shared (
        .clk   (clk),
        .rst   (rst),
        .start (aes_start),
        .in    (aes_in),
        .key   (key),
        .out   (aes_out),
        .done  (aes_done),
        .busy  (aes_busy)
    );

    reg         ghash_start;
    reg         ghash_issued;
    wire        ghash_done;

    reg  [127:0] ghash_data;
    reg  [127:0] ghash_prev;
    wire [127:0] ghash_out;

    ghash ghash_shared (
        .clk     (clk),
        .rst     (rst),
        .start   (ghash_start),
        .data_in (ghash_data),
        .h_key   (h_key),
        .y_prev  (ghash_prev),
        .done    (ghash_done),
        .y_out   (ghash_out)
    );

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            done  <= 0;
            tag_match <= 0;             // NEW

            aes_start  <= 0;
            aes_issued <= 0;
            ghash_start  <= 0;
            ghash_issued <= 0;

            ciphertext1 <= 0;
            ciphertext2 <= 0;
            ciphertext3 <= 0;
            ciphertext4 <= 0;
            tag         <= 0;
            mode_reg    <= 0;           // NEW

            // Full initialization of all internal registers
            aes_in      <= 128'd0;
            h_key       <= 128'd0;
            tag_mask    <= 128'd0;
            ct1_temp    <= 128'd0;
            ct2_temp    <= 128'd0;
            ct3_temp    <= 128'd0;
            ct4_temp    <= 128'd0;
            ghash_data  <= 128'd0;
            ghash_prev  <= 128'd0;
            ghash_accumulator <= 128'd0;

        end else begin
            aes_start   <= 0;
            ghash_start <= 0;
            done        <= 0;

            case (state)

            IDLE: begin
                if (start) begin
                    aes_in <= 128'h0;
                    aes_issued <= 0;
                    mode_reg <= mode;   // NEW: latch mode
                    tag_match <= 0;     // NEW: reset
                    state <= COMPUTE_H;
                end
            end

            COMPUTE_H: begin
                if (!aes_issued && !aes_busy) begin
                    aes_start  <= 1;
                    aes_issued <= 1;
                end
                if (aes_done) begin
                    h_key <= aes_out;
                    aes_issued <= 0;
                    aes_in <= {nonce, 32'd1};
                    state <= COMPUTE_Y0;
                end
            end

            COMPUTE_Y0: begin
                if (!aes_issued && !aes_busy) begin
                    aes_start <= 1;
                    aes_issued <= 1;
                end
                if (aes_done) begin
                    tag_mask <= aes_out;
                    aes_issued <= 0;
                    aes_in <= {nonce, 32'd2};
                    state <= COMPUTE_Y1;
                end
            end

            COMPUTE_Y1: begin
                if (!aes_issued && !aes_busy) begin
                    aes_start <= 1;
                    aes_issued <= 1;
                end
                if (aes_done) begin
                    ct1_temp <= plaintext1 ^ aes_out;
                    aes_issued <= 0;
                    aes_in <= {nonce, 32'd3};
                    state <= COMPUTE_Y2;
                end
            end

            COMPUTE_Y2: begin
                if (!aes_issued && !aes_busy) begin
                    aes_start <= 1;
                    aes_issued <= 1;
                end
                if (aes_done) begin
                    ct2_temp <= plaintext2 ^ aes_out;
                    aes_issued <= 0;
                    aes_in <= {nonce, 32'd4};
                    state <= COMPUTE_Y3;
                end
            end

            COMPUTE_Y3: begin
                if (!aes_issued && !aes_busy) begin
                    aes_start <= 1;
                    aes_issued <= 1;
                end
                if (aes_done) begin
                    ct3_temp <= plaintext3 ^ aes_out;
                    aes_issued <= 0;
                    aes_in <= {nonce, 32'd5};
                    state <= COMPUTE_Y4;
                end
            end

            COMPUTE_Y4: begin
                if (!aes_issued && !aes_busy) begin
                    aes_start <= 1;
                    aes_issued <= 1;
                end
                if (aes_done) begin
                    ct4_temp <= plaintext4 ^ aes_out;
                    aes_issued <= 0;

                    ghash_data <= aad_block1;
                    ghash_prev <= 128'h0;
                    ghash_issued <= 0;
                    state <= GHASH_AAD1;
                end
            end

            GHASH_AAD1,
            GHASH_AAD2,
            GHASH_CT1,
            GHASH_CT2,
            GHASH_CT3,
            GHASH_CT4,
            GHASH_LEN: begin

                if (!ghash_issued) begin
                    ghash_start  <= 1;
                    ghash_issued <= 1;
                end

                if (ghash_done) begin
                    ghash_accumulator <= ghash_out;
                    ghash_prev <= ghash_out;
                    ghash_issued <= 0;

                    case (state)
                        GHASH_AAD1: begin
                            ghash_data <= aad_block2;
                            state <= GHASH_AAD2;
                        end
                        GHASH_AAD2: begin
                            ghash_data <= ghash_ct1;    // NEW: dung MUX thay vi ct1_temp
                            state <= GHASH_CT1;
                        end
                        GHASH_CT1: begin
                            ghash_data <= ghash_ct2;    // NEW: dung MUX
                            state <= GHASH_CT2;
                        end
                        GHASH_CT2: begin
                            ghash_data <= ghash_ct3;    // NEW: dung MUX
                            state <= GHASH_CT3;
                        end
                        GHASH_CT3: begin
                            ghash_data <= ghash_ct4;    // NEW: dung MUX
                            state <= GHASH_CT4;
                        end
                        GHASH_CT4: begin
                            ghash_data <= len_block;
                            state <= GHASH_LEN;
                        end
                        GHASH_LEN: begin
                            state <= FINALIZE;
                        end
                    endcase
                end
            end

            FINALIZE: begin
                ciphertext1 <= ct1_temp;
                ciphertext2 <= ct2_temp;
                ciphertext3 <= ct3_temp;
                ciphertext4 <= ct4_temp;
                tag <= ghash_accumulator ^ tag_mask;
                // NEW: so sanh tag khi decrypt
                tag_match <= (mode_reg) ? ((ghash_accumulator ^ tag_mask) == tag_received) : 1'b1;
                state <= DONE_STATE;
            end

            DONE_STATE: begin
                done <= 1;
                if (!start)
                    state <= IDLE;
            end

            endcase
        end
    end
endmodule
