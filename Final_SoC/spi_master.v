// ============================================================
// SPI Master Core
// - 8-bit data width
// - Configurable CPOL, CPHA
// - Programmable clock divider (SCK = clk / (2 * (DIV+1)))
// - Full-duplex: shifts out MOSI while shifting in MISO
// ============================================================

module spi_master (
    input  wire        clk,
    input  wire        rst,

    // Control
    input  wire        start,       // Pulse to begin transfer
    input  wire [7:0]  tx_data,     // Data to transmit (MOSI)
    input  wire [7:0]  clk_div,     // Clock divider value
    input  wire        cpol,        // Clock polarity
    input  wire        cpha,        // Clock phase

    // Status
    output reg  [7:0]  rx_data,     // Received data (MISO)
    output reg         busy,        // Transfer in progress
    output reg         done,        // Pulse when transfer completes

    // SPI signals
    output reg         sck,         // SPI clock
    output reg         mosi,        // Master Out Slave In
    input  wire        miso,        // Master In Slave Out
    output reg         ss_n         // Slave Select (active low)
);

    // -------------------------------------------------------
    // Internal registers
    // -------------------------------------------------------
    reg [7:0] shift_reg;        // Shift register for TX/RX
    reg [3:0] bit_cnt;          // Bit counter (0-7)
    reg [7:0] div_cnt;          // Clock divider counter
    reg       sck_internal;     // Internal SCK before CPOL
    reg       sample_edge;      // Flag: sample MISO on this half
    reg       shift_edge;       // Flag: shift MOSI on this half

    // FSM states
    localparam IDLE     = 3'd0;
    localparam LEADING  = 3'd1;   // Leading edge of SCK
    localparam TRAILING = 3'd2;   // Trailing edge of SCK
    localparam FINISH   = 3'd3;

    reg [2:0] state;

    // -------------------------------------------------------
    // Main FSM
    // -------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            shift_reg    <= 8'h0;
            rx_data      <= 8'h0;
            bit_cnt      <= 4'd0;
            div_cnt      <= 8'd0;
            sck_internal <= 1'b0;
            mosi         <= 1'b0;
            ss_n         <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;
        end else begin
            done <= 1'b0; // Default: clear done pulse

            case (state)
                // ==================================
                // IDLE: Wait for start
                // ==================================
                IDLE: begin
                    sck_internal <= 1'b0;
                    ss_n         <= 1'b1;
                    busy         <= 1'b0;

                    if (start) begin
                        shift_reg <= tx_data;
                        bit_cnt   <= 4'd0;
                        div_cnt   <= 8'd0;
                        busy      <= 1'b1;
                        ss_n      <= 1'b0;   // Assert slave select

                        // CPHA=0: put first bit on MOSI immediately
                        if (!cpha) begin
                            mosi <= tx_data[7];
                        end

                        state <= LEADING;
                    end
                end

                // ==================================
                // LEADING edge of SCK
                // ==================================
                LEADING: begin
                    if (div_cnt == clk_div) begin
                        div_cnt      <= 8'd0;
                        sck_internal <= 1'b1;

                        if (cpha == 1'b0) begin
                            // CPHA=0: sample MISO on leading edge
                            shift_reg <= {shift_reg[6:0], miso};
                        end else begin
                            // CPHA=1: shift MOSI on leading edge
                            mosi <= shift_reg[7];
                        end

                        state <= TRAILING;
                    end else begin
                        div_cnt <= div_cnt + 1'b1;
                    end
                end

                // ==================================
                // TRAILING edge of SCK
                // ==================================
                TRAILING: begin
                    if (div_cnt == clk_div) begin
                        div_cnt      <= 8'd0;
                        sck_internal <= 1'b0;

                        if (cpha == 1'b0) begin
                            // CPHA=0: shift MOSI on trailing edge
                            mosi <= shift_reg[7];
                        end else begin
                            // CPHA=1: sample MISO on trailing edge
                            shift_reg <= {shift_reg[6:0], miso};
                        end

                        bit_cnt <= bit_cnt + 1'b1;

                        if (bit_cnt == 4'd7) begin
                            state <= FINISH;
                        end else begin
                            state <= LEADING;
                        end
                    end else begin
                        div_cnt <= div_cnt + 1'b1;
                    end
                end

                // ==================================
                // FINISH: Latch result, deassert SS
                // ==================================
                FINISH: begin
                    rx_data <= shift_reg;
                    ss_n    <= 1'b1;
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    // -------------------------------------------------------
    // Apply CPOL: invert SCK if CPOL=1
    // -------------------------------------------------------
    always @(*) begin
        sck = cpol ? ~sck_internal : sck_internal;
    end

endmodule
