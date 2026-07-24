`include "defines.vh"

module RegFile (
    input  wire        clk,
    input  wire        rst,
    input  wire        we,            // Write enable (RegWrite)
    input  wire [4:0]  r_addr1,       // Read address 1 (rs1)
    input  wire [4:0]  r_addr2,       // Read address 2 (rs2)
    input  wire [4:0]  w_addr,        // Write address (rd)
    input  wire [63:0] w_data,        // Write data
    output wire [63:0] r_data1,       // Read data 1
    output wire [63:0] r_data2        // Read data 2
);

    reg [63:0] registers [0:31] /* verilator public_flat_rw */;

    // Synchronous write, synchronous reset
    integer idx;
    always @(posedge clk) begin
        if (!rst) begin
            for (idx = 0; idx < 32; idx = idx + 1)
                registers[idx] <= 64'b0;
        end
        else begin
            if (we && (w_addr != 5'b0))
                registers[w_addr] <= w_data;
        end
    end

    // Combinational read with internal write-forwarding
    assign r_data1 = (r_addr1 == 5'b0) ? 64'b0 : 
                     (we && (w_addr == r_addr1)) ? w_data : 
                     registers[r_addr1];

    assign r_data2 = (r_addr2 == 5'b0) ? 64'b0 : 
                     (we && (w_addr == r_addr2)) ? w_data : 
                     registers[r_addr2];

endmodule
