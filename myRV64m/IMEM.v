`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// IMEM - Instruction Memory (Single Port ROM, BRAM)
//
// Follows Xilinx UG901 Single Port ROM template for BRAM inference.
// NO reset on output, NO enable condition that blocks BRAM.
//////////////////////////////////////////////////////////////////////////////////

(* ram_style = "block" *)
module IMEM (
    input  wire        clk,
    input  wire        rst,
    input  wire        rd_en,
    input  wire [63:0] addr,
    output reg  [31:0] inst_out
);

    (* ram_style = "block" *)  reg [31:0] imem [0:`IMEM_DEPTH-1] /* verilator public_flat_rw */;

    wire [11:0] word_addr = addr[13:2]; // Word-aligned: 4096 entries

    // Initialize memory
    integer idx;
    initial begin
        for (idx = 0; idx < `IMEM_DEPTH; idx = idx + 1)
            imem[idx] = `NOP_INST;
    end

    // UG901 Single Port ROM template
    always @(posedge clk) begin
        if (rd_en)
            inst_out <= imem[word_addr];
    end

endmodule
