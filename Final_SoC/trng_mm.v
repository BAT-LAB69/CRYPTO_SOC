module trng_mm #(
    parameter BASE_ADDR = 32'h4000_5000
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

    // -------------------------------------------------------
    // TRNG Memory Map (Base + offset):
    //   0x00 : Control Register  (Write: bit[0] = enable)
    //   0x04 : Status Register   (Read:  bit[0] = data_valid)
    //   0x08 : Data Register     (Read:  32-bit random word)
    // -------------------------------------------------------

    wire sel = (addr[31:12] == BASE_ADDR[31:12]);
    wire [11:0] offset = addr[11:0];

    // Control
    reg trng_enable;

    // TRNG Core wires
    wire [31:0] trng_data;
    wire        trng_valid;

    // Latch random data when valid
    reg [31:0] trng_data_latched;
    reg        trng_data_ready;

    top_trng u_trng (
        .clk(clk),
        .rst(rst),
        .enable(trng_enable),
        .data_out(trng_data),
        .data_valid(trng_valid)
    );

    // Latch data when TRNG produces a new word
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            trng_data_latched <= 32'h0;
            trng_data_ready   <= 1'b0;
        end else begin
            if (trng_valid) begin
                trng_data_latched <= trng_data;
                trng_data_ready   <= 1'b1;
            end
            // Clear ready flag when CPU reads the data register
            if (valid && sel && !we && offset == 12'h008) begin
                trng_data_ready <= 1'b0;
            end
        end
    end

    // Write: Control register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            trng_enable <= 1'b0;
        end else if (valid && sel && we && offset == 12'h000) begin
            trng_enable <= wdata[0];
        end
    end

    // Read mux
    always @(posedge clk) begin
        ready <= 0;
        rdata <= 32'h0;

        if (valid && sel) begin
            ready <= 1;

            if (!we) begin
                case (offset)
                    12'h000: rdata <= {31'b0, trng_enable};
                    12'h004: rdata <= {31'b0, trng_data_ready};
                    12'h008: rdata <= trng_data_latched;
                    default: rdata <= 32'hDEAD_DEAD;
                endcase
            end
        end
    end

endmodule
