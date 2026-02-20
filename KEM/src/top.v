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
            //shake_start <= 0;

            if (dec_done && !shake_busy) begin
                // pack input for SHAKE
                shake_din <= {
                    {(1024-4*R){1'b0}},
                    e0, e1,
                    c0, c1
                };
                shake_start <= 1;
            end
        end
    end

    shake_top u_shake (
        .clk(clk),
        .rst(rst),
        .start(shake_start),
        .out_len_type(3'd1),     // 256-bit
        .mode(1'b1),             // SHAKE256
        .din(shake_din),
        .byte_len(7'd3),    // e0||e1||c0||c1
        .dout(shared_key),
        .done(shake_done),
        .busy(shake_busy)
    );

    assign done  = shake_done;

endmodule

/////////////////// TEST ////////////////////




// module tb_bike_top_simple;

//     // Match parameters
//     localparam R = 127;
//     localparam W = 5;
//     localparam POS_W = 8;

//     reg clk = 0;
//     always #5 clk = ~clk;   // 100 MHz

//     reg rst;
//     reg start;

//     reg [W*POS_W-1:0] h0_pos_flat;
//     reg [W*POS_W-1:0] h1_pos_flat;

//     reg [R-1:0] c0;
//     reg [R-1:0] c1;

//     wire [511:0] shared_key;
//     wire done;

//     // DUT
//     bike_top #(
//         .R(R),
//         .W(W),
//         .POS_W(POS_W)
//     ) dut (
//         .clk(clk),
//         .rst(rst),
//         .start(start),
//         .h0_pos_flat(h0_pos_flat),
//         .h1_pos_flat(h1_pos_flat),
//         .c0(c0),
//         .c1(c1),
//         .shared_key(shared_key),
//         .done(done)
//     );

//     // always @(posedge clk) begin
//     //     $display("time = %0t", $time);
//     //     $display("done = %b", done);
//     //     $display("syndrome_done = %b", dut.done_syndrome);
//     //     $display("e0 = %b", dut.e0);
//     //     $display("dec_done = %b", dut.dec_done);
//     //     $display("shake_done = %b", dut.shake_done);
//     //     $display("===========================");
//     // end
    
//     initial begin
//         // Reset
//         rst = 1;
//         start = 0;
//         h0_pos_flat = 0;
//         h1_pos_flat = 0;
//         c0 = 0;
//         c1 = 0;

//         #20;
//         rst = 0;

//         // Dummy input
//         h0_pos_flat = 40'h01_02_03_04_05;
//         h1_pos_flat = 40'h06_07_08_09_0A;

//         c0 = 127'h1234;
//         c1 = 127'h5678;

//         // Start pulse
//         #10;
//         start = 1;
//         #10;
//         start = 0;

//         // Wait done
//         //repeat(1600) @(posedge clk);
//         wait(dut.shake_done);
//         //dec done = 1 ở 15385
//         //shake start = 1 ở 15385
//         //lỗi chỗ shake_busy ko bao gio bang 1
//         //sponge kẹc ở reset
//         //vấn đề ở negedge rst của shake

//         //spone_state ở sponge ra 0



//         // $display("time = %0t", $time);
//         // $display("done = %b", done);
//         // $display("syndrome_done = %b", dut.done_syndrome);
//         // $display("shake in = %h", dut.shake_din);
//         // $display("dec_done = %b", dut.dec_done);
//         //$display("shared_key = %b", dut.shared_key);
//         $display("===========================");
        

//         $display("Shared key = %h", shared_key);

//         #20;
//         $finish;
//     end

// endmodule