`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:32:08
// Design Name: 
// Module Name: RV64i
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "common.vh" 

module RISCV(
    input CLK,
    input RST,
  //-----------------------------------------------------//
  //          			Input Signals                    // 
  //-----------------------------------------------------//
    input start_in,
    ////**** Configuration Memory ****////
    input [`DATA_BITS-1:0]  CFG_addra_in_64,
    input [`WORD_BITS-1:0]  CFG_dina_in,
    input                   CFG_ena_in,
    input                   CFG_wea_in,    
    ////**** Local Data Memory ****////
    input [`DATA_BITS-1:0]  LDM_addra_in_64,
    input [`DATA_BITS-1:0]  LDM_dina_in_64,
    input                   LDM_ena_in,
    input [7:0]             LDM_wea_in,  
  //-----------------------------------------------------//
  //          			Output Signals                   // 
  //-----------------------------------------------------//    
    output                  complete_out,
    output [`DATA_BITS-1:0] LDM_douta_out_64
//    output [`WORD_BITS-1:0] Inst_ROM_in
    );
    wire [`DATA_BITS-1:0] PC_out_64;
    wire [`DATA_BITS-1:0] Imm_64;
    wire [`DATA_BITS-1:0] add_branch_out_64;
    wire [`DATA_BITS-1:0] add_jal_out_64;
    wire [`DATA_BITS-1:0] add_jalr_out_64;
    
    wire [`ADDR_BITS-1:0] Wt_addr;
    wire [`DATA_BITS-1:0] Wt_data_64;
    wire [`DATA_BITS-1:0] rdata_A_64;
    wire [`DATA_BITS-1:0] rdata_B_64;
    wire [`DATA_BITS-1:0] PC_wb_64;
    wire [`DATA_BITS-1:0] ALU_A_64;
    wire [`DATA_BITS-1:0] ALU_B_64;
    wire [`DATA_BITS-1:0] _W_D_FromRF_out;
    
    wire [1:0] Branch;      // ID
    wire [1:0] ALUSrc_A;          // EXE
    wire [1:0] ALUSrc_B;    // EXE
    wire [`ALU_CTRL_BITS-1:0] ALU_Control; // EXE
    wire RegWrite;          // WB
    wire [1:0] DatatoReg;   // WB
    wire BrEq;
	wire BrUn;
	wire BrLT;
    
//    wire [1:0] B_H_W;       // WB // not used yet
    wire W_D;
    wire W_D_FromRF;
//    wire sign;              // WB // not used yet


//stall
    wire [`DATA_BITS-1:0] ALU_A;
    wire [`DATA_BITS-1:0] ALU_A_stall;
    wire [`DATA_BITS-1:0] ALU_B_stall;
    wire [`DATA_BITS-1:0] ALU_A_branch;
    wire [1:0] BSel_stall_1;
	wire [1:0] ASel_stall_1;
	wire ASel_stall_2;
    wire [1:0] ASel_stall_3; 
    //MuxInstMem
    wire [`DATA_BITS-1:0] instmux_out_64;
    //InstMem
    wire [`WORD_BITS-1:0] Inst_ROM_in;
    //DataMem
    wire [`DATA_BITS-1:0] data_in_64;   // MEM
    wire [`DATA_BITS-1:0] ALU_out_64;  // From MEM, address out, for fetching data_in
    wire [`DATA_BITS-1:0] data_out_64; // From MEM, to be written into data memory
    wire mem_w;
    // IF_ID
    wire [`WORD_BITS-1:0] IF_ID_inst_out;
    wire [`DATA_BITS-1:0] IF_ID_PC_64;
    wire IF_ID_mem_w;
    wire [2:0] IF_ID_size;
    wire [`ADDR_BITS-1:0] IF_ID_written_reg;
    wire [`ADDR_BITS-1:0] IF_ID_read_reg1;
    wire [`ADDR_BITS-1:0] IF_ID_read_reg2;
    wire [`ADDR_BITS-1:0] IF_ID_read_reg3;    
    // ID_EXE
    wire [`WORD_BITS-1:0] ID_EXE_inst_in;
    wire [`DATA_BITS-1:0] ID_EXE_PC_64;
    wire [`DATA_BITS-1:0] ID_EXE_ALU_A_64;
    wire [`DATA_BITS-1:0] ID_EXE_ALU_B_64;
    wire [`ALU_CTRL_BITS-1:0] ID_EXE_ALU_Control;
    wire [`DATA_BITS-1:0] ID_EXE_Data_out_64;
    wire ID_EXE_mem_w;
    wire [2:0] ID_EXE_size;
    wire [1:0] ID_EXE_DatatoReg;
    wire ID_EXE_RegWrite;
    wire ID_EXE_W_D;
    wire [`ADDR_BITS-1:0] ID_EXE_written_reg;
    
    wire [`DATA_BITS-1:0] ID_EXE_ALU_out_64;
    wire [`DATA_BITS-1:0] ID_EXE_ALU_Mult;

    // EXE_MEM
    wire [`WORD_BITS-1:0] EXE_MEM_inst_in;
    wire [`DATA_BITS-1:0] EXE_MEM_PC_64;
    wire [`DATA_BITS-1:0] EXE_MEM_ALU_out_64;
    wire [`DATA_BITS-1:0] EXE_MEM_Data_out_64;
    wire EXE_MEM_mem_w;
    wire [2:0] EXE_MEM_size;
    wire [1:0] EXE_MEM_DatatoReg;
    wire EXE_MEM_RegWrite;
    wire EXE_MEM_W_D;
    wire [`ADDR_BITS-1:0] EXE_MEM_written_reg;
  
    // MEM_WB
    wire [`WORD_BITS-1:0] MEM_WB_inst_in;
    wire [`DATA_BITS-1:0] MEM_WB_ALU_out_64;
    wire [`DATA_BITS-1:0] MEM_WB_wb;
    wire [1:0] MEM_WB_DatatoReg;
    wire MEM_WB_RegWrite;
   // MUX_W_D
   wire [`DATA_BITS-1:0] MUX_W_D_out;
   // Stall
   wire PC_dstall;
   wire IF_ID_cstall;
   wire IF_ID_dstall;
   wire ID_EXE_dstall;
   
   //StateControl
   wire state_start;
     
    
    wire [`DATA_BITS-1:0] DMEM_Custom_Address;  
    wire [`DATA_BITS-1:0] ID_EXE_DMEM_Custom_Address;
    wire [`DATA_BITS-1:0] EXE_MEM_DMEM_Custom_Address;
    
    wire [`DATA_BITS-1:0] ID_EXE_DMEM_Custom_Address_ntt;
    wire [`DATA_BITS-1:0] EXE_MEM_DMEM_Custom_Address_ntt;
    wire [`DATA_BITS-1:0] DMEM_Custom_Address_ntt;
    wire IF_ID_ntt_we;
    wire ID_EXE_ntt_we;
    wire EXE_MEM_ntt_we;
    wire MEM_WB_ntt_we;
    wire EXE_MEM_ntt_start;
    wire ID_EXE_ntt_start;
    wire MEM_WB_ntt_start;
    wire [`DATA_BITS-1:0] EXE_MEM_ntt_dout;
    wire [`DATA_BITS-1:0] MEM_WB_Wt_data_64;
    wire sha3_stall;
    wire [63:0] counter_q;
    wire lbuf_stall;
    wire [`DATA_BITS-1:0] Buffer_data_out;
    wire [`DATA_BITS-1:0] ID_EXE_Buffer_data_out;
    wire [`DATA_BITS-1:0] EXE_MEM_Buffer_data_out;
    wire [`DATA_BITS-1:0] buffer_offset;
    
    wire [`DATA_BITS-1:0] IF_ID_Buffer_Base_Address;
    wire [`DATA_BITS-1:0] IF_ID_Buffer_Load_Amount;
    wire [`DATA_BITS-1:0] IF_ID_DMEM_Base_Address;
    wire ntt_stall;
    wire ntt_start;
    wire ntt_we;
    wire ntt_md;
    wire [31:0] ntt_din;
    wire ntt_valid;
    wire [31:0] ntt_dout;
    wire ntt_ready;
    wire ntt_done;
    wire [`DATA_BITS-1:0] dmemmux_out_64;
    wire DMEM_mem_w;
    wire [7:0] web;
    
    wire [2:0] MEM_WB_size;
    wire [`DATA_BITS-1:0] MEM_WB_DMEM_addr_in;
    wire MEM_WB_mem_w;    
    wire [`DATA_BITS-1:0] dmem_wr_data;
    wire [`DATA_BITS-1:0] dmem_rd_data;
    wire ntt_dmem_write;
    wire EXE_MEM_ntt_dmem_write;
    
    
    wire [63:0] IF_ID_counter;
    wire [63:0] ID_EXE_counter;
    wire [63:0] EXE_MEM_counter;
    
    wire        pwam_start;
    wire        MEM_WB_pwam_wea;
    wire        IF_ID_pwam_wea;
    wire 	    MEM_WB_pwam_web;
    wire 	    IF_ID_pwam_web;
    wire        pwam_valid;
    wire [31:0] pwam_dout;
    wire        pwam_done;
    wire        pwam_stall;
    wire        pwam_we;    
    wire [31:0] pwam_din;
    wire EXE_MEM_pwam_start;
    wire ID_EXE_pwam_start;
    wire MEM_WB_pwam_start;
    wire pwam_dmem_write;
    wire EXE_MEM_pwam_dmem_write;
    wire  pwam_mode;
    
    wire [1:0] dmem_addr_sel;
    wire [1:0] ID_EXE_dmem_addr_sel;
    wire [1:0] EXE_MEM_dmem_addr_sel;
    wire [1:0] dmem_data_sel;
    wire [1:0] ID_EXE_dmem_data_sel;
    wire [1:0] EXE_MEM_dmem_data_sel;
    
    wire [`DATA_BITS-1:0] DMEM_Base_Address_pwam;
    wire [`DATA_BITS-1:0] DMEM_Address_pwam;
    wire [`DATA_BITS-1:0] DMEM_Custom_Address_pwam;
    wire [`DATA_BITS-1:0] ID_EXE_DMEM_Custom_Address_pwam;
    wire [`DATA_BITS-1:0] EXE_MEM_DMEM_Custom_Address_pwam;
    wire [1:0] DMEM_Base_Address_pwam_sel_from_rf;
    wire [63:0] counter_q_pwam;
    wire [63:0] counter_q_final;
    wire pwam_counter_sel;
    wire [`DATA_BITS-1:0] DMEM_pwam_dout;
    wire [`DATA_BITS-1:0] EXE_MEM_pwam_dout;
    wire [63:0] counter_qq;
    
    wire [1:0] reg29_sel;
    wire [1:0] reg30_sel;
    wire [1:0] reg31_sel;
    wire [`DATA_BITS-1:0] reg29_fwd_data;
    wire [`DATA_BITS-1:0] reg30_fwd_data;
    wire [`DATA_BITS-1:0] reg31_fwd_data;
    wire alu_sel; 
    
        wire keccak_done;
    wire keccak_ready ;
    wire keccak_valid ;
    wire keccak_stall;
    wire MEM_WB_keccak_we ;
    wire MEM_WB_keccak_start ;
    wire EXE_MEM_keccak_we ;
    wire EXE_MEM_keccak_start ;
    wire keccak_we ;
    wire keccak_start ;    
    wire ID_EXE_keccak_we ;
    wire ID_EXE_keccak_start ;
    wire keccak_dmem_write;
    wire EXE_MEM_keccak_dmem_write;
    wire keccak_we_real;
    wire IF_ID_keccak_we;
    wire [63:0] counter_q_keccak;
    wire [63:0] counter_q_final_1;
    wire keccak_counter_sel;
    wire [`DATA_BITS-1:0] keccak_dout;  
//    wire ready;
   //////////////////////////////////////
   StateControl statecontrol(
        .CLK(CLK),
        .RST(RST),
        .Start_in(start_in),
        .Done_flag(LDM_douta_out_64[0:0]),
        .State_start(state_start),
        .State_done(complete_out)
   );

    DataStall _dstall_ (
        .ID_EXE_inst(ID_EXE_inst_in),
        .EXE_MEM_inst(EXE_MEM_inst_in),
        .MEM_WB_inst(MEM_WB_inst_in),
        .IF_ID_written_reg(IF_ID_written_reg),
        .IF_ID_read_reg1(IF_ID_read_reg1),
        .IF_ID_read_reg2(IF_ID_read_reg2),
        .ID_EXE_written_reg(ID_EXE_written_reg),      
        .EXE_MEM_written_reg(EXE_MEM_written_reg),
        .MEM_WB_written_reg(Wt_addr),
        
        .PC_dstall(PC_dstall),
        .IF_ID_dstall(IF_ID_dstall),
        .ID_EXE_dstall(ID_EXE_dstall),
        .ASel_stall_1(ASel_stall_1),
        .ASel_stall_2(ASel_stall_2),
        .BSel_stall_1(BSel_stall_1), 
        .ASel_stall_3(ASel_stall_3) 
        );
    wire mulstall;    
        
    ControlStall _cstall_ (
        .Branch(Branch[1:0]),
        .IF_ID_cstall(IF_ID_cstall)
        );
    MulStall _mstall_(
        .CLK(CLK),
        .RST(RST),
        .Inst_ROM_in(Inst_ROM_in),
        .mulstall(mulstall),
        .PC_stall(PC_dstall),
        .IF_ID_addr(IF_ID_PC_64),
        .Addr_64(PC_out_64),
        .IF_ID_inst(IF_ID_inst_out) 
    );   
    
    ALU_Mult _alumul_ (
        .CLK(CLK),
        .A(ID_EXE_ALU_A_64),
        .B(ID_EXE_ALU_B_64),
        .ALUOp(ID_EXE_ALU_Control[`ALU_CTRL_BITS-1:0]),
        .Result(ID_EXE_ALU_Mult)
    ); 
    
    wire [`DATA_BITS-1:0] ID_EXE_ALU_result;
    
    Mux2_1_64 _mux_alu_out (
        .In_0(ID_EXE_ALU_result),
        .In_1(ID_EXE_ALU_Mult),
        .Sel(ID_EXE_alu_sel),
        .Out(ID_EXE_ALU_out_64)       
    );

    assign ALU_out_64 = EXE_MEM_ALU_out_64;
    assign data_out_64 = EXE_MEM_Data_out_64;
    assign mem_w = EXE_MEM_mem_w;

/////////////////////////////////////////////////////////////
    REG64 _pc_ (
        .CE(state_start),
        .CLK(CLK),
        .Data_in(PC_wb_64),
        .RST(RST),
        .Data_out(PC_out_64),
        .PC_dstall(PC_dstall),
        .ntt_stall(ntt_stall),
        .pwam_stall(pwam_stall),
        .mulstall(mulstall),
        .keccak_stall(keccak_stall)
        );
    Adder  _add_Branch (
        .A(IF_ID_PC_64),         // use the "PC" from ID stage
        .B(Imm_64),           // From ID stage
        .C(add_branch_out_64)    // actually this part belongs to IF_ID
        );   
    Adder _add_JAL (
        .A(IF_ID_PC_64),               // MIPS: PC+4, RISC-V: PC!!!
        .B({{43{IF_ID_inst_out[31]}}, IF_ID_inst_out[31], IF_ID_inst_out[19:12], IF_ID_inst_out[20], IF_ID_inst_out[30:21], 1'b0}), 
        .C(add_jal_out_64)
        );
    Adder _add_JALR (
        .A(ALU_A_branch), 
        .B({{52{IF_ID_inst_out[31]}}, IF_ID_inst_out[31:20]}), 
        .C(add_jalr_out_64)
        );
    Mux4_1_64  _mux_pc_in (
        .In_0(PC_out_64[63:0] + 32'b0100),   // From IF stage
        .In_1(add_branch_out_64),      // Containing "PC" from ID stage
        .In_2(add_jal_out_64),         // From ID stage
        .In_3(add_jalr_out_64),        // From ID stage
        .Sel(Branch[1:0]),                // From ID
        .Out(PC_wb_64)
        );
        
    //MUX Instmem
    Mux2_1_64 _mux_imem_inst_in (
        .In_0(PC_out_64),
        .In_1(CFG_addra_in_64),
        .Sel(CFG_wea_in),
        .Out(instmux_out_64)       
    );
    
    //InstMem
    IMEM _imem(
        .CLK(CLK), 
        .IMEM_WE(CFG_wea_in),
        .Addr_64(instmux_out_64),  
        .Inst_in(CFG_dina_in),      
        .Inst_out(Inst_ROM_in)
    );

    REG_IF_ID _reg_if_id_ (
        .clk(CLK), .rst(RST), .CE(state_start),
        .IF_ID_dstall(IF_ID_dstall), 
        .IF_ID_cstall(IF_ID_cstall),
        // Input
        .inst_in(Inst_ROM_in),
        .PC(PC_out_64),
        // Output
        .IF_ID_inst_in(IF_ID_inst_out),
        .IF_ID_PC(IF_ID_PC_64),
        .ntt_we(ntt_we_real),
        .IF_ID_ntt_we(IF_ID_ntt_we),
        .counter(counter_q_final),
        .IF_ID_counter(IF_ID_counter),
        .pwam_wea(pwam_wea),
        .IF_ID_pwam_wea(IF_ID_pwam_wea),
        .pwam_web(pwam_web),
        .IF_ID_pwam_web(IF_ID_pwam_web),
        .keccak_we(keccak_we_real),
        .IF_ID_keccak_we(IF_ID_keccak_we)
        );
//////////////////////////////////////////////////////////////////////////////////
    RegFile _regfile (
        .CLK(CLK),
        .RST(RST),
        .RegWrite(MEM_WB_RegWrite),             
        .R_addr_A(IF_ID_inst_out[19:15]),   
        .R_addr_B(IF_ID_inst_out[24:20]),    
        .W_addr(Wt_addr),            
        .W_data(MEM_WB_wb),           
        .R_data_A(rdata_A_64),
        .R_data_B(rdata_B_64),
        .Buffer_Base_Address(IF_ID_Buffer_Base_Address),
        .Buffer_Load_Amount(IF_ID_Buffer_Load_Amount),
        .DMEM_Base_Address(IF_ID_DMEM_Base_Address)
        );

    ImmGen _signed_extend (
        .inst_32(IF_ID_inst_out), 
        .imm_64(Imm_64)
        );
    
    GetReg _rw_regs_ (
        .inst_in(IF_ID_inst_out),
        .written_reg(IF_ID_written_reg),
        .read_reg1(IF_ID_read_reg1),
        .read_reg2(IF_ID_read_reg2)
        );
        
    Controller  _controller (
        // Input:
        .Opcode(IF_ID_inst_out[6:0]),
        .Funct3(IF_ID_inst_out[14:12]),
        .Funct7(IF_ID_inst_out[31:25]),
        .Funct2(IF_ID_inst_out[26:25]),
        .BrEq(BrEq),
        .BrLT(BrLT),
        // Output:
        .ALUSrc_A(ALUSrc_A),
        .ALUSrc_B(ALUSrc_B[1:0]),
        .ALUOp(ALU_Control[`ALU_CTRL_BITS-1:0]),
        .Branch(Branch[1:0]),
        .MemtoReg(DatatoReg[1:0]),
        .MemWrite(IF_ID_mem_w),
        .RegWrite(RegWrite),
//        .B_H_W(B_H_W),                  // not used yet
        .W_D(W_D),
        .W_D_FromRF(W_D_FromRF),
//        .Sign(sign),                     // not used yet
        .size(IF_ID_size),
        .BrUn(BrUn),
        .ntt_md(ntt_md),
        .alu_sel(alu_sel)
        );
   
        
    BranchCompare _branch (
        .A(ALU_A_branch),
        .B(ALU_B_stall),
        .BrUn(BrUn),
        .BrEq(BrEq),
        .BrLT(BrLT)
        );
    
    Mux2_1_64  _W_D_FromRF(
        .In_0(ALU_B_stall),
        .In_1({32'b0,ALU_B_stall[31:0]}),
        .Sel(W_D_FromRF),
        .Out(_W_D_FromRF_out)
    );
    
    Mux4_1_64 _mux_alu_source_A (
        .In_0(rdata_A_64),      //gia tri doc tu regfile
        .In_1({32'b0, rdata_A_64[31:0]}), //danh cho lenh ADDIW...
        .In_2(IF_ID_PC_64), //LUI(nho chinh), AUIPC
        .In_3(64'h0),
        .Sel(ALUSrc_A),
        .Out(ALU_A)
        );
	
	Mux4_1_64 _mux_A_exe_mem (
	    .In_0(ID_EXE_ALU_out_64), //ket qua ALU
        .In_1(Wt_data_64),         // doc tu DMEM
        .In_2(MEM_WB_wb),           //doc tu DMEM nhung o stage WB
        .In_3(64'h0),
        .Sel(ASel_stall_1),
        .Out(ALU_A_stall)
	    );
	    
	Mux4_1_64 _mux_A_branch (
	    .In_0(ID_EXE_ALU_out_64), //ket qua ALU
        .In_1(Wt_data_64),      // doc tu DMEM
        .In_2(MEM_WB_wb),       //doc tu DMEM nhung o stage WB
        .In_3(rdata_A_64),      //doc tu regfile
        .Sel(ASel_stall_3),
        .Out(ALU_A_branch)
	    );    
	
	Mux2_1_64 _mux_A (
	    .In_0(ALU_A),
        .In_1(ALU_A_stall), 
        .Sel(ASel_stall_2),
        .Out(ALU_A_64)
	    );
	
	Mux4_1_64 _mux_alu_source_B (
        .In_0(ALU_B_stall),
        .In_1(Imm_64), 
        .In_2({32'b0,rdata_B_64[31:0]}),
        .In_3(),
        .Sel(ALUSrc_B),
        .Out(ALU_B_64)
        );
        
    Mux4_1_64 _mux_alu_B_exe_mem (
        .In_0(rdata_B_64),
        .In_1(MEM_WB_wb),
        .In_2(ID_EXE_ALU_out_64),
        .In_3(Wt_data_64),  
        .Sel(BSel_stall_1),
        .Out(ALU_B_stall)
        );  
 
    REG_ID_EXE _reg_id_exe_ (
        .clk(CLK), 
        .rst(RST), 
        .CE(state_start), 
        .ID_EXE_dstall(ID_EXE_dstall),
        // Input
        .inst_in(IF_ID_inst_out),
        .PC(IF_ID_PC_64),
        .ALU_A(ALU_A_64),
        .ALU_B(ALU_B_64),
        .ALU_Control(ALU_Control),
        .Data_out(_W_D_FromRF_out),
        .mem_w(IF_ID_mem_w),
        .size(IF_ID_size),
        .DatatoReg(DatatoReg),
        .RegWrite(RegWrite),
        .W_D(W_D),

        .DMEM_Custom_Address(DMEM_Custom_Address),
        .DMEM_Custom_Address_ntt(DMEM_Custom_Address_ntt),
        .Buffer_data_out(keccak_dout),
        .written_reg(IF_ID_written_reg), 
        
        // Output
        .ID_EXE_inst_in(ID_EXE_inst_in),
        .ID_EXE_PC(ID_EXE_PC_64),
        .ID_EXE_ALU_A(ID_EXE_ALU_A_64),
        .ID_EXE_ALU_B(ID_EXE_ALU_B_64),
        .ID_EXE_ALU_Control(ID_EXE_ALU_Control),
        .ID_EXE_Data_out(ID_EXE_Data_out_64),
        .ID_EXE_mem_w(ID_EXE_mem_w),
        .ID_EXE_size(ID_EXE_size),
        .ID_EXE_DatatoReg(ID_EXE_DatatoReg),
        .ID_EXE_W_D(ID_EXE_W_D),
        .ID_EXE_RegWrite(ID_EXE_RegWrite),
        .ID_EXE_DMEM_Custom_Address(ID_EXE_DMEM_Custom_Address),
        .ID_EXE_DMEM_Custom_Address_ntt(ID_EXE_DMEM_Custom_Address_ntt),
        .ID_EXE_Buffer_data_out(ID_EXE_Buffer_data_out),
		
        .ID_EXE_written_reg(ID_EXE_written_reg), 
        .ntt_we(IF_ID_ntt_we),
        .ID_EXE_ntt_we(ID_EXE_ntt_we),
        .ntt_start(ntt_start),
        .ID_EXE_ntt_start(ID_EXE_ntt_start),
        .counter(IF_ID_counter),
        .ID_EXE_counter(ID_EXE_counter),
        .DMEM_Custom_Address_pwam(DMEM_Custom_Address_pwam),
        .ID_EXE_DMEM_Custom_Address_pwam(ID_EXE_DMEM_Custom_Address_pwam),
        .pwam_wea(IF_ID_pwam_wea),
        .ID_EXE_pwam_wea(ID_EXE_pwam_wea),
        .pwam_web(IF_ID_pwam_web),
        .ID_EXE_pwam_web(ID_EXE_pwam_web),
        .pwam_start(pwam_start),
        .ID_EXE_pwam_start(ID_EXE_pwam_start),
        .dmem_addr_sel(dmem_addr_sel),
        .ID_EXE_dmem_addr_sel(ID_EXE_dmem_addr_sel),
        .dmem_data_sel(dmem_data_sel),
        .ID_EXE_dmem_data_sel(ID_EXE_dmem_data_sel),
        .alu_sel(alu_sel),
        .ID_EXE_alu_sel(ID_EXE_alu_sel),
        .keccak_we(IF_ID_keccak_we),
        .ID_EXE_keccak_we(ID_EXE_keccak_we),
        .keccak_start(keccak_start),
        .ID_EXE_keccak_start(ID_EXE_keccak_start)
        );
        
        wire ID_EXE_alu_sel;
///////////////////////////////////////////////////////////////////
    ALU _alualu_ (
        .A(ID_EXE_ALU_A_64),
        .B(ID_EXE_ALU_B_64),
        .ALUOp(ID_EXE_ALU_Control[`ALU_CTRL_BITS-1:0]),
        .Result(ID_EXE_ALU_result)
        ); 

    REG_EXE_MEM _exe_mem_ (
        .clk(CLK), .rst(RST), .CE(state_start),
        // Input
        .inst_in(ID_EXE_inst_in),
        .PC(ID_EXE_PC_64),
        //// To MEM stage
        .ALU_out(ID_EXE_ALU_out_64),
        .Data_out(ID_EXE_Data_out_64),
        .mem_w(ID_EXE_mem_w),
        .size(ID_EXE_size),
        .DMEM_Custom_Address(ID_EXE_DMEM_Custom_Address),
        .DMEM_Custom_Address_ntt(ID_EXE_DMEM_Custom_Address_ntt),
        .Buffer_data_out(ID_EXE_Buffer_data_out),
        
        //// To WB stage
        .DatatoReg(ID_EXE_DatatoReg),
        .RegWrite(ID_EXE_RegWrite),
        .W_D(ID_EXE_W_D),
        .written_reg(ID_EXE_written_reg), 
        
        // Output
        .EXE_MEM_inst_in(EXE_MEM_inst_in),
        .EXE_MEM_PC(EXE_MEM_PC_64),
        .EXE_MEM_ALU_out(EXE_MEM_ALU_out_64),
        .EXE_MEM_Data_out(EXE_MEM_Data_out_64),
        .EXE_MEM_mem_w(EXE_MEM_mem_w),
        .EXE_MEM_size(EXE_MEM_size),
        .EXE_MEM_DatatoReg(EXE_MEM_DatatoReg),
        .EXE_MEM_RegWrite(EXE_MEM_RegWrite),
        .EXE_MEM_W_D(EXE_MEM_W_D),
        .EXE_MEM_DMEM_Custom_Address(EXE_MEM_DMEM_Custom_Address),
        .EXE_MEM_DMEM_Custom_Address_ntt(EXE_MEM_DMEM_Custom_Address_ntt),
        .EXE_MEM_Buffer_data_out(EXE_MEM_Buffer_data_out),
        
        .EXE_MEM_written_reg(EXE_MEM_written_reg), 
        .ntt_we(ID_EXE_ntt_we),
        .EXE_MEM_ntt_we(EXE_MEM_ntt_we),
        .ntt_start(ID_EXE_ntt_start),
        .EXE_MEM_ntt_start(EXE_MEM_ntt_start),
        .ntt_valid(ntt_dmem_write),
        .EXE_MEM_ntt_valid(EXE_MEM_ntt_dmem_write),
        .ntt_dout({32'b0,ntt_dout}),
        .EXE_MEM_ntt_dout(EXE_MEM_ntt_dout),
        .counter(ID_EXE_counter),
        .EXE_MEM_counter(EXE_MEM_counter),
        .DMEM_Custom_Address_pwam(ID_EXE_DMEM_Custom_Address_pwam),
        .EXE_MEM_DMEM_Custom_Address_pwam(EXE_MEM_DMEM_Custom_Address_pwam),
        .pwam_wea(ID_EXE_pwam_wea),
        .EXE_MEM_pwam_wea(EXE_MEM_pwam_wea),
        .pwam_web(ID_EXE_pwam_web),
        .EXE_MEM_pwam_web(EXE_MEM_pwam_web),
        .pwam_start(ID_EXE_pwam_start),
        .EXE_MEM_pwam_start(EXE_MEM_pwam_start),
        .pwam_valid(pwam_dmem_write),
        .EXE_MEM_pwam_valid(EXE_MEM_pwam_dmem_write),
        .pwam_dout({32'b0,pwam_dout}),
        .EXE_MEM_pwam_dout(EXE_MEM_pwam_dout),
        .dmem_addr_sel(ID_EXE_dmem_addr_sel),
        .EXE_MEM_dmem_addr_sel(EXE_MEM_dmem_addr_sel),
        .dmem_data_sel(ID_EXE_dmem_data_sel),
        .EXE_MEM_dmem_data_sel(EXE_MEM_dmem_data_sel),
        .keccak_we(ID_EXE_keccak_we),
        .EXE_MEM_keccak_we(EXE_MEM_keccak_we),
        .keccak_start(ID_EXE_keccak_start),
        .EXE_MEM_keccak_start(EXE_MEM_keccak_start),
        .keccak_valid(keccak_dmem_write),
        .EXE_MEM_keccak_valid(EXE_MEM_keccak_dmem_write)
        );
//    assign PC_DataOut = EXE_MEM_Data_out_64;
//////////////////////////////////////////////////////////////////
    REG_MEM_WB _mem_wb_ (
        .clk(CLK), .rst(RST), .CE(state_start),
        // Input
        .inst_in(EXE_MEM_inst_in),
//        .PC(EXE_MEM_PC_64),
        .ALU_out(EXE_MEM_ALU_out_64),
        .DatatoReg(EXE_MEM_DatatoReg),
        .RegWrite(EXE_MEM_RegWrite),
        .EXE_MEM_wb(Wt_data_64),

        // Output
        .MEM_WB_inst_in(MEM_WB_inst_in),
        .MEM_WB_ALU_out(MEM_WB_ALU_out_64),
        .MEM_WB_DatatoReg(MEM_WB_DatatoReg),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_wb(MEM_WB_Wt_data_64),
        .ntt_we(EXE_MEM_ntt_we),
        .MEM_WB_ntt_we(MEM_WB_ntt_we),
        .ntt_start(EXE_MEM_ntt_start),
        .MEM_WB_ntt_start(MEM_WB_ntt_start),
        .size(EXE_MEM_size),
        .MEM_WB_size(MEM_WB_size),
        .DMEM_addr_in(DMEM_Address_pwam),
        .MEM_WB_DMEM_addr_in(MEM_WB_DMEM_addr_in),
        .mem_w(DMEM_mem_w),
        .MEM_WB_mem_w(MEM_WB_mem_w),
        .pwam_wea(EXE_MEM_pwam_wea),
        .MEM_WB_pwam_wea(MEM_WB_pwam_wea),
        .pwam_web(EXE_MEM_pwam_web),
        .MEM_WB_pwam_web(MEM_WB_pwam_web),
        .pwam_start(EXE_MEM_pwam_start),
        .MEM_WB_pwam_start(MEM_WB_pwam_start),
        .keccak_we(EXE_MEM_keccak_we),
        .MEM_WB_keccak_we(MEM_WB_keccak_we),
        .keccak_start(EXE_MEM_keccak_start),
        .MEM_WB_keccak_start(MEM_WB_keccak_start)   
        );
/////////////////////////////////////////////////


    assign Wt_addr = MEM_WB_inst_in[11:7]; // rd, except for branch and store instructions
    
    Mux2_1_64 DMEM_MUX(
        .In_0(64'h0000000000000000),
        .In_1({3'b0, LDM_addra_in_64[`DATA_BITS-1:3]}),
        .Sel(~state_start),
        .Out(dmemmux_out_64)       
    );
      
    
    assign DMEM_mem_w = mem_w || EXE_MEM_ntt_dmem_write || EXE_MEM_pwam_dmem_write || EXE_MEM_keccak_dmem_write;
    
    dmem_in _dmem_in (
        .size(EXE_MEM_size),
        .dmem_write(DMEM_mem_w),
        .data_in(DMEM_pwam_dout),
        .addr(DMEM_Address_pwam),
        .web(web),
        .data_out(dmem_wr_data),
        .counter(ID_EXE_counter)
    );
        
    DualPort_RAM DATA_RAM (
        .clka(CLK),
        .wea(LDM_wea_in),
        .ena(1'b1),
        .addra(dmemmux_out_64[12:0]),
        .dina(LDM_dina_in_64),
        .douta(LDM_douta_out_64),
        .clkb(CLK),
        .web(web),
        .enb(1'b1),
        .addrb(DMEM_Address_pwam[15:3]),
        .dinb(dmem_wr_data),
        .doutb(data_in_64)
    );    
    
    dmem_out _dmem_out (
        .size(MEM_WB_size),
        .dmem_write(MEM_WB_mem_w),
        .data_in(data_in_64),
        .addr(MEM_WB_DMEM_addr_in),
        .data_out(dmem_rd_data),
        .counter(EXE_MEM_counter)
    );
        
    Mux2_1_64  MUX_W_D_ToRF(
        .In_0(EXE_MEM_ALU_out_64),
        .In_1({32'b0,EXE_MEM_ALU_out_64[31:0]}),
        .Sel(EXE_MEM_W_D),
        .Out(MUX_W_D_out)
    );    
      
    Mux4_1_64  _mux_regfile_data_in (
        .In_0(MUX_W_D_out),          // Others
        .In_1(dmem_rd_data),          // Load
        .In_2(64'h0),                // LUI and AUIPC
        .In_3(EXE_MEM_PC_64[`DATA_BITS-1:0] + 64'b0100),    // jal and jalr: PC + 4
        .Sel(EXE_MEM_DatatoReg[1:0]),
        .Out(Wt_data_64)
    );   
      
    Mux4_1_64  _mux_regfile_data_in_wb (
        .In_0(MEM_WB_Wt_data_64),          // Others
        .In_1(dmem_rd_data),          // Load
        .In_2(MEM_WB_Wt_data_64),                // LUI and AUIPC
        .In_3(MEM_WB_Wt_data_64),    // jal and jalr: PC + 4
        .Sel(MEM_WB_DatatoReg[1:0]),
        .Out(MEM_WB_wb)
    );   
          
//////////////////////////////////////////////////////////////////


    
  ////////////////////////////////////////////////////////////////////
        
      

    ntt_control  _ntt_control (
        .CLK(CLK),
        .RST(RST),
        .ntt_we(ntt_we),
        .ntt_valid(ntt_valid),
        .ntt_ready(ntt_ready),
        .ntt_start(ntt_start),
        .counter_q(counter_q),
        .ntt_we_real(ntt_we_real),
        .ntt_dmem_write(ntt_dmem_write)
        );

    ////////////////////////////////////////////////////// 
    
    assign pwam_din = dmem_rd_data[31:0];
    
    pwam _pwam (
        .clk(CLK),
        .srst(!RST),
        .start(MEM_WB_pwam_start),
        .wea(MEM_WB_pwam_wea),
        .dina(pwam_din), 
        .web(MEM_WB_pwam_web),
        .dinb(pwam_din),
        .valid(pwam_valid),
        .dout(pwam_dout),
        .ready(pwam_ready),
        .done(pwam_done),
        .mode(pwam_mode)
    );   
    
    pwam_control _pwam_ctrl (
        .CLK(CLK),
        .RST(RST),
        .pwam_we(pwam_we),
        .pwam_valid(pwam_valid),
        .pwam_ready(pwam_ready),
        .pwam_start(pwam_start),
        .counter_q(counter_q_pwam),
        .pwam_dmem_write(pwam_dmem_write),
        .pwam_wea(pwam_wea),
        .pwam_web(pwam_web),
        .pwam_addr_sel(DMEM_Base_Address_pwam_sel_from_rf),
        .pwam_counter(pwam_counter_sel)
    );
  
    
    assign counter_qq = counter_q_final>>1;
    
    Mux2_1_64 _mux_counter_pwam(
        .In_0(counter_q_final_1),                      //non-buffer
        .In_1(counter_q_pwam),     //buffer
        .Sel(pwam_counter_sel),     
        .Out(counter_q_final)   ////////////////////USE THIS        
    );
    
    pqc_cstall _pqc_control_stall_ (
        .Opcode(Inst_ROM_in[6:0]),
        .Funct3(Inst_ROM_in[14:12]),
        .Funct7(Inst_ROM_in[31:25]),
        .pwam_done(pwam_done),
        .ntt_done(ntt_done),
        .pwam_stall(pwam_stall),
        .pwam_we(pwam_we),
        .pwam_mode(pwam_mode),
        .ntt_stall(ntt_stall),
        .ntt_we(ntt_we),
        .keccak_stall(keccak_stall),
        .keccak_we(keccak_we),
        .keccak_done(keccak_done)
    );
    
    pqc_dstall _pqc_data_stall(
        .IF_ID_inst(IF_ID_inst_out),
        .ID_EXE_inst(ID_EXE_inst_in),
        .EXE_MEM_inst(EXE_MEM_inst_in),
        .MEM_WB_inst(MEM_WB_inst_in),
        .reg29_sel(reg29_sel),
        .reg30_sel(reg30_sel),
        .reg31_sel(reg31_sel)
    );
    
    
    
    Mux4_1_64 _mux_reg29_dstall_ (
        .In_0(IF_ID_Buffer_Base_Address),                 
        .In_1(ID_EXE_ALU_out_64),     
        .In_2(EXE_MEM_ALU_out_64),
        .In_3(MEM_WB_ALU_out_64),
        .Sel(reg29_sel),
        .Out(reg29_fwd_data)
    );
    
    Mux4_1_64 _mux_reg30_dstall_ (
        .In_0(IF_ID_Buffer_Load_Amount),                 
        .In_1(ID_EXE_ALU_out_64),     
        .In_2(EXE_MEM_ALU_out_64),
        .In_3(MEM_WB_ALU_out_64),
        .Sel(reg30_sel),
        .Out(reg30_fwd_data)
    );
    
    Mux4_1_64 _mux_reg31_dstall_ (
        .In_0(IF_ID_DMEM_Base_Address),                 
        .In_1(ID_EXE_ALU_out_64),     
        .In_2(EXE_MEM_ALU_out_64),
        .In_3(MEM_WB_ALU_out_64),
        .Sel(reg31_sel),
        .Out(reg31_fwd_data)
    );
    
    
    Adder _dmem_address (
        .A(reg31_fwd_data),
        .B(counter_q_keccak << 3),
        .C(DMEM_Custom_Address)
    );
    
    Adder _dmem_address_ntt (
        .A(reg31_fwd_data),
        .B(counter_qq << 3),
        .C(DMEM_Custom_Address_ntt)
    ); 
    
    Adder _dmem_address_pwam (
        .A(DMEM_Base_Address_pwam),
        .B(counter_qq << 3),
        .C(DMEM_Custom_Address_pwam)
    );
    
    Mux4_1_64 _mux_DMEM_base_addr_sel_pwam (
        .In_0({{32{reg29_fwd_data[31]}},reg29_fwd_data[31:0]}),                 //x31
        .In_1(reg30_fwd_data),     //
        .In_2(reg31_fwd_data),
        .In_3({{32{reg29_fwd_data[63]}},reg29_fwd_data[63:32]}),
        .Sel(DMEM_Base_Address_pwam_sel_from_rf),
        .Out(DMEM_Base_Address_pwam)
    );
    
    pqc_addr _pqc_address_ (
        .Opcode(IF_ID_inst_out[6:0]),
        .Funct3(IF_ID_inst_out[14:12]),
        .Funct7(IF_ID_inst_out[31:25]),
        .ntt_valid(ntt_valid),
        .pwam_valid(pwam_valid),
        .dmem_addr_sel(dmem_addr_sel),
        .dmem_data_sel(dmem_data_sel)
    );
    
    Mux4_1_64 _mux_dmem_data_(
        .In_0(data_out_64),                         //non-pqc
        .In_1(EXE_MEM_Buffer_data_out),             //keccak
        .In_2(EXE_MEM_ntt_dout),                    //ntt
        .In_3(EXE_MEM_pwam_dout),                   //pwam
        .Sel(EXE_MEM_dmem_data_sel),     
        .Out(DMEM_pwam_dout)
    );
    
    Mux4_1_64 _mux_dmem_addr_(
        .In_0(ALU_out_64),                          //non-pqc
        .In_1(EXE_MEM_DMEM_Custom_Address),         //keccak
        .In_2(EXE_MEM_DMEM_Custom_Address_ntt),     //ntt
        .In_3(EXE_MEM_DMEM_Custom_Address_pwam),    //pwam
        .Sel(EXE_MEM_dmem_addr_sel),     
        .Out(DMEM_Address_pwam)
    );
    
    ntt NTT (
        .clk(CLK),
        .srst(!RST),
        .start(MEM_WB_ntt_start),
        .we(MEM_WB_ntt_we),
        .md(ntt_md),
        .din(ntt_din),
        .valid(ntt_valid),
        .dout(ntt_dout),
        .done(ntt_done),
        .ntt_ready(ntt_ready)
    );  
    
    assign ntt_din = dmem_rd_data[31:0];


    keccak_core keccak (
        .CLK(CLK),
        .RST(RST),
        .start(MEM_WB_keccak_start),
        .we(MEM_WB_keccak_we),
        .din(dmem_rd_data),
        .valid(keccak_valid),
        .dout(keccak_dout),
        .ready(keccak_ready),
        .done(keccak_done)
    );
    
    keccak_controller keccak_ctrl(
        .CLK(CLK),
        .RST(RST),
        .keccak_we(keccak_we),
        .keccak_valid(keccak_valid),
        .keccak_ready(keccak_ready),
        .keccak_start(keccak_start),
        .counter_q(counter_q_keccak),
        .keccak_we_real(keccak_we_real),
        .keccak_dmem_write(keccak_dmem_write),
        .keccak_counter(keccak_counter_sel)
    );

    Mux2_1_64 _mux_counter_keccak(
        .In_0(counter_q_keccak),                      //non-buffer
        .In_1(counter_q),     //buffer
        .Sel(keccak_counter_sel),     
        .Out(counter_q_final_1)   ////////////////////USE THIS        
    );
        
endmodule

