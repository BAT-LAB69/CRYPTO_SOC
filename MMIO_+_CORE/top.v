`include "picorv32.v"
`include "mem.v"

module soc_top(
    input wire clk,
    input wire rst
);


// PicoRV32 wires

wire        mem_valid;
wire        mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0]  mem_wstrb;
wire [31:0] mem_rdata;


// mem wires

wire [31:0] rdata;
wire        ready;


picorv32 picorv32 (
    .clk(clk),
    .resetn(!rst),

    .mem_valid(mem_valid),
    .mem_ready(mem_ready),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb),
    .mem_rdata(mem_rdata)
);


mem_top crypto (
    .clk(clk),
    .rst(rst),

    .addr(mem_addr),
    .wdata_in(mem_wdata),
    .wstrb(mem_wstrb),
    .we(|mem_wstrb),
    .valid(mem_valid),
    .rdata(rdata),
    .ready(ready)
);

endmodule