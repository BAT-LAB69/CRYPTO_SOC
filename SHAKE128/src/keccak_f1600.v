`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 02:31:49 AM
// Design Name: 
// Module Name: keccak_f1600
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


module keccak_f1600(
    input  wire             i_clk,
    input  wire             i_rst_n,
    input  wire             i_start,
    input  wire [1599:0]    i_state,
    
    output reg  [1599:0]    o_state,
    output reg              o_done,
    output reg              o_busy
    );
    
    // internal signal
    reg     [4:0]       round_ctr; // Bo dem vong 0 -> 23
    reg     [1599:0]    current_state;
    wire    [1599:0]    next_state_logic; // wire from output of module keccak_round
    reg     [63:0]      round_const;
    
    // ROUND CONST NIST FIPS 202
    always @(*) begin
        case (round_ctr) 
            5'd00: round_const = 64'h0000000000000001;
            5'd01: round_const = 64'h0000000000008082;
            5'd02: round_const = 64'h800000000000808A;
            5'd03: round_const = 64'h8000000080008000;
            5'd04: round_const = 64'h000000000000808B;
            5'd05: round_const = 64'h0000000080000001;
            5'd06: round_const = 64'h8000000080008081;
            5'd07: round_const = 64'h8000000000008009;
            5'd08: round_const = 64'h000000000000008A;
            5'd09: round_const = 64'h0000000000000088;
            5'd10: round_const = 64'h0000000080008009;
            5'd11: round_const = 64'h000000008000000A;
            5'd12: round_const = 64'h000000008000808B;
            5'd13: round_const = 64'h800000000000008B;
            5'd14: round_const = 64'h8000000000008089;
            5'd15: round_const = 64'h8000000000008003;
            5'd16: round_const = 64'h8000000000008002;
            5'd17: round_const = 64'h8000000000000080;
            5'd18: round_const = 64'h000000000000800A;
            5'd19: round_const = 64'h800000008000000A;
            5'd20: round_const = 64'h8000000080008081;
            5'd21: round_const = 64'h8000000000008080;
            5'd22: round_const = 64'h0000000080000001;
            5'd23: round_const = 64'h8000000080008008;
            default: round_const = 64'h0000000000000000;            
        endcase
    end
    
    // INSTANCE 
    keccak_round u_keccak_round (
        .i_state(current_state),
        .i_round_const(round_const),
        .o_state(next_state_logic)
    );
    
    // FSM to CONTROL
    localparam S_IDLE = 1'b0;
    localparam S_CALC = 1'b1;
    
    reg state_fsm;
    
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state_fsm       <= S_IDLE;
            round_ctr       <= 0;
            current_state   <= 0; 
            o_state         <= 0;
            o_done          <= 0;
            o_busy          <= 0;
        end
        else begin
            o_done <= 0;
            case (state_fsm)
                S_IDLE: begin
                    if (i_start) begin
                        // load input data which XORed with outside input block
                        current_state <= i_state;
                        //round_const   <= 0;
                        o_busy        <= 1;
                        state_fsm     <= S_CALC;
                    end
                    else begin
                        o_busy        <= 0;
                    end
                end
                
                S_CALC: begin
                    //update the result of keccak_round
                    current_state <= next_state_logic;
                    if (round_ctr == 5'd23) begin
                        o_state   <= next_state_logic; //save the last result
                        o_done    <= 1;
                        o_busy    <= 0;
                        state_fsm <= S_IDLE;
                    end
                    else begin
                        round_ctr <= round_ctr + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
