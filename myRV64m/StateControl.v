`include "defines.vh"

module StateControl (
    input  wire clk,
    input  wire rst,
    input  wire start_in,
    input  wire done_flag,
    output reg  state_start,
    output reg  state_done
);

    always @(posedge clk) begin
        if (!rst) begin
            state_start <= 1'b0;
            state_done  <= 1'b0;
        end
        else begin
            if (start_in) begin
                state_start <= 1'b1;
                if (done_flag) begin
                    state_done  <= 1'b1;
                    state_start <= 1'b0;
                end
            end
            else begin
                state_start <= 1'b0;
            end
        end
    end

endmodule
