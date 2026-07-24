`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 01:48:06 AM
// Design Name: 
// Module Name: keccak_round
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module keccak_round(
    input  wire [1599:0] i_state, // in state
    input  wire [63:0]   i_round_const, // Round Constant - RC
    
    output wire [1599:0] o_state
    );
    
    // MAPPING
    //Keccak work on matrix 5x5, each lane is 64bits
    //map vector 1600bit to matrix [x][y]
    
    wire [63:0] array [4:0][4:0]; // matrix 5x5x64
    
    genvar x, y;
    generate 
        for (y = 0; y < 5; y = y + 1) begin : map_in_y
            for (x = 0; x < 5; x = x + 1) begin : map_in_x
                // map from vector to [x][y]
                assign array[x][y] = i_state[64*(5*y + x) +: 64]; 
            end
        end
    endgenerate
    
    
    // THETA: Linear Mixing
    
    wire [63:0] c [4:0]; // parity of collum
    wire [63:0] d [4:0]; // gia tri de XOR vao state
    wire [63:0] theta_out [4:0][4:0];
    
    //cal C[x]: XOR all lanes which in the same collum
    generate 
        for (x = 0; x < 5; x = x + 1) begin : calc_c
            assign c[x] = array[x][0] ^ array[x][1] ^ array[x][2] ^ array[x][3] ^ array[x][4];
        end
    endgenerate
    
    // D[x] = C[x-1] ^ ROTL(C[x+1], 1)
    generate 
        for (x = 0; x < 5; x = x + 1) begin : calc_d
            //xử lý chỉ số âm và modulo 5: (x+4)%5 tương đương x-1
            assign d[x] = c[(x+4)%5] ^ {c[(x+1)%5][62:0], c[(x+1)%5][63]};
        end
    endgenerate
    
    //apply D to State: A'[x][y] = A[x][y] ^ D[x]
    generate 
        for (y = 0; y < 5; y = y + 1) begin : theta_apply
            for (x = 0; x < 5; x = x + 1) begin : theta_op
                assign theta_out[x][y] = array[x][y] ^ d[x]; 
            end
        end
    endgenerate    
    
    
    //RHO AND PI: Rotation & Permutation Lane
    wire [63:0] rho_pi_out [4:0][4:0];

    // Rotation Offsets by Keccak
    function [5:0] get_offset;
        input [2:0] x_in, y_in;
        begin
            case ({x_in, y_in})
                {3'd0, 3'd0}: get_offset = 0;
                {3'd1, 3'd0}: get_offset = 1;
                {3'd2, 3'd0}: get_offset = 62;
                {3'd3, 3'd0}: get_offset = 28;
                {3'd4, 3'd0}: get_offset = 27;
                
                {3'd0, 3'd1}: get_offset = 36;
                {3'd1, 3'd1}: get_offset = 44;
                {3'd2, 3'd1}: get_offset = 6;
                {3'd3, 3'd1}: get_offset = 55;
                {3'd4, 3'd1}: get_offset = 20;
                
                {3'd0, 3'd2}: get_offset = 3;
                {3'd1, 3'd2}: get_offset = 10;
                {3'd2, 3'd2}: get_offset = 43;
                {3'd3, 3'd2}: get_offset = 25;
                {3'd4, 3'd2}: get_offset = 39;
                
                {3'd0, 3'd3}: get_offset = 41;
                {3'd1, 3'd3}: get_offset = 45;
                {3'd2, 3'd3}: get_offset = 15;
                {3'd3, 3'd3}: get_offset = 21;
                {3'd4, 3'd3}: get_offset = 8;
                
                {3'd0, 3'd4}: get_offset = 18;
                {3'd1, 3'd4}: get_offset = 2;
                {3'd2, 3'd4}: get_offset = 61;
                {3'd3, 3'd4}: get_offset = 56;
                {3'd4, 3'd4}: get_offset = 14;
                default:      get_offset = 0;
            endcase
        end
    endfunction

    generate
        for (y = 0; y < 5; y = y + 1) begin : rho_pi_y
            for (x = 0; x < 5; x = x + 1) begin : rho_pi_x
                //wire [5:0] shift;
                wire [63:0] temp_val;
                
                // value offset
                localparam integer shift = get_offset(x[2:0], y[2:0]);
                
                // perform RHO: Rotate Left
                
                assign temp_val = theta_out[x][y];
                wire [63:0] rotated_val;
                
                if (shift == 0) assign rotated_val = temp_val;
                else            assign rotated_val = {temp_val[63-shift : 0], temp_val[63 : 64-shift]};

                // perform PI: Hoán đổi vị trí
                // formula Pi: Output[y][2x+3y] = Input[x][y]
                assign rho_pi_out[y][(2*x + 3*y)%5] = rotated_val;
            end
        end
    endgenerate
    
    
    //STATE CHI: non-linear
    //A out = A in XOR (~B & C)
    wire [63:0] chi_out [4:0][4:0];
    generate
        for (y = 0; y < 5; y = y + 1) begin : chi_y
            for (x = 0; x < 5; x = x + 1) begin : chi_x
                assign chi_out[x][y] = rho_pi_out[x][y] ^ 
                                      ((~rho_pi_out[(x+1)%5][y]) & rho_pi_out[(x+2)%5][y]);
            end
        end
    endgenerate    
    
    
    // STATE IOTA: plus Round Constant to pha vo doi xung
    wire [63:0] iota_out [4:0][4:0];

    generate
        for (y = 0; y < 5; y = y + 1) begin : iota_y
            for (x = 0; x < 5; x = x + 1) begin : iota_x
                if (x == 0 && y == 0)
                    // Chỉ XOR RC vào Lane (0,0)
                    assign iota_out[x][y] = chi_out[x][y] ^ i_round_const;
                else
                    assign iota_out[x][y] = chi_out[x][y];
            end
        end
    endgenerate    
    
    
    // OUTPUT MAPPING
    // map 3D [x][y] to vector 1600bits
    generate
        for (y = 0; y < 5; y = y + 1) begin : map_out_y
            for (x = 0; x < 5; x = x + 1) begin : map_out_x
                assign o_state[64*(5*y + x) +: 64] = iota_out[x][y];
            end
        end
    endgenerate
     
endmodule
