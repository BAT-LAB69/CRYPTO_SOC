`timescale 1ns/1ps


module point_op_25519(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [1:0] mode, // 00: ADD, 01: DBL
    
    input wire [254:0] p1_x, p1_y, p1_z, p1_t,
    input wire [254:0] p2_x, p2_y, p2_z, p2_t,
    
    output reg [254:0] res_x, res_y, res_z, res_t,
    output reg done,
    output wire busy
);
    localparam [254:0] D2 = 255'h52036CEE2B6FFE738CC740797779E89800700A4D4141D8AB75EB4DCA135978A3;

    reg [254:0] reg_A, reg_B, reg_C, reg_D;
    reg [254:0] reg_E, reg_F, reg_G, reg_H;
    
    // Sequential mul_25519 signals
    reg mul_start;
    wire mul_done;
    wire mul_busy;
    reg [254:0] mul_a, mul_b;
    wire [254:0] mul_res;

    reg [254:0] addsub_a, addsub_b;
    reg addsub_op;
    wire [254:0] addsub_res;

    mul_25519 mul_inst(
        .clk(clk), .rst(rst), .start(mul_start),
        .a(mul_a), .b(mul_b),
        .res(mul_res), .done(mul_done), .busy(mul_busy)
    );

    add_sub_25519 addsub_inst(
        .a(addsub_a),
        .b(addsub_b),
        .op(addsub_op),
        .res(addsub_res)
    );

    typedef enum reg [4:0] {
        IDLE = 5'd0,
        PREP_A = 5'd1,
        CALC_A = 5'd2,
        PREP_B = 5'd3,
        CALC_B = 5'd4,
        PREP_C_1 = 5'd5,
        CALC_C_1 = 5'd6,
        PREP_C_2 = 5'd7,
        CALC_C_2 = 5'd8,
        PREP_D = 5'd9,
        CALC_D = 5'd10,
        CALC_EFGH = 5'd11,
        PREP_X = 5'd12,
        CALC_X = 5'd13,
        PREP_Y = 5'd14,
        CALC_Y = 5'd15,
        PREP_Z = 5'd16,
        CALC_Z = 5'd17,
        PREP_T = 5'd18,
        CALC_T = 5'd19,
        FINISH = 5'd20
    } state_t;

    state_t state;
    assign busy = (state != IDLE);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            mul_start <= 0;
        end else begin
            mul_start <= 0; // Auto-clear
            
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) state <= PREP_A;
                end
                
                //A = (Y1-X1)*(Y2-X2)
                PREP_A: begin
                    addsub_a <= p1_y;
                    addsub_b <= p1_x;
                    addsub_op <= 1; // subtract
                    state <= CALC_A;
                end
                CALC_A: begin
                    if (!mul_busy && !mul_done) begin
                        mul_a <= addsub_res;
                        addsub_a <= p2_y;
                        addsub_b <= p2_x;
                        addsub_op <= 1;
                        mul_b <= addsub_res;
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        reg_A <= mul_res;
                        state <= PREP_B;
                    end
                end
                
                //B = (Y1+X1)*(Y2+X2)
                PREP_B: begin
                    addsub_a <= p1_y;
                    addsub_b <= p1_x;
                    addsub_op <= 0; // add
                    state <= CALC_B;
                end
                CALC_B: begin
                    if (!mul_busy && !mul_done) begin
                        mul_a <= addsub_res;
                        addsub_a <= p2_y;
                        addsub_b <= p2_x;
                        addsub_op <= 0;
                        mul_b <= addsub_res;
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        reg_B <= mul_res;
                        state <= PREP_C_1;
                    end
                end
                
                //C = T1*2d*T2
                PREP_C_1: begin
                    mul_a <= p1_t;
                    mul_b <= D2;
                    state <= CALC_C_1;
                end
                CALC_C_1: begin
                    if (!mul_busy && !mul_done) begin
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        mul_a <= mul_res; // temp result
                        mul_b <= p2_t;
                        state <= PREP_C_2;
                    end
                end
                PREP_C_2: begin
                    state <= CALC_C_2;
                end
                CALC_C_2: begin
                    if (!mul_busy && !mul_done) begin
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        reg_C <= mul_res;
                       state <= PREP_D;
                    end
                end
                
                //D = Z1*Z2
                PREP_D: begin
                    mul_a <= p1_z;
                    mul_b <= p2_z;
                    state <= CALC_D;
                end
                CALC_D: begin
                    if (!mul_busy && !mul_done) begin
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        reg_D <= mul_res;
                        state <= CALC_EFGH;
                    end
                end
                
                CALC_EFGH: begin
                    addsub_a <= reg_B;
                    addsub_b <= reg_A;
                    addsub_op <= 1; // B-A
                    reg_E <= addsub_res;
                    
                    addsub_a <= reg_D;
                    addsub_b <= reg_C;
                    addsub_op <= 1; // D-C
                    reg_F <= addsub_res;
                    
                    addsub_a <= reg_D;
                    addsub_b <= reg_C;
                    addsub_op <= 0; // D+C
                    reg_G <= addsub_res;
                    
                    addsub_a <= reg_B;
                    addsub_b <= reg_A;
                    addsub_op <= 0; // B+A
                    reg_H <= addsub_res;
                    
                    state <= PREP_X;
                end
                
                //X3 = E*F
                PREP_X: begin
                    mul_a <= reg_E;
                    mul_b <= reg_F;
                    state <= CALC_X;
                end
                CALC_X: begin
                    if (!mul_busy && !mul_done) begin
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        res_x <= mul_res;
                        state <= PREP_Y;
                    end
                end
                
                //Y3 = G*H
                PREP_Y: begin
                    mul_a <= reg_G;
                    mul_b <= reg_H;
                    state <= CALC_Y;
                end
                CALC_Y: begin
                    if (!mul_busy && !mul_done) begin
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        res_y <= mul_res;
                        state <= PREP_Z;
                    end
                end
                
                //Z3 = F*G
                PREP_Z: begin
                    mul_a <= reg_F;
                    mul_b <= reg_G;
                    state <= CALC_Z;
                end
                CALC_Z: begin
                    if (!mul_busy && !mul_done) begin
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        res_z <= mul_res;
                        state <= PREP_T;
                    end
                end
                
                //T3 = E*H
                PREP_T: begin
                    mul_a <= reg_E;
                    mul_b <= reg_H;
                    state <= CALC_T;
                end
                CALC_T: begin
                    if (!mul_busy && !mul_done) begin
                        mul_start <= 1;
                    end
                    if (mul_done) begin
                        res_t <= mul_res;
                        state <= FINISH;
                    end
                end
                
                FINISH: begin
                    done <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule