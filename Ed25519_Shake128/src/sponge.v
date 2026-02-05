`timescale 1ns/1ps  

//rate = 1344 bit, capacity = 256 bit
//suffix = 1111(4bit) combine with padding 10*1

module sponge(
    input wire clk,
    input wire rst,

    input wire [1023:0] din, 
    input wire [6:0] byte_len, // Length matches ed25519 requirement
    input wire i_valid,
    input wire i_last, 
    output reg i_ack, 
    
    output reg [511:0] dout,
    output reg done,
    output wire busy
);

    localparam RATE = 1344;
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

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            sponge_state <= 1600'd0;
            buffer_in <= 1024'd0;
            dout <= 512'd0;
            done <= 1'b0;
            i_ack <= 1'b0;
            f_start <= 1'b0;
        end else begin
            f_start <= 1'b0;
            i_ack <= 1'b0;
            case (state)
                IDLE: begin
                    if (i_valid) begin
                        buffer_in <= din;
                        saved_len <= byte_len;
                        sponge_state <= 0;
                        i_ack <= 1'b1;
                        done <= 1'b0; // Clear done
                        state <= ABSORB;
                    end
                end
                ABSORB: begin
                    //XOR input data w r first bits of state
                    sponge_state[1023:0] <= sponge_state[1023:0] ^ buffer_in;
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
                    
                    sponge_state[saved_len*8 +: 5] <= sponge_state[saved_len*8 +: 5] ^ 5'b11111;
                    sponge_state[1343] <= sponge_state[1343] ^ 1'b1;
                    f_start <= 1'b1;
                    state <= PERMUTE;
                end
                PERMUTE: begin
                    if (f_done) begin
                        sponge_state <= f_out;
                        if (done == 0) begin
                            state <= SQUEEZE;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end
                SQUEEZE: begin
                    //512<1344 -> we can take direct data after 1 time permute 
                    dout <= sponge_state[511:0];
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