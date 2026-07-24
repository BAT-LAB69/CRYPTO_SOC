`timescale 1ns/1ps
 
// Formula: add-2008-hwcd from EFD
module point_op_25519(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [1:0] mode,
    
    input wire [254:0] p1_x, p1_y, p1_z, p1_t,
    input wire [254:0] p2_x, p2_y, p2_z, p2_t,
    
    output reg [254:0] res_x, res_y, res_z, res_t,
    output reg done,
    output wire busy
);
    localparam [254:0] D = 255'h52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3;

    reg [254:0] reg_A, reg_B, reg_C, reg_D, reg_E, reg_F, reg_G, reg_H;
    reg [254:0] temp1, temp2, temp3;

    reg mul_start;
    wire mul_done;
    reg [254:0] mul_a, mul_b;
    wire [254:0] mul_res;

    mul_25519 mul_inst(.clk(clk), 
    .rst(rst), 
    .start(mul_start),
    .a(mul_a), 
    .b(mul_b), 
    .res(mul_res), 
    .done(mul_done), 
    .busy()
    );

    reg [255:0] addsub_a, addsub_b;
    reg addsub_op;
    wire [255:0] addsub_res;

    add_sub_25519 addsub_inst(.a(addsub_a), 
    .b(addsub_b), 
    .op(addsub_op), 
    .res(addsub_res)
    );


    localparam IDLE = 6'd0;
    localparam S_A = 6'd1;
    localparam W_A = 6'd2;
    localparam S_B = 6'd3;
    localparam W_B = 6'd4;
    localparam S_C1 = 6'd5;
    localparam W_C1 = 6'd6;
    localparam S_C2 = 6'd7;
    localparam W_C2 = 6'd8;
    localparam S_D = 6'd9;
    localparam W_D = 6'd10;
    localparam S_E1a = 6'd11;
    localparam S_E1b = 6'd12;
    localparam S_E2a = 6'd13;
    localparam S_E2b = 6'd14;
    localparam S_E3 = 6'd15;
    localparam W_E3 = 6'd16;
    localparam S_E4a = 6'd17;
    localparam S_E4b = 6'd18;
    localparam S_E5a = 6'd19;
    localparam S_E5b = 6'd20;
    localparam S_Fa = 6'd21;
    localparam S_Fb = 6'd22;
    localparam S_Ga = 6'd23;
    localparam S_Gb = 6'd24;
    localparam S_Ha = 6'd25;
    localparam S_Hb = 6'd26;
    localparam S_X3 = 6'd27;
    localparam W_X3 = 6'd28;
    localparam S_Y3 = 6'd29;
    localparam W_Y3 = 6'd30;
    localparam S_T3 = 6'd31;
    localparam W_T3 = 6'd32;
    localparam S_Z3 = 6'd33;
    localparam W_Z3 = 6'd34;
    localparam FINISH = 6'd35;

    reg [5:0] state;
    assign busy = (state != IDLE);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            done <= 0;
            mul_start <= 0;
        end else begin
            mul_start <= 0;
            
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= S_A;
                    end
                end

                S_A: begin 
                    mul_a <= p1_x; 
                    mul_b <= p2_x; 
                    mul_start <= 1; 
                    state <= W_A; 
                end
                W_A: if (mul_done) begin 
                    reg_A <= mul_res; 
                    state <= S_B; 
                end

                S_B: begin 
                    mul_a <= p1_y; 
                    mul_b <= p2_y; 
                    mul_start <= 1; 
                    state <= W_B; 
                end
                W_B: if (mul_done) begin reg_B <= mul_res; state <= S_C1; end

                S_C1: begin 
                    mul_a <= p1_t; 
                    mul_b <= p2_t; 
                    mul_start <= 1; 
                    state <= W_C1; 
                end
                W_C1: if (mul_done) begin temp1 <= mul_res; state <= S_C2; end
                S_C2: begin 
                    mul_a <= D; 
                    mul_b <= temp1; 
                    mul_start <= 1; 
                    state <= W_C2; 
                end
                W_C2: if (mul_done) begin 
                    reg_C <= mul_res; 
                    state <= S_D; 
                end

                S_D: begin 
                    mul_a <= p1_z; 
                    mul_b <= p2_z; 
                    mul_start <= 1; 
                    state <= W_D; 
                end
                W_D: if (mul_done) begin 
                    reg_D <= mul_res; 
                    state <= S_E1a; 
                end

                // E = (X1+Y1)*(X2+Y2) - A - B
                S_E1a: begin
                    addsub_a <= {1'b0, p1_x};
                    addsub_b <= {1'b0, p1_y};
                    addsub_op <= 0;
                    state <= S_E1b;
                end
                S_E1b: begin
                    temp1 <= addsub_res[254:0]; // Capture X1+Y1
                    state <= S_E2a;
                end
                S_E2a: begin
                    addsub_a <= {1'b0, p2_x};
                    addsub_b <= {1'b0, p2_y};
                    addsub_op <= 0;
                    state <= S_E2b;
                end
                S_E2b: begin
                    temp2 <= addsub_res[254:0]; // Capture X2+Y2
                    state <= S_E3;
                end
                S_E3: begin
                    mul_a <= temp1;
                    mul_b <= temp2;
                    mul_start <= 1;
                    state <= W_E3;
                end
                W_E3: if (mul_done) begin
                    temp1 <= mul_res; // (X1+Y1)*(X2+Y2)
                    state <= S_E4a;
                end
                S_E4a: begin
                    addsub_a <= {1'b0, temp1};
                    addsub_b <= {1'b0, reg_A};
                    addsub_op <= 1;
                    state <= S_E4b;
                end
                S_E4b: begin
                    temp2 <= addsub_res[254:0]; // temp1 - A
                    state <= S_E5a;
                end
                S_E5a: begin
                    addsub_a <= {1'b0, temp2};
                    addsub_b <= {1'b0, reg_B};
                    addsub_op <= 1;
                    state <= S_E5b;
                end
                S_E5b: begin
                    reg_E <= addsub_res[254:0]; // Final E
                    state <= S_Fa;
                end

                // F = D - C
                S_Fa: begin
                    addsub_a <= {1'b0, reg_D};
                    addsub_b <= {1'b0, reg_C};
                    addsub_op <= 1;
                    state <= S_Fb;
                end
                S_Fb: begin
                    reg_F <= addsub_res[254:0];
                    state <= S_Ga;
                end

                // G = D + C
                S_Ga: begin
                    addsub_a <= {1'b0, reg_D};
                    addsub_b <= {1'b0, reg_C};
                    addsub_op <= 0;
                    state <= S_Gb;
                end
                S_Gb: begin
                    reg_G <= addsub_res[254:0];
                    state <= S_Ha;
                end

                // H = B + A
                S_Ha: begin
                    addsub_a <= {1'b0, reg_B};
                    addsub_b <= {1'b0, reg_A};
                    addsub_op <= 0;
                    state <= S_Hb;
                end
                S_Hb: begin
                    reg_H <= addsub_res[254:0];
                    state <= S_X3;
                end

                S_X3: begin 
                   
                    mul_a <= reg_E; 
                    mul_b <= reg_F; 
                    mul_start <= 1; 
                    state <= W_X3; 
                end
                W_X3: if (mul_done) begin 
                    res_x <= mul_res; 
                    state <= S_Y3; 
                end

                S_Y3: begin 
                    mul_a <= reg_G; 
                    mul_b <= reg_H; 
                    mul_start <= 1; 
                    state <= W_Y3; 
                end
                W_Y3: if (mul_done) begin 
                    res_y <= mul_res; 
                    state <= S_T3; 
                end

                S_T3: begin 
                    mul_a <= reg_E; 
                    mul_b <= reg_H; 
                    mul_start <= 1; 
                    state <= W_T3; 
                end
                W_T3: if (mul_done) begin 
                    res_t <= mul_res; 
                    state <= S_Z3; 
                end

                S_Z3: begin 
                    mul_a <= reg_F; 
                    mul_b <= reg_G; 
                    mul_start <= 1; 
                    state <= W_Z3; 
                end
                W_Z3: if (mul_done) begin 
                    res_z <= mul_res; 
                    state <= FINISH; 
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