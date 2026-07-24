`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// RV64M_top - 5-Stage Pipelined RISC-V RV64M Processor
//
// Upgrades from RV64I_top:
//   - M-extension: MUL/DIV via parallel Booth multiplier + non-restoring divider
//   - BRAM: IMEM (addr=pc_next) and DMEM (dual-port) use synchronous read
//   - Branch-in-EX: branch resolution moved to EX stage (2-cycle penalty)
//
// Pipeline: IF -> ID -> EX -> MEM -> WB
//////////////////////////////////////////////////////////////////////////////////

// Note: Do NOT use DONT_TOUCH here — it blocks BRAM inference
module RV64M_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start_in,
    output wire        complete_out,
    output wire        debug_out
);

    //==========================================================================
    //  WIRE DECLARATIONS
    //==========================================================================

    // ---- IF Stage ----
    wire [63:0] pc_current;
    wire [63:0] pc_plus4;
    wire [63:0] pc_next;
    wire [31:0] if_inst;           // BRAM output (registered)
    wire        pc_sel;

    // ---- IF/ID (BRAM output = IF/ID inst) ----
    wire [31:0] ifid_inst;         // From BRAM or NOP on flush
    reg  [63:0] ifid_pc;           // Separate PC register aligned with BRAM

    // ---- ID Stage ----
    wire [6:0]  id_opcode;
    wire [4:0]  id_rd, id_rs1, id_rs2;
    wire [2:0]  id_funct3;
    wire [6:0]  id_funct7;
    wire [63:0] id_rs1_data, id_rs2_data;
    wire [63:0] id_imm;
    wire [63:0] id_rs1_fwd, id_rs2_fwd;

    // Controller outputs
    wire [1:0]  ctrl_ALUSrc_A;
    wire        ctrl_ALUSrc_B;
    wire [1:0]  ctrl_MemtoReg;
    wire        ctrl_RegWrite;
    wire        ctrl_MemWrite;
    wire [`ALU_CTRL_BITS-1:0] ctrl_ALUOp;
    wire [2:0]  ctrl_size;
    wire        ctrl_is_branch, ctrl_is_jal, ctrl_is_jalr;
    wire        ctrl_is_muldiv;
    wire [`MULDIV_OP_BITS-1:0] ctrl_muldiv_op;

    // ---- ID/EX Pipeline Register outputs ----
    wire [63:0] idex_pc;
    wire [63:0] idex_rs1_data, idex_rs2_data;
    wire [63:0] idex_imm;
    wire [4:0]  idex_rd, idex_rs1, idex_rs2;
    wire [31:0] idex_inst;
    wire [1:0]  idex_ALUSrc_A;
    wire        idex_ALUSrc_B;
    wire [1:0]  idex_MemtoReg;
    wire        idex_RegWrite;
    wire        idex_MemWrite;
    wire [`ALU_CTRL_BITS-1:0] idex_ALUOp;
    wire [2:0]  idex_size;
    wire        idex_is_branch, idex_is_jal, idex_is_jalr;
    wire [2:0]  idex_branch_funct3;
    wire        idex_is_muldiv;
    wire [`MULDIV_OP_BITS-1:0] idex_muldiv_op;

    // ---- EX Stage ----
    wire [63:0] ex_alu_A, ex_alu_B;
    wire [63:0] ex_alu_result;
    wire [63:0] ex_branch_target;
    wire [63:0] ex_jalr_target;
    wire [63:0] ex_pc_target;
    wire        ex_branch_taken;
    wire        ex_br_eq, ex_br_lt;

    // MulDiv
    wire [63:0] muldiv_result;
    wire        muldiv_busy, muldiv_done;
    reg         muldiv_started;
    wire [63:0] ex_result;  // ALU or MulDiv result

    // ---- EX/MEM Pipeline Register outputs ----
    wire [63:0] exmem_pc;
    wire [63:0] exmem_alu_result;
    wire [63:0] exmem_rs2_data;
    wire [4:0]  exmem_rd;
    wire [31:0] exmem_inst;
    wire [1:0]  exmem_MemtoReg;
    wire        exmem_RegWrite;
    wire        exmem_MemWrite;
    wire [2:0]  exmem_size;

    // ---- MEM Stage ----
    wire [63:0] mem_dmem_raw_rdata;
    wire [63:0] mem_dmem_formatted;
    wire [63:0] mem_dmem_wdata;
    wire [7:0]  mem_dmem_we;

    // ---- MEM/WB Pipeline Register outputs ----
    wire [63:0] memwb_pc;
    wire [63:0] memwb_alu_result;
    wire [63:0] memwb_mem_data;
    wire [4:0]  memwb_rd;
    wire [31:0] memwb_inst;
    wire [1:0]  memwb_MemtoReg;
    wire        memwb_RegWrite;

    // ---- WB Stage ----
    wire [63:0] wb_data;

    // ---- Hazard/Control ----
    wire [1:0]  fwd_A, fwd_B;
    wire        hz_pc_stall, hz_ifid_stall, hz_idex_flush;
    wire        ctrl_ifid_flush, ctrl_idex_flush;
    (* MAX_FANOUT = 128 *) wire pipeline_stall;

    assign pipeline_stall = hz_pc_stall;

    //==========================================================================
    //  STAGE 1: INSTRUCTION FETCH (IF)
    //==========================================================================

    // PC Register
    PC u_pc (
        .clk    (clk),
        .rst    (rst),
        .en     (!pipeline_stall),
        .pc_in  (pc_next),
        .pc_out (pc_current)
    );

    // PC + 4
    Adder u_pc_adder (
        .A (pc_current),
        .B (64'd4),
        .C (pc_plus4)
    );

    // PC Mux: select between PC+4 and branch target
    Mux2to1 #(.WIDTH(64)) u_pc_mux (
        .in0 (pc_plus4),
        .in1 (ex_pc_target),
        .sel (pc_sel),
        .out (pc_next)
    );

    assign pc_sel = ex_branch_taken;

    // BRAM Instruction Memory
    // Address = pc_current: BRAM samples at clock edge, output available next cycle
    IMEM u_imem (
        .clk      (clk),
        .rst      (rst),
        .rd_en    (!pipeline_stall),
        .addr     (pc_current),
        .inst_out (if_inst)
    );

    // IF/ID: BRAM output IS the instruction register
    // Flush overrides BRAM output with NOP
    assign ifid_inst = (ctrl_ifid_flush) ? `NOP_INST : if_inst;

    // IF/ID PC register (captures pc_current, aligned with BRAM sampling)
    // IMPORTANT: Do NOT zero ifid_pc on flush! BRAM is fetching the branch target!
    always @(posedge clk) begin
        if (!rst)
            ifid_pc <= `ZERO;
        else if (!pipeline_stall)
            ifid_pc <= pc_current;
    end

    //==========================================================================
    //  STAGE 2: INSTRUCTION DECODE (ID)
    //==========================================================================

    assign id_opcode = ifid_inst[6:0];
    assign id_rd     = ifid_inst[11:7];
    assign id_funct3 = ifid_inst[14:12];
    assign id_rs1    = ifid_inst[19:15];
    assign id_rs2    = ifid_inst[24:20];
    assign id_funct7 = ifid_inst[31:25];

    // Register File
    RegFile u_regfile (
        .clk     (clk),
        .rst     (rst),
        .we      (memwb_RegWrite),
        .r_addr1 (id_rs1),
        .r_addr2 (id_rs2),
        .w_addr  (memwb_rd_0),
        .w_data  (wb_data),
        .r_data1 (id_rs1_data),
        .r_data2 (id_rs2_data)
    );

    // Immediate Generator
    ImmGen u_immgen (
        .inst (ifid_inst),
        .imm  (id_imm)
    );

    // Controller (no branch decision — that's in EX now)
    Controller u_ctrl (
        .opcode    (id_opcode),
        .funct3    (id_funct3),
        .funct7    (id_funct7),
        .ALUSrc_A  (ctrl_ALUSrc_A),
        .ALUSrc_B  (ctrl_ALUSrc_B),
        .MemtoReg  (ctrl_MemtoReg),
        .RegWrite  (ctrl_RegWrite),
        .MemWrite  (ctrl_MemWrite),
        .ALUOp     (ctrl_ALUOp),
        .size      (ctrl_size),
        .is_branch (ctrl_is_branch),
        .is_jal    (ctrl_is_jal),
        .is_jalr   (ctrl_is_jalr),
        .is_muldiv (ctrl_is_muldiv),
        .muldiv_op (ctrl_muldiv_op)
    );

    // Hazard Detection
    wire muldiv_stall_sig = idex_is_muldiv && !muldiv_complete;
    HazardDetection u_hazard (
        .ID_EXE_opcode (idex_inst[6:0]),
        .ID_EXE_rd     (idex_rd),
        .IF_ID_rs1     (id_rs1),
        .IF_ID_rs2     (id_rs2),
        .muldiv_busy   (muldiv_busy),
        .muldiv_stall  (muldiv_stall_sig),
        .PC_stall      (hz_pc_stall),
        .IF_ID_stall   (hz_ifid_stall),
        .ID_EXE_flush  (hz_idex_flush)
    );

    // ID/EX Pipeline Register
    REG_ID_EXE u_reg_idex (
        .clk            (clk),
        .rst            (rst),
        .en             (!pipeline_stall),
        .flush          (hz_idex_flush || ctrl_idex_flush),
        .pc_in          (ifid_pc),
        .rs1_data_in    (id_rs1_data),
        .rs2_data_in    (id_rs2_data),
        .imm_in         (id_imm),
        .rd_in          (id_rd),
        .rs1_addr_in    (id_rs1),
        .rs2_addr_in    (id_rs2),
        .inst_in        (ifid_inst),
        .ALUSrc_A_in    (ctrl_ALUSrc_A),
        .ALUSrc_B_in    (ctrl_ALUSrc_B),
        .MemtoReg_in    (ctrl_MemtoReg),
        .RegWrite_in    (ctrl_RegWrite),
        .MemWrite_in    (ctrl_MemWrite),
        .ALUOp_in       (ctrl_ALUOp),
        .size_in        (ctrl_size),
        .is_branch_in   (ctrl_is_branch),
        .is_jal_in      (ctrl_is_jal),
        .is_jalr_in     (ctrl_is_jalr),
        .branch_funct3_in(id_funct3),
        .is_muldiv_in   (ctrl_is_muldiv),
        .muldiv_op_in   (ctrl_muldiv_op),
        // Outputs
        .pc_out         (idex_pc),
        .rs1_data_out   (idex_rs1_data),
        .rs2_data_out   (idex_rs2_data),
        .imm_out        (idex_imm),
        .rd_out         (idex_rd),
        .rs1_addr_out_0 (idex_rs1_0),
        .rs1_addr_out_1 (idex_rs1_1),
        .rs1_addr_out_2 (idex_rs1_2),
        .rs1_addr_out_3 (idex_rs1_3),
        .rs2_addr_out_0 (idex_rs2_0),
        .rs2_addr_out_1 (idex_rs2_1),
        .rs2_addr_out_2 (idex_rs2_2),
        .rs2_addr_out_3 (idex_rs2_3),
        .inst_out       (idex_inst),
        .ALUSrc_A_out   (idex_ALUSrc_A),
        .ALUSrc_B_out   (idex_ALUSrc_B),
        .MemtoReg_out   (idex_MemtoReg),
        .RegWrite_out   (idex_RegWrite),
        .MemWrite_out   (idex_MemWrite),
        .ALUOp_out      (idex_ALUOp),
        .size_out       (idex_size),
        .is_branch_out  (idex_is_branch),
        .is_jal_out     (idex_is_jal),
        .is_jalr_out    (idex_is_jalr),
        .branch_funct3_out(idex_branch_funct3),
        .is_muldiv_out  (idex_is_muldiv),
        .muldiv_op_out  (idex_muldiv_op)
    );

    //==========================================================================
    //  STAGE 3: EXECUTE (EX)
    //==========================================================================

    //==========================================================================
    //  FORWARDING UNIT & MUXES (EX STAGE) - 4-Way Sliced
    wire [4:0] memwb_rd_0, memwb_rd_1, memwb_rd_2, memwb_rd_3;
    wire [4:0] idex_rs1_0, idex_rs1_1, idex_rs1_2, idex_rs1_3;
    wire [4:0] idex_rs2_0, idex_rs2_1, idex_rs2_2, idex_rs2_3;
    wire [1:0] fwd_A_0, fwd_A_1, fwd_A_2, fwd_A_3;
    wire [1:0] fwd_B_0, fwd_B_1, fwd_B_2, fwd_B_3;

    (* DONT_TOUCH = "TRUE" *) ForwardingUnit u_fwd_0 (
        .ID_EXE_rs1(idex_rs1_0), .ID_EXE_rs2(idex_rs2_0),
        .EXE_MEM_rd(exmem_rd), .EXE_MEM_RegWrite(exmem_RegWrite),
        .MEM_WB_rd(memwb_rd_0),  .MEM_WB_RegWrite(memwb_RegWrite),
        .ForwardA(fwd_A_0),    .ForwardB(fwd_B_0)
    );
    (* DONT_TOUCH = "TRUE" *) ForwardingUnit u_fwd_1 (
        .ID_EXE_rs1(idex_rs1_1), .ID_EXE_rs2(idex_rs2_1),
        .EXE_MEM_rd(exmem_rd), .EXE_MEM_RegWrite(exmem_RegWrite),
        .MEM_WB_rd(memwb_rd_1),  .MEM_WB_RegWrite(memwb_RegWrite),
        .ForwardA(fwd_A_1),    .ForwardB(fwd_B_1)
    );
    (* DONT_TOUCH = "TRUE" *) ForwardingUnit u_fwd_2 (
        .ID_EXE_rs1(idex_rs1_2), .ID_EXE_rs2(idex_rs2_2),
        .EXE_MEM_rd(exmem_rd), .EXE_MEM_RegWrite(exmem_RegWrite),
        .MEM_WB_rd(memwb_rd_2),  .MEM_WB_RegWrite(memwb_RegWrite),
        .ForwardA(fwd_A_2),    .ForwardB(fwd_B_2)
    );
    (* DONT_TOUCH = "TRUE" *) ForwardingUnit u_fwd_3 (
        .ID_EXE_rs1(idex_rs1_3), .ID_EXE_rs2(idex_rs2_3),
        .EXE_MEM_rd(exmem_rd), .EXE_MEM_RegWrite(exmem_RegWrite),
        .MEM_WB_rd(memwb_rd_3),  .MEM_WB_RegWrite(memwb_RegWrite),
        .ForwardA(fwd_A_3),    .ForwardB(fwd_B_3)
    );

    wire [63:0] ex_fwd_A;
    wire [63:0] ex_fwd_B;

    // Slice 0: [15:0]
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_A_0 (
        .in0(idex_rs1_data[15:0]), .in1(wb_data[15:0]), .in2(exmem_alu_result[15:0]), .in3(16'b0),
        .sel(fwd_A_0), .out(ex_fwd_A[15:0])
    );
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_B_0 (
        .in0(idex_rs2_data[15:0]), .in1(wb_data[15:0]), .in2(exmem_alu_result[15:0]), .in3(16'b0),
        .sel(fwd_B_0), .out(ex_fwd_B[15:0])
    );

    // Slice 1: [31:16]
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_A_1 (
        .in0(idex_rs1_data[31:16]), .in1(wb_data[31:16]), .in2(exmem_alu_result[31:16]), .in3(16'b0),
        .sel(fwd_A_1), .out(ex_fwd_A[31:16])
    );
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_B_1 (
        .in0(idex_rs2_data[31:16]), .in1(wb_data[31:16]), .in2(exmem_alu_result[31:16]), .in3(16'b0),
        .sel(fwd_B_1), .out(ex_fwd_B[31:16])
    );

    // Slice 2: [47:32]
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_A_2 (
        .in0(idex_rs1_data[47:32]), .in1(wb_data[47:32]), .in2(exmem_alu_result[47:32]), .in3(16'b0),
        .sel(fwd_A_2), .out(ex_fwd_A[47:32])
    );
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_B_2 (
        .in0(idex_rs2_data[47:32]), .in1(wb_data[47:32]), .in2(exmem_alu_result[47:32]), .in3(16'b0),
        .sel(fwd_B_2), .out(ex_fwd_B[47:32])
    );

    // Slice 3: [63:48]
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_A_3 (
        .in0(idex_rs1_data[63:48]), .in1(wb_data[63:48]), .in2(exmem_alu_result[63:48]), .in3(16'b0),
        .sel(fwd_A_3), .out(ex_fwd_A[63:48])
    );
    Mux4to1 #(.WIDTH(16)) u_fwd_mux_B_3 (
        .in0(idex_rs2_data[63:48]), .in1(wb_data[63:48]), .in2(exmem_alu_result[63:48]), .in3(16'b0),
        .sel(fwd_B_3), .out(ex_fwd_B[63:48])
    );

    // ALU Input A Mux
    Mux4to1 #(.WIDTH(64)) u_alu_mux_A (
        .in0 (ex_fwd_A),
        .in1 (ex_fwd_A),        // W-type (ALU handles truncation)
        .in2 (idex_pc),         // AUIPC/LUI
        .in3 (64'b0),
        .sel (idex_ALUSrc_A),
        .out (ex_alu_A)
    );

    // ALU Input B Mux
    Mux2to1 #(.WIDTH(64)) u_alu_mux_B (
        .in0 (ex_fwd_B),
        .in1 (idex_imm),
        .sel (idex_ALUSrc_B),
        .out (ex_alu_B)
    );

    // ALU
    ALU u_alu (
        .A      (ex_alu_A),
        .B      (ex_alu_B),
        .ALUOp  (idex_ALUOp),
        .Result (ex_alu_result)
    );

    // MulDiv Unit
    reg         muldiv_complete;  // Persists after done pulse until pipeline advances
    reg  [63:0] muldiv_result_latched;

    wire muldiv_start_pulse = idex_is_muldiv && !muldiv_busy && !muldiv_started && !muldiv_complete;

    always @(posedge clk) begin
        if (!rst) begin
            muldiv_started  <= 1'b0;
            muldiv_complete <= 1'b0;
            muldiv_result_latched <= 64'b0;
        end
        else if (ctrl_idex_flush) begin
            muldiv_started  <= 1'b0;
            muldiv_complete <= 1'b0;
        end
        else begin
            if (muldiv_start_pulse)
                muldiv_started <= 1'b1;
            if (muldiv_done) begin
                muldiv_complete <= 1'b1;
                muldiv_result_latched <= muldiv_result;
            end
            // Clear when pipeline advances (stall released + complete)
            if (muldiv_complete && !hz_pc_stall) begin
                muldiv_started  <= 1'b0;
                muldiv_complete <= 1'b0;
            end
        end
    end

    MulDiv u_muldiv (
        .clk    (clk),
        .rst    (rst),
        .start  (muldiv_start_pulse),
        .op     (idex_muldiv_op),
        .rs1    (ex_fwd_A),
        .rs2    (ex_fwd_B),
        .result (muldiv_result),
        .busy   (muldiv_busy),
        .done   (muldiv_done)
    );

    // EX result: use latched MulDiv result when complete
    assign ex_result = muldiv_complete ? muldiv_result_latched :
                       muldiv_done ? muldiv_result :
                       ex_alu_result;

    // ---- Branch Logic (now in EX stage) ----

    // Branch Comparator
    wire ex_BrUn = idex_branch_funct3[2] && idex_branch_funct3[1];

    BranchCompare u_brcmp (
        .A    (ex_fwd_A),
        .B    (ex_fwd_B),
        .BrUn (ex_BrUn),
        .BrEq (ex_br_eq),
        .BrLT (ex_br_lt)
    );

    // Branch target: PC + imm
    Adder u_branch_target (
        .A (idex_pc),
        .B (idex_imm),
        .C (ex_branch_target)
    );

    // JALR target: rs1 + imm (with LSB cleared)
    wire [63:0] ex_jalr_raw = ex_fwd_A + idex_imm;
    assign ex_jalr_target = {ex_jalr_raw[63:1], 1'b0};

    // Branch decision
    reg ex_branch_decision;
    always @(*) begin
        ex_branch_decision = 1'b0;
        if (idex_is_branch) begin
            case (idex_branch_funct3)
                3'b000: ex_branch_decision = ex_br_eq;   // BEQ
                3'b001: ex_branch_decision = !ex_br_eq;  // BNE
                3'b100: ex_branch_decision = ex_br_lt;   // BLT
                3'b101: ex_branch_decision = !ex_br_lt;  // BGE
                3'b110: ex_branch_decision = ex_br_lt;   // BLTU
                3'b111: ex_branch_decision = !ex_br_lt;  // BGEU
                default: ex_branch_decision = 1'b0;
            endcase
        end
    end

    assign ex_branch_taken = ex_branch_decision || idex_is_jal || idex_is_jalr;

    // PC target mux
    assign ex_pc_target = idex_is_jalr ? ex_jalr_target : ex_branch_target;

    reg [31:0] dbg_cycle = 0;
    always @(posedge clk) begin
        if (rst) dbg_cycle <= dbg_cycle + 1;
        if (dbg_cycle > 440 && dbg_cycle < 460) begin
            $display("CYC=%0d | PC=%0d | IF_ID: pc=%0d inst=%0h flush=%b | ID_EX: pc=%0d inst=%0h jal=%b ex_bt=%0d ex_tk=%b | ctrl_ff=%b/%b",
                dbg_cycle, pc_current, ifid_pc, ifid_inst, ctrl_ifid_flush, idex_pc, idex_inst, idex_is_jal, ex_branch_target, ex_branch_taken,
                u_ctrl_stall.IF_ID_flush, u_ctrl_stall.ID_EX_flush);
        end
        if (ex_branch_taken && ex_pc_target == 64'b0) begin
            $display("JUMP TO 0 DETECTED! time=%0t, is_jal=%b, is_jalr=%b, idex_pc=%0d, idex_imm=%0d, inst=%0h", 
                $time, idex_is_jal, idex_is_jalr, idex_pc, idex_imm, idex_inst);
        end
    end

    // Control Stall (flush on branch taken)
    ControlStall u_ctrl_stall (
        .clk             (clk),
        .rst             (rst),
        .ex_branch_taken (ex_branch_taken),
        .IF_ID_flush     (ctrl_ifid_flush),
        .ID_EX_flush     (ctrl_idex_flush)
    );

    // JAL/JALR link address: PC+4 using CLA (not ripple-carry)
    wire [63:0] ex_link_addr;
    Adder u_link_adder (
        .A (idex_pc),
        .B (64'd4),
        .C (ex_link_addr)
    );

    // EX/MEM Pipeline Register
    wire [63:0] exmem_result_in = (idex_is_jal || idex_is_jalr) ?
                                   ex_link_addr : ex_result;

    REG_EXE_MEM u_reg_exmem (
        .clk            (clk),
        .rst            (rst),
        .en             (!muldiv_busy),
        .pc_in          (idex_pc),
        .alu_result_in  (exmem_result_in),
        .rs2_data_in    (ex_fwd_B),
        .rd_in          (idex_rd),
        .inst_in        (idex_inst),
        .MemtoReg_in    (idex_MemtoReg),
        .RegWrite_in    (idex_is_muldiv ? (muldiv_complete || muldiv_done) :
                         idex_RegWrite),
        .MemWrite_in    (idex_MemWrite),
        .size_in        (idex_size),
        .pc_out         (exmem_pc),
        .alu_result_out (exmem_alu_result),
        .rs2_data_out   (exmem_rs2_data),
        .rd_out         (exmem_rd),
        .inst_out       (exmem_inst),
        .MemtoReg_out   (exmem_MemtoReg),
        .RegWrite_out   (exmem_RegWrite),
        .MemWrite_out   (exmem_MemWrite),
        .size_out       (exmem_size)
    );

    //==========================================================================
    //  STAGE 4: MEMORY ACCESS (MEM)
    //==========================================================================

    // DMEM Write Formatter
    dmem_in u_dmem_in (
        .size       (exmem_size),
        .dmem_write (exmem_MemWrite),
        .data_in    (exmem_rs2_data),
        .addr       (exmem_alu_result),
        .web        (mem_dmem_we),
        .data_out   (mem_dmem_wdata)
    );

    // BRAM Data Memory (Simple Dual-Port with Byte Write Enable)
    // Read addr from EX stage ALU result; Write addr from EX/MEM
    DMEM u_dmem (
        .clk     (clk),
        .rst     (rst),
        .rd_en   (1'b1),
        .rd_addr (ex_alu_result),      // Read address from EX (before EX/MEM)
        .r_data  (mem_dmem_raw_rdata),
        .wr_addr (exmem_alu_result),   // Write address from MEM
        .w_data  (mem_dmem_wdata),
        .we      (mem_dmem_we)
    );

    // DMEM Read Formatter
    dmem_out u_dmem_out (
        .size     (exmem_size),
        .data_in  (mem_dmem_raw_rdata),
        .addr     (exmem_alu_result),
        .data_out (mem_dmem_formatted)
    );

    // MEM/WB Pipeline Register
    REG_MEM_WB u_reg_memwb (
        .clk            (clk),
        .rst            (rst),
        .en             (1'b1),
        .pc_in          (exmem_pc),
        .alu_result_in  (exmem_alu_result),
        .mem_data_in    (mem_dmem_formatted),
        .rd_in          (exmem_rd),
        .inst_in        (exmem_inst),
        .MemtoReg_in    (exmem_MemtoReg),
        .RegWrite_in    (exmem_RegWrite),
        .pc_out         (memwb_pc),
        .alu_result_out (memwb_alu_result),
        .mem_data_out   (memwb_mem_data),
        .rd_out_0       (memwb_rd_0),
        .rd_out_1       (memwb_rd_1),
        .rd_out_2       (memwb_rd_2),
        .rd_out_3       (memwb_rd_3),
        .inst_out       (memwb_inst),
        .MemtoReg_out   (memwb_MemtoReg),
        .RegWrite_out   (memwb_RegWrite)
    );

    //==========================================================================
    //  STAGE 5: WRITE BACK (WB)
    //==========================================================================

    Mux4to1 #(.WIDTH(64)) u_wb_mux (
        .in0 (memwb_alu_result),
        .in1 (memwb_mem_data),
        .in2 (64'b0),
        .in3 (memwb_alu_result),  // PC+4 already stored in alu_result for JAL/JALR
        .sel (memwb_MemtoReg),
        .out (wb_data)
    );

    //==========================================================================
    //  STATE CONTROL
    //==========================================================================

    StateControl u_state (
        .clk        (clk),
        .rst        (rst),
        .start_in   (start_in),
        .done_flag  (1'b0),
        .state_start(),
        .state_done (complete_out)
    );

    //==========================================================================
    //  DEBUG OUTPUT
    //==========================================================================
    // XOR-reduce all critical pipeline state to prevent Vivado from removing logic.
    // Every signal here must be kept by Vivado because debug_out depends on it.
    assign debug_out = ^pc_current ^
                       ^wb_data ^
                       ^ex_alu_result ^
                       ^ex_result ^
                       ^muldiv_result ^
                       ^mem_dmem_raw_rdata ^
                       ^mem_dmem_wdata ^
                       ^exmem_alu_result ^
                       ^exmem_rs2_data ^
                       ^idex_rs1_data ^
                       ^idex_rs2_data ^
                       ^idex_imm ^
                       ^ifid_inst ^
                       ^ifid_pc ^
                       ^id_rs1_data ^
                       ^id_rs2_data ^
                       muldiv_busy ^
                       muldiv_done ^
                       pipeline_stall ^
                       ex_branch_taken;

endmodule
