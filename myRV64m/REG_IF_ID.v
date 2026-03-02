`include "defines.vh"

module REG_IF_ID (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        flush,
    input  wire [31:0] inst_in,
    input  wire [63:0] pc_in,
    output reg  [31:0] inst_out,
    output reg  [63:0] pc_out
);

    always @(posedge clk) begin
        if (!rst) begin
            inst_out <= `NOP_INST;
            pc_out   <= `ZERO;
        end
        else if (flush) begin
            inst_out <= `NOP_INST;
            pc_out   <= `ZERO;
        end
        else if (en) begin
            inst_out <= inst_in;
            pc_out   <= pc_in;
        end
    end

endmodule
