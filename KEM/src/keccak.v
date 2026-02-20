`timescale 1ns/1ps
module keccak_round(
    input wire [1599:0] in_state,
    input wire [63:0] rc,
    output wire [1599:0] out_state
);
    wire [63:0] state [0:4][0:4];
    genvar x, y;
    generate
        for (x = 0; x < 5; x = x + 1) begin : state_gen
            for (y = 0; y < 5; y = y + 1) begin : state_row_gen
                assign state[x][y] = in_state[(x + 5*y) * 64 +: 64];
            end
        end
    endgenerate

    // Theta
    wire [63:0] c [0:4];
    wire [63:0] d [0:4];
    wire [63:0] theta_state [0:4][0:4];
    generate 
        for (x = 0; x < 5; x = x + 1) begin: theta_c 
            assign c[x] = state[x][0] ^ state[x][1] ^ state[x][2] ^ state[x][3] ^ state[x][4];
        end
        for (x = 0; x < 5; x = x + 1) begin: theta_d 
            assign d[x] = c[(x+4)%5] ^ {c[(x+1)%5][62:0], c[(x+1)%5][63]};
        end
        for (y = 0; y < 5; y = y + 1) begin: theta_out_y
            for (x = 0; x < 5; x = x + 1) begin: theta_out_x
                assign theta_state[x][y] = d[x] ^ state[x][y];
            end
        end
    endgenerate

    // Rho & Pi
    wire [63:0] rho_pi_state [0:4][0:4];

    assign rho_pi_state[0][0] = theta_state[0][0];
    assign rho_pi_state[0][2] = {theta_state[1][0][62:0], theta_state[1][0][63:63]};
    assign rho_pi_state[0][4] = {theta_state[2][0][1:0], theta_state[2][0][63:2]};
    assign rho_pi_state[0][1] = {theta_state[3][0][35:0], theta_state[3][0][63:36]};
    assign rho_pi_state[0][3] = {theta_state[4][0][36:0], theta_state[4][0][63:37]};
    assign rho_pi_state[1][3] = {theta_state[0][1][27:0], theta_state[0][1][63:28]};
    assign rho_pi_state[1][0] = {theta_state[1][1][19:0], theta_state[1][1][63:20]};
    assign rho_pi_state[1][2] = {theta_state[2][1][57:0], theta_state[2][1][63:58]};
    assign rho_pi_state[1][4] = {theta_state[3][1][8:0], theta_state[3][1][63:9]};
    assign rho_pi_state[1][1] = {theta_state[4][1][43:0], theta_state[4][1][63:44]};
    assign rho_pi_state[2][1] = {theta_state[0][2][60:0], theta_state[0][2][63:61]};
    assign rho_pi_state[2][3] = {theta_state[1][2][53:0], theta_state[1][2][63:54]};
    assign rho_pi_state[2][0] = {theta_state[2][2][20:0], theta_state[2][2][63:21]};
    assign rho_pi_state[2][2] = {theta_state[3][2][38:0], theta_state[3][2][63:39]};
    assign rho_pi_state[2][4] = {theta_state[4][2][24:0], theta_state[4][2][63:25]};
    assign rho_pi_state[3][4] = {theta_state[0][3][22:0], theta_state[0][3][63:23]};
    assign rho_pi_state[3][1] = {theta_state[1][3][18:0], theta_state[1][3][63:19]};
    assign rho_pi_state[3][3] = {theta_state[2][3][48:0], theta_state[2][3][63:49]};
    assign rho_pi_state[3][0] = {theta_state[3][3][42:0], theta_state[3][3][63:43]};
    assign rho_pi_state[3][2] = {theta_state[4][3][55:0], theta_state[4][3][63:56]};
    assign rho_pi_state[4][2] = {theta_state[0][4][45:0], theta_state[0][4][63:46]};
    assign rho_pi_state[4][4] = {theta_state[1][4][61:0], theta_state[1][4][63:62]};
    assign rho_pi_state[4][1] = {theta_state[2][4][2:0], theta_state[2][4][63:3]};
    assign rho_pi_state[4][3] = {theta_state[3][4][7:0], theta_state[3][4][63:8]};
    assign rho_pi_state[4][0] = {theta_state[4][4][49:0], theta_state[4][4][63:50]};

    // Chi
    wire [63:0] chi_state [0:4][0:4];
    generate 
        for (y = 0; y < 5; y = y + 1) begin: chi_y
            for (x = 0; x < 5; x = x + 1) begin: chi_x
                assign chi_state[x][y] = rho_pi_state[x][y] ^ ((~rho_pi_state[(x+1)%5][y]) & rho_pi_state[(x+2)%5][y]);
            end
        end
    endgenerate

    // Iota
    wire [63:0] iota_state [0:4][0:4];
    generate
        for (y = 0; y < 5; y = y + 1) begin: iota_y
            for (x = 0; x < 5; x = x + 1) begin: iota_x
                if (x == 0 && y == 0) begin
                    assign iota_state[x][y] = chi_state[x][y] ^ rc;
                end
                else begin
                    assign iota_state[x][y] = chi_state[x][y];
                end
            end
        end
    endgenerate

    // Output
    generate
        for (y = 0; y < 5; y = y + 1) begin: out_y
            for (x = 0; x < 5; x = x + 1) begin: out_x
                assign out_state[(x + 5*y) * 64 +: 64] = iota_state[x][y];
            end
        end
    endgenerate
endmodule



module keccak_f1600(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [1599:0] in_state,
    output reg [1599:0] out_state,
    output reg done,
    output wire busy
);


    localparam IDLE = 2'd0;
    localparam PROCESS = 2'd1;
    localparam FINISH = 2'd2;

    reg [1:0] state;


    reg [4:0] round_cnt; //0_23 round
    reg [1599:0] curr_state; 
    reg [63:0] rc; //round constant

    wire [1599:0] next_state;

    keccak_round round_inst(
        .in_state(curr_state),
        .rc(rc),
        .out_state(next_state)
    );

    assign busy = (state != IDLE);

    //RC for kaccak-f1600
    always @(*) begin
        case (round_cnt)
            5'd0:  rc = 64'h0000000000000001; 5'd1:  rc = 64'h0000000000008082;
            5'd2:  rc = 64'h800000000000808a; 5'd3:  rc = 64'h8000000080008000;
            5'd4:  rc = 64'h000000000000808b; 5'd5:  rc = 64'h0000000080000001;
            5'd6:  rc = 64'h8000000080008081; 5'd7:  rc = 64'h8000000000008009;
            5'd8:  rc = 64'h000000000000008a; 5'd9:  rc = 64'h0000000000000088;
            5'd10: rc = 64'h0000000080008009; 5'd11: rc = 64'h000000008000000a;
            5'd12: rc = 64'h000000008000808b; 5'd13: rc = 64'h800000000000008b;
            5'd14: rc = 64'h8000000000008089; 5'd15: rc = 64'h8000000000008003;
            5'd16: rc = 64'h8000000000008002; 5'd17: rc = 64'h8000000000000080;
            5'd18: rc = 64'h000000000000800a; 5'd19: rc = 64'h800000008000000a;
            5'd20: rc = 64'h8000000080008081; 5'd21: rc = 64'h8000000000008080;
            5'd22: rc = 64'h0000000080000001; 5'd23: rc = 64'h8000000080008008;
            default: rc = 64'h0;
        endcase
    end

    //FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            round_cnt <= 5'd0;
            curr_state <= 1600'd0;
            done <= 1'b0;
            out_state <= 1600'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        curr_state <= in_state;
                        round_cnt <= 5'd0;
                        state <= PROCESS;
                    end
                end
                PROCESS: begin
                    curr_state <= next_state;
                    round_cnt <= round_cnt + 1;

                    if (round_cnt == 5'd23) begin
                        state <= FINISH;
                    end 
                    
                end
                FINISH: begin
                    done <= 1'b1;
                    out_state <= curr_state;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end


endmodule



///////////////// TEST /////////////////


// `timescale 1ns/1ps

// module tb_keccak_f1600;

//     localparam CLK_PERIOD = 10;

//     reg clk;
//     reg rst;
//     reg start;
//     reg [1599:0] in_state;

//     wire [1599:0] out_state;
//     wire done;
//     wire busy;

//     // DUT
//     keccak_f1600 dut (
//         .clk(clk),
//         .rst(rst),
//         .start(start),
//         .in_state(in_state),
//         .out_state(out_state),
//         .done(done),
//         .busy(busy)
//     );

//     // Clock
//     initial begin
//         clk = 0;
//         forever #(CLK_PERIOD/2) clk = ~clk;
//     end

//     // Expected output (zero input test vector)
//     reg [1599:0] expected;

//     initial begin
//         expected = {
//             64'h75F644E97F30A13B,
//             64'h16F53526E70465C2,
//             64'h1841F924A2C509E4,
//             64'h940C7922AE3A2614,
//             64'h8C3EE88A1CCF32C8,
//             64'hB87C5A554FD00ECB,
//             64'h613670957BC46611,
//             64'h64BEFEF28CC970F2,
//             64'h05E5635A21D9AE61,
//             64'h01F22F1A11A5569F,
//             64'h43B831CD0347C826,
//             64'h81A57C16DBCF555F,
//             64'hA9A6E6260D712103,
//             64'hEB5AA93F2317D635,
//             64'h30935AB7D08FFC64,
//             64'hAD30A6F71B19059C,
//             64'h8C5BDA0CD6192E76,
//             64'h90FEE5A0A44647C4,
//             64'hFF97A42D7F8E6FD4,
//             64'h8B284E056253D057,
//             64'hBD1547306F80494D,
//             64'hD598261EA65AA9EE,
//             64'h84D5CCF933C0478A,
//             64'hF1258F7940E1DDE7
//         };
//     end
//     integer i;
//     initial begin

//         // Init
//         rst = 0;
//         start = 0;
//         in_state = 1600'd0;

//         #50;
//         rst = 1;

//         #20;

//         $display("====================================");
//         $display("TEST: Keccak-f1600 Zero Input");
//         $display("====================================");

//         start = 1;
//         #10;
//         start = 0;

//         wait(done);

//         #10;

//         // if (out_state === expected) begin
//         //     $display("PASS: Output matches NIST vector");
//         // end else begin
//         //     $display("FAIL: Output mismatch");
//         //     $display("Expected = %h", expected);
//         //     $display("Got      = %h", out_state);
//         // end

       
//         for (i = 0; i < 25; i = i + 1)
//             $display("Lane %0d = %h", i, out_state[i*64 +: 64]);

//         #50;
//         $finish;
//     end

// endmodule