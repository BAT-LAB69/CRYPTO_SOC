`timescale 1ns/1ps

module arithmetic(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [255:0] k_in, //input from shake128
    input wire [255:0] s_in, //input from s
    input wire [255:0] r_in, //input form r (nonce from shake128)
    output reg [252:0] s_out, //last result 253 bit
    output reg done,
    output wire busy

);

    localparam [252:0] L = 253'h1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ed;

    reg [511:0] mul_res;
    reg reducer_start;
    wire reducer_done;
    wire [252:0] reducer_dout;
    wire reducer_busy;

    reg [511:0] temp;
    
    // Sequential multiplier registers
    reg [511:0] multiplicand;
    reg [255:0] multiplier;
    reg [511:0] product;
    reg [8:0] mul_counter;

    reducer reducer_inst(
        .clk(clk),
        .rst(rst),
        .start(reducer_start),
        .din(temp),
        .dout(reducer_dout),
        .done(reducer_done),
        .busy(reducer_busy)
    );

    typedef enum reg [2:0] {
        IDLE = 3'd0,
        MUL_INIT = 3'd1,
        MUL_LOOP = 3'd2,
        REDUCE = 3'd3,
        ADD = 3'd4,
        FINISH = 3'd5
    } state_t;

    state_t state;
    assign busy = (state != IDLE); 
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            mul_res <= 0;
            reducer_start <= 0;
            s_out <= 0;
            product <= 0;
            multiplicand <= 0;
            multiplier <= 0;
            mul_counter <= 0;
        end else begin
            reducer_start <= 0;
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        multiplicand <= {256'b0, k_in};
                        multiplier <= s_in;
                        product <= 0;
                        mul_counter <= 0;
                        state <= MUL_INIT;
                    end
                end
                
                MUL_INIT: begin
                    // Ready to start multiplication
                    state <= MUL_LOOP;
                end
                
                MUL_LOOP: begin
                    // Shift-and-add multiplication
                    if (multiplier[0]) begin
                        product <= product + multiplicand;
                    end
                    multiplier <= multiplier >> 1;
                    multiplicand <= multiplicand << 1;
                    mul_counter <= mul_counter + 1;
                    
                    if (mul_counter == 255) begin
                        mul_res <= product;
                        state <= REDUCE;
                    end
                end
                
                REDUCE: begin
                    if (!reducer_busy && !reducer_done) begin
                        temp <= mul_res;
                        reducer_start <= 1;
                    end else if (reducer_done) begin
                        temp <= {1'b0, reducer_dout} + {1'b0, r_in[252:0]};
                        state <= ADD;
                    end
                end
                
                ADD: begin
                    if (temp >= L) begin
                        s_out <= temp - L;
                    end else begin
                        s_out <= temp[252:0];
                    end
                    state <= FINISH;
                end
                
                FINISH: begin
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