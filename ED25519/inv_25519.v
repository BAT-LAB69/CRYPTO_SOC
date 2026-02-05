`timescale 1ns/1ps

module inv_25519(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [254:0] a,
    output reg [254:0] res,
    output reg done,
    output wire busy
);
    // Fermat's little theorem: a^(p-2) mod p = a^(-1) mod p
    // p-2 = 2^255 - 21
    localparam [254:0] EXP = 255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB;
    
    typedef enum reg [1:0] {
        IDLE = 2'd0,
        SQR = 2'd1,
        MUL_COND = 2'd2,
        FINISH = 2'd3
    } state_t;
    
    state_t state;
    assign busy = (state != IDLE);
    
    reg [254:0] base;
    reg [254:0] result;
    reg [7:0] bit_idx;
    
    // Sequential multiplier interface
    reg mul_start;
    wire mul_done;
    wire mul_busy;
    reg [254:0] mul_a, mul_b;
    wire [254:0] mul_res;
    
    mul_25519 multiplier_inst (
        .clk(clk), .rst(rst), .start(mul_start),
        .a(mul_a), .b(mul_b),
        .res(mul_res), .done(mul_done), .busy(mul_busy)
    );
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            result <= 0;
            base <= 0;
            bit_idx <= 0;
            mul_start <= 0;
        end else begin
            mul_start <= 0; // Auto-clear
            
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        base <= a;
                        result <= 1;
                        bit_idx <= 254;
                        state <= SQR;
                    end
                end
                
                SQR: begin
                    // Square: result = result * result
                    if (!mul_busy && !mul_done) begin
                        mul_a <= result;
                        mul_b <= result;
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        result <= mul_res;
                        // Check if we need to multiply by base
                        if (EXP[bit_idx]) begin
                            state <= MUL_COND;
                        end else begin
                            // Go to next bit
                            if (bit_idx == 0) begin
                                state <= FINISH;
                            end else begin
                                bit_idx <= bit_idx - 1;
                                state <= SQR;
                            end
                        end
                    end
                end
                
                MUL_COND: begin
                    // Multiply: result = result * base
                    if (!mul_busy && !mul_done) begin
                        mul_a <= result;
                        mul_b <= base;
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        result <= mul_res;
                        // Go to next bit
                        if (bit_idx == 0) begin
                            state <= FINISH;
                        end else begin
                            bit_idx <= bit_idx - 1;
                            state <= SQR;
                        end
                    end
                end
                
                FINISH: begin
                    res <= result;
                    done <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule