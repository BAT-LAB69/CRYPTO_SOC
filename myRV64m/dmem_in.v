`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// dmem_in - Data Memory Write Formatter
// Uses explicit case statements instead of multiplications for ASIC optimization.
//////////////////////////////////////////////////////////////////////////////////

module dmem_in (
    input  wire [2:0]  size,
    input  wire        dmem_write,
    input  wire [63:0] data_in,
    input  wire [63:0] addr,
    output reg  [7:0]  web,
    output reg  [63:0] data_out
);

    always @(*) begin
        if (dmem_write) begin
            case (size)
                3'd0: begin // SB - Store Byte
                    case (addr[2:0])
                        3'd0: begin web = 8'h01; data_out = {56'b0, data_in[7:0]};       end
                        3'd1: begin web = 8'h02; data_out = {48'b0, data_in[7:0],  8'b0}; end
                        3'd2: begin web = 8'h04; data_out = {40'b0, data_in[7:0], 16'b0}; end
                        3'd3: begin web = 8'h08; data_out = {32'b0, data_in[7:0], 24'b0}; end
                        3'd4: begin web = 8'h10; data_out = {24'b0, data_in[7:0], 32'b0}; end
                        3'd5: begin web = 8'h20; data_out = {16'b0, data_in[7:0], 40'b0}; end
                        3'd6: begin web = 8'h40; data_out = { 8'b0, data_in[7:0], 48'b0}; end
                        3'd7: begin web = 8'h80; data_out = {       data_in[7:0], 56'b0}; end
                        default: begin web = 8'h01; data_out = {56'b0, data_in[7:0]}; end
                    endcase
                end
                3'd1: begin // SH - Store Half
                    case (addr[2:1])
                        2'd0: begin web = 8'h03; data_out = {48'b0, data_in[15:0]};        end
                        2'd1: begin web = 8'h0C; data_out = {32'b0, data_in[15:0], 16'b0}; end
                        2'd2: begin web = 8'h30; data_out = {16'b0, data_in[15:0], 32'b0}; end
                        2'd3: begin web = 8'hC0; data_out = {       data_in[15:0], 48'b0}; end
                        default: begin web = 8'h03; data_out = {48'b0, data_in[15:0]}; end
                    endcase
                end
                3'd2: begin // SW - Store Word
                    case (addr[2])
                        1'b0: begin web = 8'h0F; data_out = {32'b0, data_in[31:0]};        end
                        1'b1: begin web = 8'hF0; data_out = {       data_in[31:0], 32'b0}; end
                        default: begin web = 8'h0F; data_out = {32'b0, data_in[31:0]}; end
                    endcase
                end
                3'd3: begin // SD - Store Double
                    web      = 8'hFF;
                    data_out = data_in;
                end
                default: begin
                    web      = 8'h00;
                    data_out = 64'b0;
                end
            endcase
        end
        else begin
            web      = 8'h00;
            data_out = 64'b0;
        end
    end

endmodule
