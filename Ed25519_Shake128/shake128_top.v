`timescale 1ns/1ps


module shake128_top(
    input wire clk,
    input wire rst,

    input wire start,
    input wire [2:0] mode, //0: 256-bit output, 1:512-bit output
    input wire [1023:0] din,
    input wire [6:0] byte_len, // Added for dynamic padding

    output wire [511:0] dout,
    output wire done,
    output wire busy
);

    reg i_valid;
    reg i_last;
    wire i_ack;
    wire sponge_done;
    wire [511:0] sponge_dout;


    localparam IDLE = 2'd0;
    localparam START_ABS = 2'd1; //start absorb
    localparam WAIT_DONE = 2'd2;

    reg [1:0] state;

    
    sponge sponge_inst(
        .clk(clk),
        .rst(rst),
        .din(din),
        .byte_len(byte_len),
        .i_valid(i_valid),
        .i_last(i_last),
        .i_ack(i_ack),
        .dout(sponge_dout),
        .done(sponge_done),
        .busy(busy)
    );

    //ed25519 require both 256bit & 512bit tuy giai doan
    assign dout = (mode == 3'd0) ? {256'b0, sponge_dout[255:0]} : sponge_dout;
    assign done = sponge_done;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            i_valid <= 1'b0;
            i_last <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        i_valid <= 1'b1;
                        i_last <= 1'b1;
                        state <= START_ABS;
                    end
                end
                START_ABS: begin
                    if (i_ack) begin
                        i_valid <= 1'b0;
                        i_last <= 1'b0;
                        state <= WAIT_DONE;
                    end
                end
                WAIT_DONE: begin
                    if (sponge_done) begin
                        state <= IDLE;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
