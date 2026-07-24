`timescale 1ns/1ps

// ============================================================
// SPI Master Testbench
// - Simulates a simple SPI slave (loopback with bit-invert)
// - CPU writes TX data via MMIO, triggers transfer, reads RX
// ============================================================

module tb_spi;

    reg         clk, rst;
    reg  [31:0] addr, wdata;
    reg         we, valid;
    wire [31:0] rdata;
    wire        ready;

    // SPI wires
    wire spi_sck, spi_mosi, spi_ss_n;
    reg  spi_miso;

    // -------------------------------------------------------
    // DUT: SPI Memory-Mapped Wrapper
    // -------------------------------------------------------
    spi_mm #(.BASE_ADDR(32'h4000_6000)) dut (
        .clk(clk), .rst(rst),
        .addr(addr), .wdata(wdata),
        .we(we), .valid(valid),
        .rdata(rdata), .ready(ready),
        .spi_sck(spi_sck),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_ss_n(spi_ss_n)
    );

    // -------------------------------------------------------
    // Clock: 10ns period (100 MHz)
    // -------------------------------------------------------
    always #5 clk = ~clk;

    // -------------------------------------------------------
    // Simple SPI Slave Model: loopback MOSI -> MISO
    // (shifts in MOSI on rising SCK, shifts out on falling)
    // -------------------------------------------------------
    reg [7:0] slave_shift;
    reg [3:0] slave_bit_cnt;
    reg       slave_active;

    // Detect SCK edges
    reg sck_prev;
    wire sck_posedge_w = (spi_sck && !sck_prev);
    wire sck_negedge_w = (!spi_sck && sck_prev);

    always @(posedge clk) begin
        sck_prev <= spi_sck;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slave_shift   <= 8'hA5;  // Pre-loaded slave response
            slave_bit_cnt <= 4'd0;
            slave_active  <= 1'b0;
            spi_miso      <= 1'b1;
        end else begin
            if (spi_ss_n) begin
                // SS deasserted, reset
                slave_shift   <= 8'hA5;
                slave_bit_cnt <= 4'd0;
                slave_active  <= 1'b1;
                spi_miso      <= 1'b1;
            end else begin
                // SS asserted (active low)
                if (!slave_active) begin
                    slave_active <= 1'b1;
                    spi_miso <= slave_shift[7]; // Put MSB on MISO
                end

                // Mode 0 (CPOL=0, CPHA=0): sample on posedge, shift on negedge
                if (sck_posedge_w) begin
                    slave_shift <= {slave_shift[6:0], spi_mosi};
                    slave_bit_cnt <= slave_bit_cnt + 1'b1;
                end
                if (sck_negedge_w) begin
                    spi_miso <= slave_shift[7];
                end
            end
        end
    end

    // -------------------------------------------------------
    // Bus access tasks
    // -------------------------------------------------------
    task bus_write(input [31:0] a, input [31:0] d);
        begin
            @(posedge clk);
            addr  <= a;
            wdata <= d;
            we    <= 1'b1;
            valid <= 1'b1;
            @(posedge clk);
            while (!ready) @(posedge clk);
            valid <= 1'b0;
            we    <= 1'b0;
        end
    endtask

    task bus_read(input [31:0] a, output [31:0] d);
        begin
            @(posedge clk);
            addr  <= a;
            we    <= 1'b0;
            valid <= 1'b1;
            @(posedge clk);
            while (!ready) @(posedge clk);
            d = rdata;
            valid <= 1'b0;
        end
    endtask

    // -------------------------------------------------------
    // Main test
    // -------------------------------------------------------
    reg [31:0] status, rx;
    integer timeout;

    initial begin
        $dumpfile("spi_wave.vcd");
        $dumpvars(0, tb_spi);

        clk = 0; rst = 1;
        addr = 0; wdata = 0; we = 0; valid = 0;
        spi_miso = 1;
        sck_prev = 0;

        #30 rst = 0;
        #20;

        $display("===========================================");
        $display("[SPI] Test Start");
        $display("===========================================");

        // 1. Configure: CPOL=0, CPHA=0 (Mode 0)
        bus_write(32'h4000_6014, 32'h0000_0000);
        $display("[SPI] Config: Mode 0 (CPOL=0, CPHA=0)");

        // 2. Set clock divider = 4
        bus_write(32'h4000_6010, 32'h0000_0004);
        $display("[SPI] Clock divider = 4");

        // 3. Write TX data = 0x5A
        bus_write(32'h4000_6008, 32'h0000_005A);
        $display("[SPI] TX data = 0x5A");

        // 4. Start transfer
        bus_write(32'h4000_6000, 32'h0000_0001);
        $display("[SPI] Transfer started...");

        // 5. Poll STATUS until done
        timeout = 0;
        status = 0;
        while (!(status & 32'h1)) begin
            bus_read(32'h4000_6004, status);
            timeout = timeout + 1;
            if (timeout > 1000) begin
                $display("[SPI] ERROR: Timeout waiting for done!");
                $finish;
            end
        end
        $display("[SPI] Transfer complete! (polled %0d times)", timeout);

        // 6. Read RX data
        bus_read(32'h4000_600C, rx);
        $display("[SPI] RX data = 0x%h", rx[7:0]);

        // 7. Second transfer: TX = 0xF0
        bus_write(32'h4000_6008, 32'h0000_00F0);
        bus_write(32'h4000_6000, 32'h0000_0001);
        $display("[SPI] Second transfer: TX = 0xF0");

        timeout = 0;
        status = 0;
        while (!(status & 32'h1)) begin
            bus_read(32'h4000_6004, status);
            timeout = timeout + 1;
            if (timeout > 1000) begin
                $display("[SPI] ERROR: Timeout!");
                $finish;
            end
        end

        bus_read(32'h4000_600C, rx);
        $display("[SPI] RX data = 0x%h", rx[7:0]);

        $display("===========================================");
        $display("[SPI] All Tests Completed Successfully!");
        $display("===========================================");
        #100;
        $finish;
    end

    // Safety timeout
    initial begin
        #500000;
        $display("[SPI] Global Timeout!");
        $finish;
    end

endmodule
