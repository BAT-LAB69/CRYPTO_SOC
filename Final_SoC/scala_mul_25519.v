`timescale 1ns/1ps

module scala_mul_25519(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [255:0] scalar, // scalar 256bit (clamped)
    
    input wire [254:0] base_x, base_y, base_z, base_t,
    
    output reg [254:0] res_x, res_y, res_z, res_t,
    output reg done,
    output wire busy
);

    // Internal Point Register (Accumulator)
    reg [254:0] curr_x, curr_y, curr_z, curr_t;
    
    // Bit counter
    reg [8:0] bit_idx; // 0 to 255

    // Point Op Interface
    reg pt_start;
    reg [1:0] pt_mode; // 0: ADD, 1: DBL
    // Inputs to Point Op
    reg [254:0] pt_p1_x, pt_p1_y, pt_p1_z, pt_p1_t;
    reg [254:0] pt_p2_x, pt_p2_y, pt_p2_z, pt_p2_t;
    // Outputs from Point Op
    wire [254:0] pt_res_x, pt_res_y, pt_res_z, pt_res_t;
    wire pt_done;
    wire pt_busy;

    point_op_25519 point_op (
        .clk(clk),
        .rst(rst),
        .start(pt_start),
        .mode(pt_mode),
        .p1_x(pt_p1_x), 
        .p1_y(pt_p1_y), 
        .p1_z(pt_p1_z), 
        .p1_t(pt_p1_t),
        .p2_x(pt_p2_x), 
        .p2_y(pt_p2_y), 
        .p2_z(pt_p2_z), 
        .p2_t(pt_p2_t),
        .res_x(pt_res_x), 
        .res_y(pt_res_y), 
        .res_z(pt_res_z), 
        .res_t(pt_res_t),
        .done(pt_done),
        .busy(pt_busy)
    );


    localparam IDLE = 3'd0;
    localparam INIT = 3'd1;
    localparam DBL_PREP = 3'd2;
    localparam DBL_WAIT = 3'd3;
    localparam ADD_PREP = 3'd4;
    localparam ADD_WAIT = 3'd5;
    localparam NEXT_BIT = 3'd6;
    localparam FINISH = 3'd7;

    reg [2:0] state;
    assign busy = (state != IDLE);
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            // Initialize to identity point (0, 1, 1, 0) even at reset
            curr_x <= 0; 
            curr_y <= 1;  
            curr_z <= 1;  
            curr_t <= 0;
            bit_idx <= 0;
            pt_start <= 0;
        end else begin
            pt_start <= 0; // Pulse
            
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        
                        
                        // Initialize Result to Identity (0, 1, 1, 0)
                        curr_x <= 0;
                        curr_y <= 1;
                        curr_z <= 1;
                        curr_t <= 0;
                        
                        bit_idx <= 254; 
                        
                        // Clear point op interface registers
                        pt_p1_x <= 0; pt_p1_y <= 0; pt_p1_z <= 0; pt_p1_t <= 0;
                        pt_p2_x <= 0; pt_p2_y <= 0; pt_p2_z <= 0; pt_p2_t <= 0;
                        pt_mode <= 0;
                        
                        // Ensure output is clean
                        // res_x <= 0; res_y <= 0; res_z <= 0; res_t <= 0; // Optional
                        
                        state <= DBL_PREP;
                    end
                end

                // 1. Double the current accumulator
                DBL_PREP: begin
                    pt_p1_x <= curr_x; pt_p1_y <= curr_y; pt_p1_z <= curr_z; pt_p1_t <= curr_t;
                    pt_p2_x <= curr_x; pt_p2_y <= curr_y; pt_p2_z <= curr_z; pt_p2_t <= curr_t;
                    pt_mode <= 2'b01; // DBL
                    pt_start <= 1;
                    state <= DBL_WAIT;
                end
                DBL_WAIT: begin
                    if (pt_done) begin
                        curr_x <= pt_res_x;
                        curr_y <= pt_res_y;
                        curr_z <= pt_res_z;
                        curr_t <= pt_res_t;
                        
                        // Check if we need to add (if scalar bit is 1)
                        if (scalar[bit_idx]) begin
                            state <= ADD_PREP;
                        end else begin
                            state <= NEXT_BIT;
                        end
                    end
                end

                // 2. Add Base Point if scalar bit is 1
                ADD_PREP: begin
                    pt_p1_x <= curr_x;  pt_p1_y <= curr_y;  pt_p1_z <= curr_z;  pt_p1_t <= curr_t;
                    pt_p2_x <= base_x;  pt_p2_y <= base_y;  pt_p2_z <= base_z;  pt_p2_t <= base_t;
                    pt_mode <= 2'b00; // ADD
                    pt_start <= 1;
                    state <= ADD_WAIT;
                end
                ADD_WAIT: begin
                    if (pt_done) begin
                        curr_x <= pt_res_x;
                        curr_y <= pt_res_y;
                        curr_z <= pt_res_z;
                        curr_t <= pt_res_t;
                        state <= NEXT_BIT;
                    end
                end

                NEXT_BIT: begin
                    if (bit_idx == 0) begin
                        state <= FINISH;
                    end else begin
                        bit_idx <= bit_idx - 1;
                        state <= DBL_PREP;
                    end
                end

                FINISH: begin
                    
                    res_x <= curr_x;
                    res_y <= curr_y;
                    res_z <= curr_z;
                    res_t <= curr_t;
                    done <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule