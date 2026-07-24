module mem_top(
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] addr,
    input  wire [31:0] wdata_in,
    input  wire [3:0]  wstrb,
    input  wire        we,
    input  wire        valid,
    output reg  [31:0] rdata,
    output reg         ready
);

  
    reg [31:0] wdata;
    
    always @(*) begin

        if (wstrb[0] == 1) wdata[7:0]   <= wdata_in[7:0];
        if (wstrb[1] == 1) wdata[15:8]  <= wdata_in[15:8];
        if (wstrb[2] == 1) wdata[23:16] <= wdata_in[23:16];
        if (wstrb[3] == 1) wdata[31:24] <= wdata_in[31:24];
        
        //load_data_from_dmem <= mem_array[{addr_to_dmem[AddrMsb:AddrLsb]}];
    end

    wire [31:0] r_aes, r_rsa, r_ed, r_shake, r_ram;
    wire rd_aes, rd_rsa, rd_ed, rd_shake, rd_ram;

    // -------------------------
    // Instantiate blocks
    // -------------------------
    aes_gcm_mm #(.BASE_ADDR(32'h4000_0000))
    u_aes (
        .clk(clk), .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .we(we),
        .valid(valid),
        .rdata(r_aes),
        .ready(rd_aes)
    );

    ed25519_shake128_mm #(.BASE_ADDR(32'h4000_1000))
    u_ed (
        .clk(clk), .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .we(we),
        .valid(valid),
        .rdata(r_ed),
        .ready(rd_ed)
    );

    bike_mm #(.BASE_ADDR(32'h4000_2000))
    u_bike (
        .clk(clk), .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .we(we),
        .valid(valid),
        .rdata(r_shake),
        .ready(rd_shake)
    );

    rsa_mm #(.BASE_ADDR(32'h4000_3000))
    u_rsa (
        .clk(clk), .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .we(we),
        .valid(valid),
        .rdata(r_rsa),
        .ready(rd_rsa)
    );

    ram_mm #(.BASE_ADDR(32'h4000_4000))
    u_ram (
        .clk(clk), .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .we(we),
        .valid(valid),
        .rdata(r_ram),
        .ready(rd_ram)
    );

    // -------------------------
    // Safe mux
    // -------------------------
    always @(*) begin
        rdata = 32'h0;
        ready = 1'b0;

        if (rd_aes) begin
            rdata = r_aes;
            ready = 1'b1;
        end
        else if (rd_ed) begin
            rdata = r_ed;
            ready = 1'b1;
        end
        else if (rd_shake) begin
            rdata = r_shake;
            ready = 1'b1;
        end
        else if (rd_rsa) begin
            rdata = r_rsa;
            ready = 1'b1;
        end
        else if (rd_ram) begin
            rdata = r_ram;
            ready = 1'b1;
        end
    end


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
                ram[(addr - BASE_ADDR) >> 2] <= wdata;
            else
                rdata <= ram[(addr - BASE_ADDR) >> 2];
        end
    end

endmodule