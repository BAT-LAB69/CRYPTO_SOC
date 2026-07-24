`timescale 1ns/1ps


module scala_mul_25519(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [255:0] scalar, //scalar 256bit
    
    input wire [254:0] base_x, base_y, base_z, base_t,
    
    output reg [254:0] res_x, res_y, res_z, res_t,
    output reg done,
    output wire busy
);
    //reg store Montgomery Ladder
    reg [254:0] r0_x, r0_y, r0_z, r0_t;
    reg [254:0] r1_x, r1_y, r1_z, r1_t;
    
    reg [8:0] bit_idx; //loop cnt from 255 to 0

    reg pt_start;
    reg [1:0] pt_mode;
    wire pt_done;
    wire pt_busy;
    wire [254:0] pt_res_x, pt_res_y, pt_res_z, pt_res_t;

    point_op_25519 point_op (
        .clk(clk),
        .rst(rst),
        .start(pt_start),
        .mode(pt_mode),
        .p1_x(r0_x),
        .p1_y(r0_y),
        .p1_z(r0_z),
        .p1_t(r0_t),
        .p2_x(r1_x),
        .p2_y(r1_y),
        .p2_z(r1_z),
        .p2_t(r1_t),
        .res_x(pt_res_x),
        .res_y(pt_res_y),
        .res_z(pt_res_z),
        .res_t(pt_res_t),
        .done(pt_done),
        .busy(pt_busy)
    );

    typedef enum reg [2:0] {
        IDLE = 3'd0,
        INIT = 3'd1,
        ADD = 3'd2,
        DBL = 3'd3,
        UPDATE = 3'd4,
        FINISH = 3'd5
    } state_t;

    state_t state;
    assign busy = (state != IDLE);
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            bit_idx <= 255;
        end else begin
            pt_start <= 0;
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) state <= INIT;
                end
                INIT: begin
                    //r0 = (0, 1, 1, 0), r1 = base
                    r0_x <= 0;
                    r0_y <= 1;
                    r0_z <= 1;
                    r0_t <= 0;
                    r1_x <= base_x;
                    r1_y <= base_y;
                    r1_z <= base_z;
                    r1_t <= base_t;
                    bit_idx <= 255;
                    pt_mode <= 2'b00; // ADD mode
                    state <= ADD;
                end
                //r0 = r0 + r1 (constant-time)
                ADD: begin
                    if (!pt_busy && !pt_done) begin
                        pt_start <= 1;
                        pt_mode <= 2'b00; // ADD mode
                    end else begin
                        pt_start <= 0;
                    end
                    if (pt_done) begin 
                        
                        r0_x <= scalar[bit_idx] ? pt_res_x : r0_x;
                        r0_y <= scalar[bit_idx] ? pt_res_y : r0_y;
                        r0_z <= scalar[bit_idx] ? pt_res_z : r0_z;
                        r0_t <= scalar[bit_idx] ? pt_res_t : r0_t;
                        
                        r1_x <= scalar[bit_idx] ? r1_x : pt_res_x;
                        r1_y <= scalar[bit_idx] ? r1_y : pt_res_y;
                        r1_z <= scalar[bit_idx] ? r1_z : pt_res_z;
                        r1_t <= scalar[bit_idx] ? r1_t : pt_res_t;
                        
                        state <= DBL;
                    end
                end
                DBL: begin
                    if (!pt_busy && !pt_done) begin
                        pt_start <= 1;
                        pt_mode  <= 2'b01; // DBL mode
                        // Constant-time: copy appropriate point for doubling
                        r0_x <= scalar[bit_idx] ? r1_x : r0_x;
                        r0_y <= scalar[bit_idx] ? r1_y : r0_y;
                        r0_z <= scalar[bit_idx] ? r1_z : r0_z;
                        r0_t <= scalar[bit_idx] ? r1_t : r0_t;
                        
                        r1_x <= scalar[bit_idx] ? r1_x : r0_x;
                        r1_y <= scalar[bit_idx] ? r1_y : r0_y;
                        r1_z <= scalar[bit_idx] ? r1_z : r0_z;
                        r1_t <= scalar[bit_idx] ? r1_t : r0_t;
                    end else begin
                        pt_start <= 0;
                    end

                    if (pt_done) begin
                        // Constant-time conditional assignment
                        r1_x <= scalar[bit_idx] ? pt_res_x : r1_x;
                        r1_y <= scalar[bit_idx] ? pt_res_y : r1_y;
                        r1_z <= scalar[bit_idx] ? pt_res_z : r1_z;
                        r1_t <= scalar[bit_idx] ? pt_res_t : r1_t;
                        
                        r0_x <= scalar[bit_idx] ? r0_x : pt_res_x;
                        r0_y <= scalar[bit_idx] ? r0_y : pt_res_y;
                        r0_z <= scalar[bit_idx] ? r0_z : pt_res_z;
                        r0_t <= scalar[bit_idx] ? r0_t : pt_res_t;
                        
                        state <= UPDATE;
                    end
                end
                UPDATE: begin
                    if (bit_idx == 0) begin
                        res_x <= r0_x;
                        res_y <= r0_y;
                        res_z <= r0_z;
                        res_t <= r0_t;
                        state <= FINISH;
                    end else begin
                        bit_idx <= bit_idx - 1;
                        state <= ADD;
                    end
                end
                FINISH: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule