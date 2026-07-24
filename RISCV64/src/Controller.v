`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2024 16:12:00
// Design Name: 
// Module Name: Controller
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

module Controller(
        input [6:0] Opcode,
		input [2:0] Funct3,
		input [6:0] Funct7,
		input [1:0] Funct2,
		input wire BrEq,
		input wire BrLT,
		output reg [1:0] ALUSrc_A,
		output reg [1:0] ALUSrc_B,
		output reg [1:0] MemtoReg,
		output reg [1:0] Branch,
		output reg RegWrite,
		output reg MemWrite,
		output reg [`ALU_CTRL_BITS-1:0] ALUOp,
//		output reg [1:0] B_H_W, //not used yet
		output reg W_D, //0 mean Double Word operation, 1 means Word operation
		output reg W_D_FromRF,
//		output reg Sign,
		output reg [2:0] size,
		output reg BrUn,
		output reg ntt_md,
		output reg alu_sel
    );
    always @(*) begin
        BrUn = 0;
		ALUSrc_B = 0;
		ALUSrc_A = 0;
		MemtoReg = 2'b0;
		Branch = 0;
		RegWrite = 0;
		W_D = 0;
		W_D_FromRF = 0;
		MemWrite = 0;
//		B_H_W = 2'b0; // default: immediate is a word
//		Sign = 1'b1; // default: signed extension to "write_data"
		size = 3;
		ntt_md = 1;
		ALUOp = `ALU_DEFAULT;
		alu_sel = 0;
        case (Opcode)
            //R_TYPE
            `R_TYPE_W: begin
                RegWrite = 1;
                case (Funct7)
                    7'b0000000: begin
                        case (Funct3)
                            3'b000: ALUOp = `ALU_ADD;
                            3'b001: ALUOp = `ALU_SLL;
                            3'b101: ALUOp = `ALU_SRL;
                            default: ALUOp = `ALU_DEFAULT;
                        endcase
                    end
                    7'b0100000: begin
                        case (Funct3)
                            3'b000: ALUOp = `ALU_SUB;
                            3'b101: ALUOp = `ALU_SRA;
                            default: ALUOp = `ALU_DEFAULT;
                        endcase     
                    end 
                    7'b0000001: begin
                        case (Funct3)
                            3'b000: begin
                                ALUOp = `ALU_MULW;
                                alu_sel = 1;
                            end
                            3'b100, 3'b101: ALUOp = `ALU_DIV; 
                            default: ALUOp = `ALU_DEFAULT;
                        endcase     
                    end 
                    default: ALUOp = `ALU_DEFAULT;  
                endcase     
            end
            `R_TYPE: begin
                RegWrite = 1;
                case (Funct7)
                    7'b0000000: begin
                        case (Funct3)
                            3'b000: ALUOp = `ALU_ADD;
                            3'b001: ALUOp = `ALU_SLL;
                            3'b010: ALUOp = `ALU_SLT;
                            3'b011: ALUOp = `ALU_SLTU;
                            3'b100: ALUOp = `ALU_XOR;
                            3'b101: ALUOp = `ALU_SRL;
                            3'b110: ALUOp = `ALU_OR;
                            3'b111: ALUOp = `ALU_AND;
                            default: ALUOp = `ALU_DEFAULT;
                        endcase
                    end
                    7'b0100000: begin
                        case (Funct3)
                            3'b000: ALUOp = `ALU_SUB;
                            3'b101: ALUOp = `ALU_SRA;
                            default: ALUOp = `ALU_DEFAULT;
                        endcase     
                    end   
                    7'b0000001: begin
                        case (Funct3)
                            3'b000: begin
                                ALUOp = `ALU_MUL;
                                alu_sel = 1;
                            end
                            3'b001: ALUOp = `ALU_MULH;
                            3'b010: ALUOp = `ALU_MULHSU;
                            3'b011: ALUOp = `ALU_MULHU;
                            3'b100: ALUOp = `ALU_DIV;
                            3'b101: ALUOp = `ALU_DIVU;
                            3'b110: ALUOp = `ALU_REM;
                            3'b111: ALUOp = `ALU_REMU;
                            default: ALUOp = `ALU_DEFAULT;
                        endcase     
                    end   
                    default: ALUOp = `ALU_DEFAULT;               
                endcase
            end
            
            `I_TYPE: begin
                RegWrite = 1;
                ALUSrc_B = 2'b01; 
                case (Funct3)
                    3'b000: ALUOp = `ALU_ADD; //ADDI                  
                    3'b001: ALUOp = `ALU_SLL; //SLLI                   
                    3'b010: ALUOp = `ALU_SLT; //SLTI                   
                    3'b011: ALUOp = `ALU_SLTU; //SLTIU                   
                    3'b100: ALUOp = `ALU_XOR; //XORI                    
                    3'b101: 
                        case (Funct7[6:1])
                             6'b000000: ALUOp = `ALU_SRL; // SRLI
			                 6'b010000: ALUOp = `ALU_SRA; // SRAI
			                 default: ALUOp = `ALU_DEFAULT;
                        endcase
                    3'b110: ALUOp = `ALU_OR; //ORI                   
                    3'b111: ALUOp = `ALU_AND; //ANDI                   
                    default: ALUOp = `ALU_DEFAULT;                    
                endcase
            end
            
            `I_TYPE_LOAD: begin
                ALUOp = `ALU_ADD;		
				MemtoReg = 2'b01;
				RegWrite = 1;
				ALUSrc_B = 2'b01;
				case (Funct3)
				    3'b000: begin//LB 
//				        B_H_W = 2'b01;
				        size = 0;
				    end    
				    3'b001: begin//LH
//				        B_H_W = 2'b10; 
				        size = 1;
				    end
				    3'b010: begin //LW
//				        B_H_W = 2'b0;
				        ALUSrc_B = 2'b01;
				        size = 2;
				    end
				    3'b011: begin // LD
//				        B_H_W = 2'b01; // byte
//				        Sign = 1'b0;
				        size = 3;
				    end
				    3'b100: begin // LBU
//				        B_H_W = 2'b01; // byte
//				        Sign = 1'b0;
				        size = 4;
				    end
				    3'b101: begin //LHU
//				        B_H_W = 2'b10; // half word
//				        Sign = 1'b0;
				        ALUSrc_B = 2'b01;
				        size = 5;
				    end
				    3'b110: begin //LWU
//				        B_H_W = 2'b10; // half word
//				        Sign = 1'b0;
				        ALUSrc_B = 2'b01;
				        size = 6;
				    end
				    default: begin
//				        B_H_W = 2'b0;
				        ALUSrc_B = 2'b01;
				    end
				endcase
            end
            
            `S_TYPE: begin
                ALUOp = `ALU_ADD;
			    MemWrite = 1;
			    ALUSrc_B = 2'b01;
			    case (Funct3)
                    3'b000: begin //SB
                        //ALUSrc_B = 2'b10;
//			            B_H_W = 2'b01; // byte
			            size = 0;
                    end
                    3'b001: begin //SH
                        //ALUSrc_B = 2'b10;
//			            B_H_W = 2'b10; // half word
			            size = 1;
                    end
                    3'b010: begin //SW       
                        size = 2;
                    end			     
                    3'b011: begin //SD
                        ALUSrc_B = 2'b01;
			            W_D_FromRF = 1'b0;
			            size = 3;
                    end    
			        default: begin
//			            B_H_W = 2'b0;
			            ALUSrc_B = 2'b01;
			            W_D_FromRF = 1'b1;
			        end
			    endcase
            end
            
            `B_TYPE: begin
                case (Funct3)
			        3'b000: begin // BEQ
			            //ALUOp = `ALU_SUB; 
			            //Branch = {1'b0, Zero};
			            Branch = (BrEq) ? 1 : 0;
			        end 
			        3'b001: begin // BNE
			            //ALUOp = `ALU_SUB;
			            //Branch = {1'b0, ~Zero};
			            Branch = (BrEq) ? 0 : 1;
			        end
			        3'b100: begin // BLT
			            //ALUOp = `ALU_SLT;
			            //Branch = {1'b0, Zero};
			            Branch = (BrLT) ? 1 : 0;
			        end
			        3'b101: begin // BGE
			            //ALUOp = `ALU_BGE;
			            Branch = (BrLT) ? 0 : 1;
			            //Branch = {1'b0, Zero};
			        end
			        3'b110: begin // BLTU
			            //ALUOp = `ALU_SLTU;
			            BrUn = 1;
			            Branch = (BrLT) ? 1 : 0;
			            //Branch = {1'b0, Zero}; 
			        end
			        3'b111: begin // BGEU
			            //ALUOp = `ALU_BGEU;
			            BrUn = 1;
			            Branch = (BrLT) ? 0 : 1;
			            //Branch = {1'b0, Zero};
			        end
			        default: begin
			            ALUOp = `ALU_DEFAULT;
			            //Branch = 
			            //Branch = {1'b0, Zero};
                    end
			    endcase
            end
            
            `J_TYPE: begin
                Branch = 2'b10;
				MemtoReg = 2'b11;
				RegWrite = 1;
            end
            
            `I_TYPE_JALR: begin
                Branch = 2'b11;
                MemtoReg = 2'b11;
                RegWrite = 1;
            end
            
            `U_TYPE_LUI: begin
                ALUOp = `ALU_LUI;
                //MemtoReg = 2'b10;
                ALUSrc_A = 2'b10;
                ALUSrc_B = 2'b01;
                RegWrite = 1;
            end
            
            `U_TYPE_AUIPC: begin
                ALUOp = `ALU_AUIPC;
                //MemtoReg = 2'b10;
                ALUSrc_A = 2'b10;
                ALUSrc_B = 2'b01;
                RegWrite = 1;
            end
            
            `IW_TYPE: begin
                RegWrite = 1;
                case (Funct3)
                    3'b000: begin // ADDIW  
                        ALUOp = `ALU_ADD;                  
                        ALUSrc_B = 2'b01;
                        ALUSrc_A = 2'b01;
                        W_D = 1'b1;
                    end
                    3'b001: begin //SLLIW
                        ALUOp = `ALU_SLLW; // SLLI
                        ALUSrc_B = 2'b01;
                        ALUSrc_A = 2'b01;
                        W_D = 1'b1;
                    end
                    3'b101: begin
                        ALUSrc_B = 2'b01;
			            ALUSrc_A = 2'b01;
			            W_D = 1'b1;
			            case (Funct7)
			                7'b0000000: ALUOp = `ALU_SRLW; // SRLIW
			                7'b0100000: ALUOp = `ALU_SRAW; // SRAIw
			                default: ALUOp = `ALU_DEFAULT;
			            endcase
                    end
                    default: ALUOp = `ALU_DEFAULT;
                endcase
            end    
            
                   
            //CustomOpcode
		    7'b0001011: begin
		        RegWrite = 1;
		        case(Funct3)
		            3'b000: begin
		                case (Funct7)
		                   7'b0000010: ALUOp = `ALU_ROTLEFT; //ROTLeft
		                   7'b0000111: ALUOp = `ALU_SIGMA0; //SIGMA0
		                   7'b0001000: ALUOp = `ALU_SIGMA1; //SIGMA1
		                   7'b0001001: ALUOp = `ALU_SUM0; //SUM0
		                   7'b0001010: ALUOp = `ALU_SUM1; //SUM1
		                   default: ALUOp = `ALU_DEFAULT;
		                endcase
		            end
		            3'b001: begin
                        ALUSrc_B = 2'b01; 
                        ALUOp = `ALU_ROL; //ROL 
		            end
		            3'b011: begin
		                case (Funct7)
                            7'b0000000: begin //LBUF
                                RegWrite = 0;
                                MemWrite = 0;
		                    end
		                    7'b0000001: begin //SBUF
		                        RegWrite = 0;
		                        MemWrite = 1;
		                    end
		                    7'b0000010: begin
		                        RegWrite = 0;
		                        ALUOp = `ALU_ADD;
		                    end
		                    7'b0000011: begin //NTT
                                RegWrite = 0;
                                MemWrite = 0;	
                                ntt_md = 1;	 
                                MemtoReg = 1;     
                                size = 7;              
		                    end
		                    7'b0000100: begin //INVNTT
		                        RegWrite = 0;
                                MemWrite = 0;
                                ntt_md = 0;
                                MemtoReg = 1;  
                                size = 7;
		                    end
		                    7'b0000111: begin //PWAM
		                        RegWrite = 0;
                                MemWrite = 0;
                                MemtoReg = 1;  
                                size = 7;
		                    end
		                    7'b0000101: begin //LPWAM
		                        RegWrite = 0;
                                MemWrite = 0;
                                MemtoReg = 1;  
                                size = 7;
		                    end
		                    default: ALUOp = `ALU_DEFAULT;
		                endcase
		            end
		            default: ALUOp = `ALU_DEFAULT;
		        endcase
		    end
		    //3rs instruction
		    7'b0101011: begin
		        RegWrite = 1;
		        case(Funct3)
		            3'b000: begin
		                case (Funct2)
		                   2'b10: begin
		                      ALUOp = `ALU_CH; //CH instruction
		                      //DatatoReg = 2'b01;
		                   end
		                   2'b11: ALUOp = `ALU_MAJ; //Maj instruction
		                   default: ALUOp = `ALU_DEFAULT;
		                endcase
		            end
		            3'b001: begin
		                case (Funct2)
		                   2'b00: begin
		                      ALUOp = `ALU_CHI; 
		                   end 
		                   default: ALUOp = `ALU_DEFAULT;
		                endcase   
		            end
		            default: ALUOp = `ALU_DEFAULT;
		        endcase
		    end
            7'b0011111: begin
                RegWrite = 1;
                ALUSrc_B = 2'b01; 
                case (Funct3)
                    3'b000: ALUOp = `ALU_ROL; //ROL                                
                    default: ALUOp = `ALU_DEFAULT;                    
                endcase
            end
            default: ALUOp = `ALU_DEFAULT;
        endcase
    end      
endmodule


