`include "defines.vh"

module dmem_out (
    input  wire [2:0]  size,
    input  wire [63:0] data_in,
    input  wire [63:0] addr,
    output reg  [63:0] data_out
);

    always @(*) begin
        case (size)
            3'd0: begin // LB
                case (addr[2:0])
                    3'd0: data_out = {{56{data_in[ 7]}}, data_in[ 7: 0]};
                    3'd1: data_out = {{56{data_in[15]}}, data_in[15: 8]};
                    3'd2: data_out = {{56{data_in[23]}}, data_in[23:16]};
                    3'd3: data_out = {{56{data_in[31]}}, data_in[31:24]};
                    3'd4: data_out = {{56{data_in[39]}}, data_in[39:32]};
                    3'd5: data_out = {{56{data_in[47]}}, data_in[47:40]};
                    3'd6: data_out = {{56{data_in[55]}}, data_in[55:48]};
                    3'd7: data_out = {{56{data_in[63]}}, data_in[63:56]};
                    default: data_out = {{56{data_in[7]}}, data_in[7:0]};
                endcase
            end
            3'd1: begin // LH
                case (addr[2:1])
                    2'd0: data_out = {{48{data_in[15]}}, data_in[15: 0]};
                    2'd1: data_out = {{48{data_in[31]}}, data_in[31:16]};
                    2'd2: data_out = {{48{data_in[47]}}, data_in[47:32]};
                    2'd3: data_out = {{48{data_in[63]}}, data_in[63:48]};
                    default: data_out = {{48{data_in[15]}}, data_in[15:0]};
                endcase
            end
            3'd2: begin // LW
                case (addr[2])
                    1'b0: data_out = {{32{data_in[31]}}, data_in[31: 0]};
                    1'b1: data_out = {{32{data_in[63]}}, data_in[63:32]};
                    default: data_out = {{32{data_in[31]}}, data_in[31:0]};
                endcase
            end
            3'd3: data_out = data_in; // LD
            3'd4: begin // LBU
                case (addr[2:0])
                    3'd0: data_out = {56'b0, data_in[ 7: 0]};
                    3'd1: data_out = {56'b0, data_in[15: 8]};
                    3'd2: data_out = {56'b0, data_in[23:16]};
                    3'd3: data_out = {56'b0, data_in[31:24]};
                    3'd4: data_out = {56'b0, data_in[39:32]};
                    3'd5: data_out = {56'b0, data_in[47:40]};
                    3'd6: data_out = {56'b0, data_in[55:48]};
                    3'd7: data_out = {56'b0, data_in[63:56]};
                    default: data_out = {56'b0, data_in[7:0]};
                endcase
            end
            3'd5: begin // LHU
                case (addr[2:1])
                    2'd0: data_out = {48'b0, data_in[15: 0]};
                    2'd1: data_out = {48'b0, data_in[31:16]};
                    2'd2: data_out = {48'b0, data_in[47:32]};
                    2'd3: data_out = {48'b0, data_in[63:48]};
                    default: data_out = {48'b0, data_in[15:0]};
                endcase
            end
            3'd6: begin // LWU
                case (addr[2])
                    1'b0: data_out = {32'b0, data_in[31: 0]};
                    1'b1: data_out = {32'b0, data_in[63:32]};
                    default: data_out = {32'b0, data_in[31:0]};
                endcase
            end
            default: data_out = data_in;
        endcase
    end

endmodule
