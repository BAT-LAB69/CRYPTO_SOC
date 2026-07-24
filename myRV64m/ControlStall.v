`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// ControlStall - EX-stage Branch Flush Control
// Generates flush for both IF/ID and ID/EX when branch taken in EX.
// 2-cycle branch penalty.
//////////////////////////////////////////////////////////////////////////////////

module ControlStall (
    input  wire        clk,
    input  wire        rst,
    input  wire        ex_branch_taken, // Branch taken signal from EX stage
    (* max_fanout = "32" *) output reg IF_ID_flush,
    (* max_fanout = "32" *) output reg ID_EX_flush
);

    // Register the flush signal so Vivado can replicate these registers
    // to reduce fanout on the pipeline clears.
    always @(posedge clk) begin
        if (!rst) begin
            IF_ID_flush <= 1'b0;
            ID_EX_flush <= 1'b0;
        end else begin
            // When a branch is taken, we signal a flush for the NEXT cycle
            IF_ID_flush <= ex_branch_taken;
            ID_EX_flush <= ex_branch_taken;
        end
    end

endmodule
