`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:38:05
// Design Name: 
// Module Name: RISCV_tb
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

module RISCV_tb(

    );
    reg Start_in;
    wire Complete_out;
    reg CLK, RST;
    reg [`DATA_BITS-1:0] CFG_addra_in_64;
    reg [`WORD_BITS-1:0] CFG_dina_in;
    reg CFG_ena_in;
    reg CFG_wea_in;
    wire [`DATA_BITS-1:0] data_out_64;
    wire [`WORD_BITS-1:0] IF_ID_inst_out;
    wire mem_w;
    wire [`DATA_BITS-1:0] data_in_64;
    reg [`DATA_BITS-1:0] LDM_dina_in_64;
	reg [`DATA_BITS-1:0] LDM_addra_in_64;
	reg [7:0] LDM_wea_in;
	wire [`DATA_BITS-1:0] LDM_douta_out_64;
	wire MEM_WB_RegWrite;
	wire [`DATA_BITS-1:0] Wt_data_64;
	wire [1:0] MEM_WB_DatatoReg;
    //reg [1:0] Branch;
    wire [`WORD_BITS-1:0] Inst_32;
    wire [`DATA_BITS-1:0] DMEM_R_data_out_64;
    wire [`DATA_BITS-1:0] DMEM_W_data_in_64;
//    wire [`WORD_BITS-1:0] Inst_ROM_in;
    reg [`DATA_BITS-1:0] i = 0;
    
	parameter clock = 20;
	always #(clock/2) CLK = ~CLK;
	

	always @ (posedge CLK) begin
	   i = i + 1;
	end
	       
	
	
	RISCV inst0 (.CLK(CLK), 
	                 .RST(RST),
//	                 .Inst_ROM_in(Inst_ROM_in),
	                 .CFG_addra_in_64(CFG_addra_in_64),
	                 .CFG_dina_in(CFG_dina_in),
	                 .CFG_ena_in(CFG_ena_in),
	                 .CFG_wea_in(CFG_wea_in),
	                 .LDM_dina_in_64(LDM_dina_in_64),
	                 .LDM_addra_in_64(LDM_addra_in_64),
	                 .LDM_wea_in(LDM_wea_in),
	                 .LDM_douta_out_64(LDM_douta_out_64),
	                 .start_in(Start_in),
	                 .complete_out(Complete_out)
	                 );	
//	initial begin
//		 $readmemh("D:/CE409/RISCV/Inst.txt", inst0._imem.imem);
//	end     
	       
//	initial begin
//		 $readmemh("C:/Users/TienLe/Downloads/C_Compiler/C_Compiler/SHA256_Stable_Backup/real.txt", inst0._imem.imem);
//	end
	/*initial begin
		 $readmemh("D:/DOAN1/dmem.txt", inst0._dmem.dmem);
	end*/

	initial begin
		#0 
		CLK = 0;
		RST = 0;
		CFG_wea_in = 0;
		#clock
		RST = 1;
		#clock
		LDM_wea_in = 8'hff;
		LDM_dina_in_64 = 64'h0000_0000_0000_0001;
		LDM_addra_in_64 = 64'h10;
		#clock
		LDM_dina_in_64 = 64'h0000000000008082;
		LDM_addra_in_64 = 64'h18;
		#clock
		LDM_dina_in_64 = 64'h800000000000808a;
		LDM_addra_in_64 = 64'h20;
		#clock
		LDM_dina_in_64 = 64'h8000000080008000;
		LDM_addra_in_64 = 64'h28;
		#clock
		LDM_dina_in_64 = 64'h000000000000808b;
		LDM_addra_in_64 = 64'h30;
		#clock
		LDM_dina_in_64 = 64'h0000000080000001;
		LDM_addra_in_64 = 64'h38;
		#clock
		LDM_dina_in_64 = 64'h8000000080008081;
		LDM_addra_in_64 = 64'h40;
		#clock
		LDM_dina_in_64 = 64'h8000000000008009;
		LDM_addra_in_64 = 64'h48;
		#clock
		LDM_dina_in_64 = 64'h000000000000008a;
		LDM_addra_in_64 = 64'h50;
		#clock
		LDM_dina_in_64 = 64'h0000000000000088;
		LDM_addra_in_64 = 64'h58;
		#clock
		LDM_dina_in_64 = 64'h0000000080008009;
		LDM_addra_in_64 = 64'h60;
		#clock
		LDM_dina_in_64 = 64'h000000008000000a;
		LDM_addra_in_64 = 64'h68;
		#clock
		LDM_dina_in_64 = 64'h000000008000808b;
		LDM_addra_in_64 = 64'h70;
		#clock
		LDM_dina_in_64 = 64'h800000000000008b;
		LDM_addra_in_64 = 64'h78;
		#clock
		LDM_dina_in_64 = 64'h8000000000008089;
		LDM_addra_in_64 = 64'h80;
		#clock
		LDM_dina_in_64 = 64'h8000000000008003;
		LDM_addra_in_64 = 64'h88;
		#clock
		LDM_dina_in_64 = 64'h8000000000008002;
		LDM_addra_in_64 = 64'h90;
		#clock
		LDM_dina_in_64 = 64'h8000000000000080;
		LDM_addra_in_64 = 64'h98;
		#clock
		LDM_dina_in_64 = 64'h000000000000800a;
		LDM_addra_in_64 = 64'ha0;
		#clock
		LDM_dina_in_64 = 64'h800000008000000a;
		LDM_addra_in_64 = 64'ha8;
		#clock
		LDM_dina_in_64 = 64'h8000000080008081;
		LDM_addra_in_64 = 64'hb0;
		#clock
		LDM_dina_in_64 = 64'h8000000000008080;
		LDM_addra_in_64 = 64'hb8;
		#clock
		LDM_dina_in_64 = 64'h0000000080000001;
		LDM_addra_in_64 = 64'hc0;
		#clock
		LDM_dina_in_64 = 64'h8000000080008008;
		LDM_addra_in_64 = 64'hc8;
		#clock
		LDM_dina_in_64 = 64'h8000000080008008;
		LDM_addra_in_64 = 64'hd0;
		
		#clock
        LDM_dina_in_64 = 64'h07140B9A0A0B08ED;
        LDM_addra_in_64 = 64'hE0;
        #clock
        LDM_dina_in_64 = 64'h00CA011F058E05D5;
        LDM_addra_in_64 = 64'hE8;
        #clock
        LDM_dina_in_64 = 64'h00B60629026E0C56;
        LDM_addra_in_64 = 64'hF0;
        #clock
        LDM_dina_in_64 = 64'h05BC073F084F03C2;
        LDM_addra_in_64 = 64'hF8;
        #clock
        LDM_dina_in_64 = 64'h017F010807D4023D;
        LDM_addra_in_64 = 64'h100;
        #clock
        LDM_dina_in_64 = 64'h0C7F06BF05B209C4;
        LDM_addra_in_64 = 64'h108;
        #clock
        LDM_dina_in_64 = 64'h026002DC03F90A58;
        LDM_addra_in_64 = 64'h110;
        #clock
        LDM_dina_in_64 = 64'h06DE0C34019B06FB;
        LDM_addra_in_64 = 64'h118;
        #clock
        LDM_dina_in_64 = 64'h03F70AD9028C04C7;
        LDM_addra_in_64 = 64'h120;
        #clock
        LDM_dina_in_64 = 64'h06F90BE705D307F4;
        LDM_addra_in_64 = 64'h128;
        #clock
        LDM_dina_in_64 = 64'h0A670BC10CF90204;
        LDM_addra_in_64 = 64'h130;
        #clock
        LDM_dina_in_64 = 64'h05BD007E087706AF;
        LDM_addra_in_64 = 64'h138;
        #clock
        LDM_dina_in_64 = 64'h033E0BF20CA709AC;
        LDM_addra_in_64 = 64'h140;
        #clock
        LDM_dina_in_64 = 64'h094A0C0A0774006B;
        LDM_addra_in_64 = 64'h148;
        #clock
        LDM_dina_in_64 = 64'h0A2C071D03C10B73;
        LDM_addra_in_64 = 64'h150;
        #clock
        LDM_dina_in_64 = 64'h080602A508D801C0;
        LDM_addra_in_64 = 64'h158;
        #clock
        LDM_dina_in_64 = 64'h034B022B01AE08B2;
        LDM_addra_in_64 = 64'h160;
        #clock
        LDM_dina_in_64 = 64'h0069060E0367081E;
        LDM_addra_in_64 = 64'h168;
        #clock
        LDM_dina_in_64 = 64'h0C1600B1024B01A6;
        LDM_addra_in_64 = 64'h170;
        #clock
        LDM_dina_in_64 = 64'h067506260B350BDE;
        LDM_addra_in_64 = 64'h178;
        #clock
        LDM_dina_in_64 = 64'h0C6E0487030A0C0B;
        LDM_addra_in_64 = 64'h180;
        #clock
        LDM_dina_in_64 = 64'h045F0AA705CB09F8;
        LDM_addra_in_64 = 64'h188;
        #clock
        LDM_dina_in_64 = 64'h015D0999028406CB;
        LDM_addra_in_64 = 64'h190;
        #clock
        LDM_dina_in_64 = 64'h0CB60C65014901A2;
        LDM_addra_in_64 = 64'h198;
        #clock
        LDM_dina_in_64 = 64'h0262025B04490331;
        LDM_addra_in_64 = 64'h1A0;
        #clock
        LDM_dina_in_64 = 64'h0180074807FC052A;
        LDM_addra_in_64 = 64'h1A8;
        #clock
        LDM_dina_in_64 = 64'h07CA04C20C790842;
        LDM_addra_in_64 = 64'h1B0;
        #clock
        LDM_dina_in_64 = 64'h0686085E00DC0997;
        LDM_addra_in_64 = 64'h1B8;
        #clock
        LDM_dina_in_64 = 64'h031A080307070860;
        LDM_addra_in_64 = 64'h1C0;
        #clock
        LDM_dina_in_64 = 64'h01DE099B09AB071B;
        LDM_addra_in_64 = 64'h1C8;
        #clock
        LDM_dina_in_64 = 64'h03DF03E40BCD0C95;
        LDM_addra_in_64 = 64'h1D0;
        #clock
        LDM_dina_in_64 = 64'h065C05F2074D03BE;
        LDM_addra_in_64 = 64'h1D8;
        
        #clock
        $readmemh("/home/duy/Tien/RV64I_CORE/Embedded_Software/riel.txt", inst0._imem.imem);

		#clock
		Start_in = 1;
		LDM_wea_in = 8'h00;
		
		while (!Complete_out)
		  @(posedge CLK);
		
		Start_in = 0;
		#clock
		//$readmemh("C:/Users/TienLe/Downloads/C_Compiler/C_Compiler/SHA256_Stable_Backup/reset.txt", inst0._imem.imem);
		LDM_dina_in_64 = 64'h0000000000000000;
        LDM_addra_in_64 = 64'h0;
        LDM_wea_in = 8'hff;
		#clock  
		LDM_wea_in = 8'h00;
		//$readmemh("C:/Users/TienLe/Downloads/C_Compiler/C_Compiler/SHA256_Stable_Backup/riel_dec.txt", inst0._imem.imem);
		#clock
		Start_in = 1;
		#200000 $stop;
	end
	
	
//    integer load = 0;
//    //initial begin
//        always @ (posedge CLK)
//        if (Inst_ROM_in[6:0] == 7'b0000011 || Inst_ROM_in[6:0] == 7'b0100011 
//            || (Inst_ROM_in[6:0] == 7'b0001011 && Inst_ROM_in[14:12] == 3'b011 && (Inst_ROM_in[31:25] == 7'b0000000 || Inst_ROM_in[31:25] == 7'b0000001))) begin
//            load = load + 1;
//        end
//   //end

endmodule