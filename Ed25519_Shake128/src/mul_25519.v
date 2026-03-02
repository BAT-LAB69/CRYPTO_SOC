`timescale 1ns/1ps

module mul_25519(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [254:0] a,
    input wire [254:0] b,
    output reg [254:0] res,
    output reg done,
    output wire busy
);
    localparam [254:0] P = 255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED;
    
    
    localparam IDLE = 3'd0;
    localparam MUL = 3'd1;
    localparam REDUCE_1 = 3'd2;
    localparam REDUCE_2 = 3'd3;
    localparam FINAL = 3'd4;
    
    reg [2:0] state;
    assign busy = (state != IDLE);
    
    reg [509:0] product;
    reg [509:0] multiplicand; 
    reg [254:0] multiplier;
    reg [7:0] counter;
    
    reg [263:0] temp1; // First reduction result (< 20 * 2^255)
    reg [255:0] temp2; // Second reduction result (< 2 * 2^255)
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            // res <= 0; // Don't clear result, hold it
            product <= 0;
            counter <= 0;
            multiplicand <= 0;
            multiplier <= 0;
            temp1 <= 0;
            temp2 <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // $display("[MUL_25519 DEBUG] Time %t: Starting multiplication", $time);
                        multiplicand <= {255'b0, a}; 
                        multiplier <= b;
                        product <= 0;
                        counter <= 0;
                        state <= MUL;
                    end
                end
                
                MUL: begin
                    if (counter == 0 || counter == 64 || counter == 127) begin
                        // $display("[MUL_25519 DEBUG] Time %t: Counter = %d", $time, counter);
                    end
                    
                    // Radix-2 multiplier to minimize LUT usage.
                    // Instead of evaluating 16 massive cases, process 1 bit at a time
                    // or 2 bits linearly. Let's do Radix-2 for maximum area savings:
                    if (multiplier[0]) begin
                        product <= product + multiplicand;
                    end
                    
                    multiplicand <= multiplicand << 1;
                    multiplier <= multiplier >> 1;
                    counter <= counter + 1;
                    
                    if (counter == 254) begin 
                        // $display("[MUL_25519 DEBUG] Time %t: Counter reached 254, moving to REDUCE_1", $time);
                        state <= REDUCE_1;
                    end
                end
                
                REDUCE_1: begin
                    // First Reduction: L + 19*H
                    // H = product[509:255] (255 bits max)
                    // L = product[254:0]
                    // temp1 can be up to ~20 * 2^255 (260 bits approx)
                    // (19 = 16 + 2 + 1)
                    temp1 <= {9'b0, product[254:0]} + 
                             {4'b0, product[509:255], 4'b0} +  // 16*H
                             {8'b0, product[509:255], 1'b0} +  // 2*H
                             {9'b0, product[509:255]};         // 1*H
                    
                    state <= REDUCE_2;
                end
                
                REDUCE_2: begin
                    // Second Reduction: L' + 19*H'
                    // temp1 is 264 bits. P is 255 bits.
                    // H' = temp1[263:255] (9 bits)
                    // L' = temp1[254:0] 
                    // 19*H' is small (approx 19 * 511 ~ 10000).
                    // Result < P + 10000. Fits in 256 bits easily.
                    temp2 <= {1'b0, temp1[254:0]} + (19 * temp1[263:255]);
                    
                    state <= FINAL;
                end
                
                FINAL: begin
                    // Final subtract P if needed
                    if (temp2 >= {1'b0, P}) begin
                        res <= temp2[254:0] - P; // Or temp2 - P
                    end else begin
                        res <= temp2[254:0];
                    end
                    done <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
