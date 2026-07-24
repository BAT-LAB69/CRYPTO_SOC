`timescale 1ns/1ps

module reducer(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [511:0] din,
    output reg [252:0] dout,
    output reg done,
    output wire busy
);
    
    localparam [252:0] L = 253'h1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ed;

    reg [511:0] remainder;
    reg [253:0] acc;
    reg [8:0] cnt;


    localparam IDLE = 2'd0;
    localparam SHIFT = 2'd1;
    localparam SUB = 2'd2;
    localparam FINAL = 2'd3;

    reg [1:0] state;
    assign busy = (state != IDLE);

    wire [254:0] sub_res = {1'b0, acc} - {2'b0, L};

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            cnt <= 0;
            acc <= 0;
            remainder <= 0;
            dout <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        remainder <= din;
                        acc <= 0;
                        cnt <= 511;
                        state <= SHIFT;
                    end
                end

                SHIFT: begin
                    {acc, remainder} <= {acc[252:0], remainder, 1'b0};
                    state <= SUB;
                end

                SUB: begin
                    if (!sub_res[254]) begin
                        acc <= sub_res[253:0];
                    end 
                    if (cnt == 0) begin
                        state <= FINAL;
                    end else begin
                        cnt <= cnt - 1;
                        state <= SHIFT;
                    end
                end
                FINAL: begin
                    dout <= acc[252:0];
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
