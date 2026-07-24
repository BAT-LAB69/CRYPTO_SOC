`timescale 1ns/1ps



module add_sub_25519(
    input wire [255:0] a,
    input wire [255:0] b,
    input wire op, //0: add, 1: sub
    output reg [255:0] res
);

    localparam [255:0] P = {1'b0, 255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED}; //2^255 - 19

    wire [256:0] sum_full;
    wire [256:0] sum_minus_p;
    wire [256:0] sub_full;
    wire [256:0] sub_minus_p;
    
    assign sum_full = a + b;
    assign sum_minus_p = sum_full - P;

    assign sub_full = a - b;
    assign sub_minus_p = sub_full + P;

    always @(*) begin
        if (!op) begin
            if (sum_full >= P)
                res = sum_minus_p[255:0];
            else
                res = sum_full[255:0];
        end
        else begin
            if (a < b)
                res = sub_minus_p;
            else
                res = sub_full;
        end
    end
    
endmodule