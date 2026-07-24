// ============================================================
// SPI Master - Memory Mapped Wrapper
// ============================================================
// Memory Map (Base + offset):
//   0x000 : CTRL   (Write: bit[0] = start transfer)
//   0x004 : STATUS (Read:  bit[0] = done, bit[1] = busy)
//   0x008 : TXDATA (Write: 8-bit data to transmit)
//   0x00C : RXDATA (Read:  8-bit received data)
//   0x010 : CLKDIV (Write: 8-bit clock divider)
//   0x014 : CONFIG (Write: bit[0] = CPOL, bit[1] = CPHA)
// ============================================================

module spi_mm #(
    parameter BASE_ADDR = 32'h4000_6000
)(
    input  wire        clk,
    input  wire        rst,

    // PicoRV32 bus
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        we,
    input  wire        valid,
    output reg  [31:0] rdata,
    output reg         ready,

    // SPI external pins
    output wire        spi_sck,
    output wire        spi_mosi,
    input  wire        spi_miso,
    output wire        spi_ss_n
);

    wire sel = (addr[31:12] == BASE_ADDR[31:12]);
    wire [11:0] offset = addr[11:0];

    // -------------------------------------------------------
    // Control registers
    // -------------------------------------------------------
    reg        start_reg;
    reg [7:0]  tx_data_reg;
    reg [7:0]  clk_div_reg;
    reg        cpol_reg;
    reg        cpha_reg;

    // -------------------------------------------------------
    // SPI Core wires
    // -------------------------------------------------------
    wire [7:0] rx_data;
    wire       spi_busy;
    wire       spi_done;

    // -------------------------------------------------------
    // Latch done flag (cleared on STATUS read)
    // -------------------------------------------------------
    reg done_latched;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done_latched <= 1'b0;
        end else begin
            if (spi_done)
                done_latched <= 1'b1;
            // Clear when CPU reads STATUS register
            else if (valid && sel && !we && offset == 12'h004)
                done_latched <= 1'b0;
        end
    end

    // -------------------------------------------------------
    // Latch RX data when transfer completes
    // -------------------------------------------------------
    reg [7:0] rx_data_latched;

    always @(posedge clk or posedge rst) begin
        if (rst)
            rx_data_latched <= 8'h0;
        else if (spi_done)
            rx_data_latched <= rx_data;
    end

    // -------------------------------------------------------
    // Auto-clear start after 1 cycle
    // -------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            start_reg <= 1'b0;
        else if (start_reg)
            start_reg <= 1'b0;
    end

    // -------------------------------------------------------
    // Bus Write
    // -------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_data_reg <= 8'h0;
            clk_div_reg <= 8'd4;    // Default divider
            cpol_reg    <= 1'b0;
            cpha_reg    <= 1'b0;
        end else if (valid && sel && we) begin
            case (offset)
                12'h000: start_reg   <= wdata[0];
                12'h008: tx_data_reg <= wdata[7:0];
                12'h010: clk_div_reg <= wdata[7:0];
                12'h014: begin
                    cpol_reg <= wdata[0];
                    cpha_reg <= wdata[1];
                end
                default: ;
            endcase
        end
    end

    // -------------------------------------------------------
    // Bus Read
    // -------------------------------------------------------
    always @(posedge clk) begin
        ready <= 1'b0;
        rdata <= 32'h0;

        if (valid && sel) begin
            ready <= 1'b1;

            if (!we) begin
                case (offset)
                    12'h004: rdata <= {30'b0, spi_busy, done_latched};
                    12'h00C: rdata <= {24'b0, rx_data_latched};
                    12'h010: rdata <= {24'b0, clk_div_reg};
                    12'h014: rdata <= {30'b0, cpha_reg, cpol_reg};
                    default: rdata <= 32'hDEAD_DEAD;
                endcase
            end
        end
    end

    // -------------------------------------------------------
    // SPI Master Core Instance
    // -------------------------------------------------------
    spi_master u_spi_master (
        .clk     (clk),
        .rst     (rst),
        .start   (start_reg),
        .tx_data (tx_data_reg),
        .clk_div (clk_div_reg),
        .cpol    (cpol_reg),
        .cpha    (cpha_reg),
        .rx_data (rx_data),
        .busy    (spi_busy),
        .done    (spi_done),
        .sck     (spi_sck),
        .mosi    (spi_mosi),
        .miso    (spi_miso),
        .ss_n    (spi_ss_n)
    );

endmodule
