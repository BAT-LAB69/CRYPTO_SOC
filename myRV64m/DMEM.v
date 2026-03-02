`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// DMEM - Data Memory (Simple Dual-Port BRAM with Byte Write Enable)
//
// Follows Xilinx UG901 "Simple Dual Port RAM with Byte-wide Write Enable"
// template for guaranteed BRAM inference.
//
// Port A: Write with byte-granular write enable (for loop pattern)
// Port B: Read with enable
//////////////////////////////////////////////////////////////////////////////////

(* ram_style = "block" *)
module DMEM (
    input  wire        clk,
    input  wire        rst,
    // Read port (Port B)
    input  wire        rd_en,
    input  wire [63:0] rd_addr,
    output reg  [63:0] r_data,
    // Write port (Port A)
    input  wire [63:0] wr_addr,
    input  wire [63:0] w_data,
    input  wire [7:0]  we           // Byte write enables
);

    // Parameters matching UG901 template
    localparam NUM_COL    = 8;       // 8 bytes per word
    localparam COL_WIDTH  = 8;       // 8 bits per byte
    localparam ADDR_WIDTH = 13;      // log2(DMEM_DEPTH)

    (* ram_style = "block" *)  reg [NUM_COL*COL_WIDTH-1:0] dmem [0:`DMEM_DEPTH-1];

    wire [ADDR_WIDTH-1:0] rd_idx = rd_addr[15:3];
    wire [ADDR_WIDTH-1:0] wr_idx = wr_addr[15:3];

    // Port A: Byte-wide Write Enable (UG901 for loop template)
    integer i;
    always @(posedge clk) begin
        for (i = 0; i < NUM_COL; i = i + 1) begin
            if (we[i])
                dmem[wr_idx][i*COL_WIDTH +: COL_WIDTH] <= w_data[i*COL_WIDTH +: COL_WIDTH];
        end
    end

    // Port B: Synchronous Read
    always @(posedge clk) begin
        if (rd_en)
            r_data <= dmem[rd_idx];
    end

endmodule
