//////////////////////////////////////////////////////////////////////////////////
/*                          PARAMETERS USED IN THIS DESIGN                      */
//////////////////////////////////////////////////////////////////////////////////
        `define WORD_BITS                32 //Define WIDTH of almost REG and WIRE in design
        `define DATA_BITS                64
        `define ADDR_BITS                5  //Define WIDTH of rs,rd address signal
        `define ADDR_BITS_ZERO           `ADDR_BITS'd0
        `define ZERO                     64'h0000000000000000 
        `define NOP_INST                 32'h00000013 //Define HEX CODE of NOP instruction
        `define XLEN                     32
        `define BRAM_WIDTH               32 
        `define BRAM_INST_DEPTH          4096
        `define BRAM_DMEM_DEPTH          8192

//////////////////////////////////////////////////////////////////////////////////        
/*                          INSTRUCTION OPCODE                                  */
//////////////////////////////////////////////////////////////////////////////////
        `define R_TYPE                      7'b0110011
        `define R_TYPE_W                    7'b0111011
        `define I_TYPE                      7'b0010011
        `define I_TYPE_LOAD                 7'b0000011
        `define I_TYPE_JALR                 7'b1100111
        `define S_TYPE                      7'b0100011
        `define S_TYPE_SD                   7'b0100011
        `define B_TYPE                      7'b1100011  
        `define U_TYPE_LUI                  7'b0110111
        `define U_TYPE_AUIPC                7'b0010111        
        `define J_TYPE                      7'b1101111
        `define IW_TYPE                     7'b0011011
        //`define M_TYPE                      7'b0111011
        

//////////////////////////////////////////////////////////////////////////////////        
/*                                ALU CONTROL                                   */
//////////////////////////////////////////////////////////////////////////////////
        `define ALU_CTRL_BITS               6
        `define ALU_ADD                     6'b000000
        `define ALU_SUB                     6'b000001
        `define ALU_SLL                     6'b000010
        `define ALU_SLT                     6'b000011
        `define ALU_SLTU                    6'b000100
        `define ALU_XOR                     6'b000101
        `define ALU_SRL                     6'b000110
        `define ALU_SRA                     6'b000111
        `define ALU_OR                      6'b001000
        `define ALU_AND                     6'b001001
        `define ALU_BEQ                     6'b001010
        `define ALU_BNE                     6'b001011
        `define ALU_BLT                     6'b001100
        `define ALU_BGE                     6'b001101
        `define ALU_BLTU                    6'b001110
        `define ALU_BGEU                    6'b001111
        `define ALU_ROTLEFT                 6'b010000
        `define ALU_SIGMA0                  6'b010001
        `define ALU_SIGMA1                  6'b010010
        `define ALU_SUM0                    6'b010011
        `define ALU_SUM1                    6'b010100
        `define ALU_CH                      6'b010101
        `define ALU_MAJ                     6'b010110
        `define ALU_DIV                     6'b010111
        `define ALU_DIVU                    6'b011000
        `define ALU_REM                     6'b011001
        `define ALU_REMU                    6'b011010
        `define ALU_MUL                     6'b011011
        `define ALU_MULH                    6'b011100 
        `define ALU_MULHSU                  6'b011101   
        `define ALU_MULHU                   6'b011110
        `define ALU_CHI                     6'b011111
        `define ALU_ROL                     6'b100000  
        `define ALU_LUI                     6'b100001
        `define ALU_AUIPC                   6'b100010
        `define ALU_MULW                    6'b100011
        `define ALU_SLLW                    6'b100100
        `define ALU_SRLW                    6'b100101
        `define ALU_SRAW                    6'b100110
        `define ALU_DEFAULT                 6'b111111         
        
        ///***AXI_INTERFACE***///
        `define LED_CTROL_PHYS           40'h0402000000
        `define RESET_BASE_PHYS          40'h0400000000
        `define START_BASE_PHYS          40'h0400000004
        `define FINISH_BASE_PHYS         40'h0400000010
        `define CFG_BASE_PHYS            16'h0401
        `define LMM_BASE_PHYS            12'h048 
        `define AXI_DWIDTH_BITS          64          
        ///*** Configuration Memory ***///
        `define CFG_COUNT     58
        `define CFG_ADDR_BITS 64
        `define CFG_DATA_BITS 32
        ///*** Local Data Memory    ***///
        `define LDM_COUNT     32 //Depending On AMOUNT Of Line in DATA_RAM From CPU.
        `define LDM_ADDR_BITS 64
        `define LDM_DATA_BITS 64
        ///*** TestBench Local Variable ***///
	    `define TB_DELAY	340
	    `define TB_LOOP_DELAY	270