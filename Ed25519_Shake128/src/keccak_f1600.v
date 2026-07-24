`timescale 1ns/1ps

//hoan vi 24 vong f1600

module keccak_f1600(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [1599:0] in_state,
    output reg [1599:0] out_state,
    output reg done,
    output wire busy
);


    localparam IDLE = 2'd0;
    localparam PROCESS = 2'd1;
    localparam FINISH = 2'd2;

    reg [1:0] state;


    reg [4:0] round_cnt; //0_23 round
    reg [1599:0] curr_state; 
    reg [63:0] rc; //round constant

    wire [1599:0] next_state;

    keccak_round round_inst(
        .in_state(curr_state),
        .rc(rc),
        .out_state(next_state)
    );

    assign busy = (state != IDLE);

    //RC for kaccak-f1600
    always @(*) begin
        case (round_cnt)
            5'd0:  rc = 64'h0000000000000001; 5'd1:  rc = 64'h0000000000008082;
            5'd2:  rc = 64'h800000000000808a; 5'd3:  rc = 64'h8000000080008000;
            5'd4:  rc = 64'h000000000000808b; 5'd5:  rc = 64'h0000000080000001;
            5'd6:  rc = 64'h8000000080008081; 5'd7:  rc = 64'h8000000000008009;
            5'd8:  rc = 64'h000000000000008a; 5'd9:  rc = 64'h0000000000000088;
            5'd10: rc = 64'h0000000080008009; 5'd11: rc = 64'h000000008000000a;
            5'd12: rc = 64'h000000008000808b; 5'd13: rc = 64'h800000000000008b;
            5'd14: rc = 64'h8000000000008089; 5'd15: rc = 64'h8000000000008003;
            5'd16: rc = 64'h8000000000008002; 5'd17: rc = 64'h8000000000000080;
            5'd18: rc = 64'h000000000000800a; 5'd19: rc = 64'h800000008000000a;
            5'd20: rc = 64'h8000000080008081; 5'd21: rc = 64'h8000000000008080;
            5'd22: rc = 64'h0000000080000001; 5'd23: rc = 64'h8000000080008008;
            default: rc = 64'h0;
        endcase
    end

    //FSM
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            round_cnt <= 5'd0;
            curr_state <= 1600'd0;
            done <= 1'b0;
            out_state <= 1600'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        curr_state <= in_state;
                        round_cnt <= 5'd0;
                        state <= PROCESS;
                    end
                end
                PROCESS: begin
                    curr_state <= next_state;
                    if (round_cnt == 5'd23) begin
                        state <= FINISH;
                    end else begin
                        round_cnt <= round_cnt + 1;
                    end
                end
                FINISH: begin
                    done <= 1'b1;
                    out_state <= curr_state;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end


endmodule
