`timescale 1ns / 1ps
`include "defines.vh"

module RV64_Full_tb;

    reg        clk;
    reg        rst;
    reg        start_in;
    wire       complete_out;
    wire       debug_out;

    parameter CLK_PERIOD = 20;
    always #(CLK_PERIOD/2) clk = ~clk;

    RV64M_top dut (
        .clk          (clk),
        .rst          (rst),
        .start_in     (start_in),
        .complete_out (complete_out),
        .debug_out    (debug_out)
    );

    integer i, pass_count, fail_count;

    integer i, pass_count, fail_count;

    task check_reg;
        input [4:0]  reg_num;
        input [63:0] expected;
        input [255:0] test_name; 
        begin
            if (dut.u_regfile.registers[reg_num] === expected) begin
                $display("  PASS: x%0d = %0d (0x%016h) - %0s",
                    reg_num, $signed(expected), expected, test_name);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: x%0d expected %0d (0x%016h), got %0d (0x%016h) - %0s",
                    reg_num, $signed(expected), expected,
                    $signed(dut.u_regfile.registers[reg_num]),
                    dut.u_regfile.registers[reg_num], test_name);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 0;
        start_in = 0;

        dut.u_imem.imem[0] = 32'h00A00093; // ADDI x1, x0, 10
        dut.u_imem.imem[1] = 32'h00300113; // ADDI x2, x0, 3
        dut.u_imem.imem[2] = 32'hFFB00193; // ADDI x3, x0, -5
        dut.u_imem.imem[3] = 32'hFF900213; // ADDI x4, x0, -7
        dut.u_imem.imem[4] = 32'h01400293; // ADDI x5, x0, 20
        dut.u_imem.imem[5] = 32'h00000313; // ADDI x6, x0, 0
        dut.u_imem.imem[6] = 32'h00000013; // NOP
        dut.u_imem.imem[7] = 32'h005083B3; // ADD  x7, x1, x5
        dut.u_imem.imem[8] = 32'h40128433; // SUB  x8, x5, x1
        dut.u_imem.imem[9] = 32'h0050F4B3; // AND  x9, x1, x5
        dut.u_imem.imem[10] = 32'h0050E533; // OR   x10, x1, x5
        dut.u_imem.imem[11] = 32'h0050C5B3; // XOR  x11, x1, x5
        dut.u_imem.imem[12] = 32'h00509633; // SLL  x12, x1, x5
        dut.u_imem.imem[13] = 32'h001656B3; // SRL  x13, x12, x1
        dut.u_imem.imem[14] = 32'h0050A733; // SLT  x14, x1, x5
        dut.u_imem.imem[15] = 32'h0012B7B3; // SLTU x15, x5, x1
        dut.u_imem.imem[16] = 32'h00F0E813; // ORI  x16, x1, 15
        dut.u_imem.imem[17] = 32'h00F0F893; // ANDI x17, x1, 15
        dut.u_imem.imem[18] = 32'h0FF0C913; // XORI x18, x1, 255
        dut.u_imem.imem[19] = 32'h00409993; // SLLI x19, x1, 4
        dut.u_imem.imem[20] = 32'h0029DA13; // SRLI x20, x19, 2
        dut.u_imem.imem[21] = 32'h4011DA93; // SRAI x21, x3, 1
        dut.u_imem.imem[22] = 32'h11111B37; // LUI  x22, 69905
        dut.u_imem.imem[23] = 32'h00001B97; // AUIPC x23, 1
        dut.u_imem.imem[24] = 32'h06400C1B; // ADDIW x24, x0, 100
        dut.u_imem.imem[25] = 32'hFCE00C9B; // ADDIW x25, x0, -50
        dut.u_imem.imem[26] = 32'h019C0D3B; // ADDW  x26, x24, x25
        dut.u_imem.imem[27] = 32'h00103023; // SD   x1, 0(x0)
        dut.u_imem.imem[28] = 32'h00503423; // SD   x5, 8(x0)
        dut.u_imem.imem[29] = 32'h00003D83; // LD   x27, 0(x0)
        dut.u_imem.imem[30] = 32'h00803E03; // LD   x28, 8(x0)
        dut.u_imem.imem[31] = 32'h02208EB3; // MUL  x29, x1, x2
        dut.u_imem.imem[32] = 32'h02219F33; // MULH x30, x3, x2
        dut.u_imem.imem[33] = 32'h0221AFB3; // MULHSU x31, x3, x2
        dut.u_imem.imem[34] = 32'h0220B0B3; // MULHU x1, x1, x2
        dut.u_imem.imem[35] = 32'h03B54133; // DIV  x2, x10, x27
        dut.u_imem.imem[36] = 32'h03B561B3; // REM  x3, x10, x27
        dut.u_imem.imem[37] = 32'h00000013; // NOP
        dut.u_imem.imem[38] = 32'h00000013; // NOP
        dut.u_imem.imem[39] = 32'h00000013; // NOP
        dut.u_imem.imem[40] = 32'h0000006F; // JAL  x0, 0

        #(CLK_PERIOD * 3);
        rst = 1;
        start_in = 1;

        // Give it 1000 cycles
        #(CLK_PERIOD * 1000);

        $display("");
        $display("====================================================================");
        $display("  RV64M Processor - Full Unified Testbench Results");
        $display("====================================================================");
        $display("");
        
        // Debug
        // Stop tracing after cycle 1000 just in case
        
        pass_count = 0;
        fail_count = 0;

        check_reg(5,  64'd20,       "ADDI x5, x0, 20");
        check_reg(6,  64'd0,        "ADDI x6, x0, 0");
        check_reg(7,  64'd30,       "ADD  x7, x1, x5");
        check_reg(8,  64'd10,       "SUB  x8, x5, x1");
        check_reg(9,  64'd0,        "AND  x9, x1, x5");
        check_reg(10, 64'd30,       "OR   x10, x1, x5");
        check_reg(11, 64'd30,       "XOR  x11, x1, x5");
        check_reg(12, 64'd10485760, "SLL  x12, x1, x5");
        check_reg(13, 64'd10240,    "SRL  x13, x12, x1");
        check_reg(14, 64'd1,        "SLT  x14, x1, x5");
        check_reg(15, 64'd0,        "SLTU x15, x5, x1");

        check_reg(16, 64'd15,       "ORI  x16, x1, 15");
        check_reg(17, 64'd10,       "ANDI x17, x1, 15");
        check_reg(18, 64'd245,      "XORI x18, x1, 255");
        check_reg(19, 64'd160,      "SLLI x19, x1, 4");
        check_reg(20, 64'd40,       "SRLI x20, x19, 2");
        check_reg(21, -64'sd3,      "SRAI x21, x3, 1");

        check_reg(22, 64'h11111000, "LUI  x22, 69905");
        check_reg(23, 64'h105c,     "AUIPC x23, 1"); // pc at instr 23 is 4*23 = 92 = 0x5C. 0x5C + 0x1000 = 0x105c

        check_reg(24, 64'd100,      "ADDIW x24, x0, 100");
        check_reg(25, -64'sd50,     "ADDIW x25, x0, -50");
        check_reg(26, 64'd50,       "ADDW  x26, x24, x25");

        check_reg(27, 64'd10,       "LD   x27, 0(x0)");
        check_reg(28, 64'd20,       "LD   x28, 8(x0)");

        check_reg(29, 64'd30,       "MUL  x29, x1, x2");
        check_reg(30, 64'hFFFFFFFFFFFFFFFF, "MULH x30, x3, x2");
        check_reg(31, 64'hFFFFFFFFFFFFFFFF, "MULHSU x31, x3, x2");
        check_reg(1,  64'd0,        "MULHU x1, x1, x2");
        
        check_reg(2,  64'd3,        "DIV  x2, x10, x27");
        check_reg(3,  64'd0,        "REM  x3, x10, x27");

        $display("");
        $display("====================================================================");
        if (fail_count == 0)
            $display("  ALL %0d TESTS PASSED!", pass_count);
        else
            $display("  %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("====================================================================");

        $finish;
    end
endmodule
