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
                    if (counter == 0 || counter == 10 || counter == 20 || counter == 30 || counter == 40 || counter == 50 || counter == 60 || counter == 63) begin
                        // $display("[MUL_25519 DEBUG] Time %t: Counter = %d", $time, counter);
                    end
                    
                    // Radix-4 multiplier (unchanged logic is fine, assuming it works)
                    // The previous logic accumulated into 'product' correctly
                    case (multiplier[3:0])
                        4'd0:  product <= product;
                        4'd1:  product <= product + {255'b0, multiplicand};
                        4'd2:  product <= product + {254'b0, multiplicand, 1'b0};
                        4'd3:  product <= product + {255'b0, multiplicand} + {254'b0, multiplicand, 1'b0};
                        4'd4:  product <= product + {253'b0, multiplicand, 2'b0};
                        4'd5:  product <= product + {255'b0, multiplicand} + {253'b0, multiplicand, 2'b0};
                        4'd6:  product <= product + {254'b0, multiplicand, 1'b0} + {253'b0, multiplicand, 2'b0};
                        4'd7:  product <= product + {255'b0, multiplicand} + {254'b0, multiplicand, 1'b0} + {253'b0, multiplicand, 2'b0};
                        4'd8:  product <= product + {252'b0, multiplicand, 3'b0};
                        4'd9:  product <= product + {255'b0, multiplicand} + {252'b0, multiplicand, 3'b0};
                        4'd10: product <= product + {254'b0, multiplicand, 1'b0} + {252'b0, multiplicand, 3'b0};
                        4'd11: product <= product + {255'b0, multiplicand} + {254'b0, multiplicand, 1'b0} + {252'b0, multiplicand, 3'b0};
                        4'd12: product <= product + {253'b0, multiplicand, 2'b0} + {252'b0, multiplicand, 3'b0};
                        4'd13: product <= product + {255'b0, multiplicand} + {253'b0, multiplicand, 2'b0} + {252'b0, multiplicand, 3'b0};
                        4'd14: product <= product + {254'b0, multiplicand, 1'b0} + {253'b0, multiplicand, 2'b0} + {252'b0, multiplicand, 3'b0};
                        4'd15: product <= product + {255'b0, multiplicand} + {254'b0, multiplicand, 1'b0} + {253'b0, multiplicand, 2'b0} + {252'b0, multiplicand, 3'b0};
                    endcase
                    
                    multiplicand <= multiplicand << 4;
                    multiplier <= multiplier >> 4;
                    counter <= counter + 1;
                    
                    if (counter == 63) begin 
                        // $display("[MUL_25519 DEBUG] Time %t: Counter reached 63, moving to REDUCE_1", $time);
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
