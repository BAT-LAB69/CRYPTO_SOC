`include "defines.vh"

module PC (
    input  wire        clk,
    input  wire        rst,       // Synchronous reset (active low)
    input  wire        en,        // Enable (0 = stall)
    input  wire [63:0] pc_in,     // Next PC value
    output reg  [63:0] pc_out     // Current PC value
);

    always @(posedge clk) begin
        if (!rst)
            pc_out <= `ZERO;
        else if (en) begin
            pc_out <= pc_in;
            if (pc_in == 64'b0) begin
                $display("PC is returning to 0 at time %0t!", $time);
            end
        end
    end

endmodule
