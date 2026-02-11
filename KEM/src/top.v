`include "bit_flip_dec.v"
`include "shake_top.v"
`include "syndrome.v"

/*
Kiến trúc chuẩn (hardware):
            c0,c1
              │
              ▼
        syndrome compute
              │
              ▼
     bit-flipping decoder
          │        │
          │        └─ success (ra wrapper)
          ▼
        e0,e1
          │
          ▼
      SHAKE256 KDF
          │
          ▼
      shared_key

*/


module bike_top #(
    parameter R = 127,
    parameter W = 5,
    parameter POS_W = 8,
    parameter MAX_IT = 10,
    parameter THRESHOLD = 2
)(
    input  wire           clk,
    input  wire           rst,
    input  wire           start,

    input  wire [W*POS_W-1:0] h0_pos_flat,
    input  wire [W*POS_W-1:0] h1_pos_flat,

    input  wire [R-1:0]   c0,
    input  wire [R-1:0]   c1,

    output wire [255:0]   shared_key,
    output wire           done
);

    // =====================================================
    // Internal signals
    // =====================================================
    wire [R-1:0] syndrome;
    wire done_syndrome;

    wire [R-1:0] e0, e1;
    wire dec_done;
    wire dec_success;

    reg  shake_start;
    wire shake_done;
    wire shake_busy;

    reg [1023:0] shake_din;

    // =====================================================
    // Syndrome
    // =====================================================
    syndrome #(
        .R(R), .W(W), .POS_W(POS_W)
    ) u_syndrome (
        .clk(clk),
        .rst(rst),
        .start(start),
        .c0(c0),
        .c1(c1),
        .h0_pos_flat(h0_pos_flat),
        .h1_pos_flat(h1_pos_flat),
        .s(syndrome),
        .done(done_syndrome)
    );

    // =====================================================
    // Bit-flipping decoder
    // =====================================================
    bit_flipping_decoder #(
        .R(R), .W(W), .POS_W(POS_W),
        .MAX_IT(MAX_IT), .THRESHOLD(THRESHOLD)
    ) u_decoder (
        .clk(clk),
        .rst(rst),
        .start(done_syndrome),
        .s_in(syndrome),
        .h0_pos_flat(h0_pos_flat),
        .h1_pos_flat(h1_pos_flat),
        .e0(e0),
        .e1(e1),
        .done(dec_done),
        .success(dec_success)
    );

    // =====================================================
    // SHAKE256 (KDF)
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shake_start <= 0;
            shake_din   <= 0;
        end else begin
            shake_start <= 0;

            if (dec_done && !shake_busy) begin
                // pack input for SHAKE
                shake_din <= {
                    e0, e1,
                    c0, c1,
                    {(1024-4*R){1'b0}}
                };
                shake_start <= 1;
            end
        end
    end

    shake_top u_shake (
        .clk(clk),
        .rst(rst),
        .start(shake_start),
        .out_len_type(3'd0),     // 256-bit
        .mode(1'b1),             // SHAKE256
        .din(shake_din),
        .byte_len((4*R+7)/8),    // e0||e1||c0||c1
        .dout(shared_key),
        .done(shake_done),
        .busy(shake_busy)
    );

    assign done = shake_done;

endmodule

