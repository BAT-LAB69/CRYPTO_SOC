`timescale 1ns/1ps

module add_sub_25519(
    input wire [255:0] a,
    input wire [255:0] b,
    input wire op, //0: add, 1: sub
    output reg [255:0] res
);

    localparam [255:0] P = 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED; //2^255 - 19

    wire [256:0] sum;
    
    assign sum = a + b;

    always @(*) begin
        if (!op) begin 
            // ADD
            if (sum >= P)
                res = sum - P;
            else
                res = sum[255:0];
        end
        else begin 
            // SUB
            if (a >= b)
                res = a - b;
            else
                res = (a + P) - b;
        end
    end
    
endmodule