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
    
    typedef enum reg [1:0] {
        IDLE = 2'd0,
        MUL = 2'd1,
        REDUCE = 2'd2,
        FINAL = 2'd3
    } state_t;
    
    state_t state;
    assign busy = (state != IDLE);
    
    reg [509:0] product;
    reg [509:0] multiplicand; // Expanded to 510 bits to prevent overflow during shift
    reg [254:0] multiplier;
    reg [7:0] counter; // 255/4 = 64 iterations
    
    reg [254:0] high;
    reg [254:0] low;
    reg [263:0] temp; // L + 19*H can be up to 264 bits
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            res <= 0;
            product <= 0;
            counter <= 0;
            multiplicand <= 0; // Clear it
            multiplier <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        multiplicand <= {255'b0, a}; // Load into lower part, no pre-shift
                        multiplier <= b;
                        product <= 0;
                        counter <= 0;
                        state <= MUL;
                    end
                end
                
                MUL: begin
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
                    
                    if (counter == 63) begin // 64 iterations (255/4 rounded up)
                        state <= REDUCE;
                    end
                end
                
                REDUCE: begin
                    // P = 2^255 - 19
                    //  H * 2^255 + L
                    // result = L + 19*H (mod P)
                    high <= product[509:255];
                    low <= product[254:0];
                    
                    // Calculate 19*H + L
                    // 19*H = 16*H + 2*H + H = H<<4 + H<<1 + H
                    temp <= {9'b0, low} + 
                            {4'b0, product[509:255], 4'b0} +  // 16*H
                            {8'b0, product[509:255], 1'b0} +  // 2*H
                            {9'b0, product[509:255]};         // H
                    
                    state <= FINAL;
                end
                
                FINAL: begin
                    // Final reduction if temp >= P
                    if (temp >= {9'b0, P}) begin
                        res <= temp[254:0] - P;
                    end else begin
                        res <= temp[254:0];
                    end
                    done <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
