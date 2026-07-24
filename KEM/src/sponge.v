`timescale 1ps/1ps  
`include "keccak.v"

module sponge(
    input wire clk,
    input wire rst,

    input wire [1023:0] din, 
    input wire [6:0] byte_len, // Length matches ed25519 requirement
    input wire i_valid,
    input wire i_last, 
    input wire mode, // 0: SHAKE128, 1: SHAKE256
    output reg i_ack, 
    
    output reg [511:0] dout,
    output reg done,
    output wire busy
);

    // Dynamic RATE based on mode
    // SHAKE128: Rate = 1344
    // SHAKE256: Rate = 1088
    wire [10:0] Rate_bits;
    assign Rate_bits = (mode == 1'b1) ? 11'd1088 : 11'd1344;

    localparam STATE_SIZE = 1600;


    localparam IDLE = 3'd0;
    localparam ABSORB = 3'd1; //XOR
    localparam PADDING = 3'd2; //add suffix 111 and padding 10*1
    localparam PERMUTE = 3'd3; //24 loop permute
    localparam SQUEEZE = 3'd4; //data out

    reg [2:0] state;
    reg [STATE_SIZE-1:0] sponge_state;
    reg[1023:0] buffer_in;
    reg [6:0] saved_len;
    reg saved_mode; // Latch mode at start

    reg f_start;
    wire f_done;
    wire f_busy;
    wire [STATE_SIZE-1:0] f_out;

    keccak_f1600 f_inst(
        .clk(clk),
        .rst(rst),
        .start(f_start),
        .in_state(sponge_state),
        .out_state(f_out),
        .done(f_done),
        .busy(f_busy)
    );

    assign busy = (state != IDLE);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            sponge_state <= 1600'd0;
            buffer_in <= 1024'd0;
            dout <= 512'd0;
            done <= 1'b0;
            i_ack <= 1'b0;
            f_start <= 1'b0;
            saved_mode <= 0;
            
        end else begin
            f_start <= 1'b0;
            i_ack <= 1'b0;
            case (state)
                IDLE: begin
                    if (i_valid) begin
                        buffer_in <= din;
                        saved_len <= byte_len;
                        saved_mode <= mode; // Latch mode
                        sponge_state <= 0;
                        i_ack <= 1'b1;
                        done <= 1'b0; // Clear done
                        state <= ABSORB;
                    end
                end
                ABSORB: begin
                    //XOR input data w r first bits of state
                    sponge_state[1023:0] <= sponge_state[1023:0] ^ buffer_in;
                    //$display("ABSORB: sponge_state[1023:0] = %h", sponge_state[1023:0]);
                    if (i_last) begin
                        state <= PADDING;
                    end else begin
                        f_start <= 1'b1;
                        state <= PERMUTE;
                    end
                end
                PADDING: begin
                    //bit index = saved_len * 8
                    // We need to XOR 0x1F starting at this index
                    // sponge_state[idx +: 8] ...
                    // Since 0x1F is 5 bits 11111.
                    //$display("PADDING: Applying padding at bit index %d", saved_len*8);
                    sponge_state[saved_len*8 +: 5] <= sponge_state[saved_len*8 +: 5] ^ 5'b11111;
                    // Padding rule: pad10*1
                    // XOR 0x80 (highest bit) at the end of the rate block
                    // For SHAKE128: bit 1343
                    // For SHAKE256: bit 1087
                    if (saved_mode == 1'b1) begin
                        // SHAKE256
                        sponge_state[1087] <= sponge_state[1087] ^ 1'b1;
                    end else begin
                        // SHAKE128
                        sponge_state[1343] <= sponge_state[1343] ^ 1'b1;
                    end
                    
                    f_start <= 1'b1;
                    state <= PERMUTE;
                end
                PERMUTE: begin
                    if (f_done) begin
                        sponge_state <= f_out;
                        //$display("PERMUTE: Permutation done");
                        if (done == 0) begin
                            state <= SQUEEZE;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end
                SQUEEZE: begin
                    //512<1088 (min rate) -> we can take direct data after 1 time permute 
                    //$display("SQUEEZE: Outputting hash");

                    // chỗ này
                    dout = sponge_state[511:0];
                    done <= 1;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule


///////////// TEST /////////////////


// module tb_sponge;

//     // Clock / Reset
//     reg clk = 0;
//     reg rst = 1;

//     always #5 clk = ~clk;   // 100MHz

//     // Inputs
//     reg  [1023:0] din;
//     reg  [6:0]    byte_len;
//     reg           i_valid;
//     reg           i_last;
//     reg           mode;

//     // Outputs
//     wire [511:0] dout;
//     wire done;
//     wire busy;
//     wire i_ack;

//     // Instantiate DUT
//     sponge dut (
//         .clk(clk),
//         .rst(rst),
//         .din(din),
//         .byte_len(byte_len),
//         .i_valid(i_valid),
//         .i_last(i_last),
//         .mode(mode),
//         .i_ack(i_ack),
//         .dout(dout),
//         .done(done),
//         .busy(busy)
//     );

//     initial begin
//         // Reset
//         #10 rst = 0;

//         // Gửi dữ liệu "abc"
//         #10;
//         din      = 0;
//         din[23:0]= 24'h636261;  // little-endian "abc"
//         byte_len = 3;
//         mode     = 1;           // SHAKE128
//         i_last   = 1;
//         i_valid  = 1;

//         #10;
//         i_valid = 0;

//         // Đợi kết quả
//         wait(done);

//         $display("DONE!");
//         $display("Output = %h", dout);

//         #20;
//         $finish;
//     end

// endmodule