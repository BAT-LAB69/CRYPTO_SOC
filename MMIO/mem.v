


module crypto_periph_top(
    input wire clk,
    input wire rst,

    input wire [31:0] addr,
    input wire [31:0] wdata,
    input wire we,
    input wire valid,
    output wire [31:0] rdata,
    output wire ready
);

    wire [31:0] r_aes, r_rsa, r_ed, r_shake, r_ram;
    wire rd_aes, rd_rsa, rd_ed, rd_shake, rd_ram;

    aes_gcm_mm #(.BASE_ADDR(32'h4000_0000)) 
    u_aes (.clk(clk),.rst(rst),.addr(addr),.wdata(wdata),.we(we),.valid(valid),.rdata(r_aes),.ready(rd_aes));

    ed25519_shake128_mm #(.BASE_ADDR(32'h4000_1000)) 
    u_ed    (.clk(clk),.rst(rst),.addr(addr),.wdata(wdata),.we(we),.valid(valid),.rdata(r_ed),.ready(rd_ed));
    
    bike_mm #(.BASE_ADDR(32'h4000_2000)) 
    u_shake (.clk(clk),.rst(rst),.addr(addr),.wdata(wdata),.we(we),.valid(valid),.rdata(r_shake),.ready(rd_shake));
    
    rsa_mm #(.BASE_ADDR(32'h4000_3000))
    u_rsa (.clk(clk),.rst(rst),.addr(addr),.wdata(wdata),.we(we),.valid(valid),.rdata(r_rsa),.ready(rd_rsa));
    
    ram_mm #(.BASE_ADDR(32'h4000_4000))
    u_ram (.clk(clk),.rst(rst),.addr(addr),.wdata(wdata),.we(we),.valid(valid),.rdata(r_ram),.ready(rd_ram));

    assign rdata =
        rd_aes   ? r_aes   :
        rd_rsa   ? r_rsa   :
        rd_ed    ? r_ed    :
        rd_shake ? r_shake :
        rd_ram   ? r_ram   :
        32'h0;

    assign ready = rd_aes | rd_rsa | rd_ed | rd_shake | rd_ram;

endmodule

/////////////////// NORMAL RAM ////////////////////

module ram_mm #(
    parameter BASE_ADDR = 32'h4000_4000,
    parameter RAM_WORDS = 1024
)(
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        we,
    input  wire        valid,
    output reg  [31:0] rdata,
    output reg         ready
);

    wire sel = (addr[31:12] >= BASE_ADDR[31:12]);
    (* ram_style="block" *)
    reg [31:0] ram [0:RAM_WORDS-1];

    always @(posedge clk) begin
        ready <= 0;

        if(valid && sel) begin
            ready <= 1;

            if(we)
                ram[addr] <= wdata;
            else
                rdata <= ram[addr];
        end
    end

endmodule