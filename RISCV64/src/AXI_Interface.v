`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2024 09:45:49 AM
// Design Name: 
// Module Name: AXI_Interface
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



`timescale 1 ns / 1 ps
`include "common.vh"
	module AXI_Interface #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of ID for for write address, write data, read address and read data
		parameter integer C_S_AXI_ID_WIDTH	= 1,
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 64,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 40,
		// Width of optional user defined signal in write address channel
		parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
		// Width of optional user defined signal in read address channel
		parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
		// Width of optional user defined signal in write data channel
		parameter integer C_S_AXI_WUSER_WIDTH	= 0,
		// Width of optional user defined signal in read data channel
		parameter integer C_S_AXI_RUSER_WIDTH	= 0,
		// Width of optional user defined signal in write response channel
		parameter integer C_S_AXI_BUSER_WIDTH	= 0
	)
	(
 // Users to add ports here
        output wire LED0,
        output wire LED1,
        output wire LED2,
        output wire LED3,
        output wire LED4,
        output wire LED5,
        output wire LED6,
        output wire LED7, 
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write Address ID
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
		// Write address
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each
    // write transaction.
		input wire [3 : 0] S_AXI_AWQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_AWREGION,
		// Optional User-defined signal in the write address channel.
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and
    // control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_AWREADY,
		// Write Data
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write last. This signal indicates the last transfer
    // in a write burst.
		input wire  S_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		output wire  S_AXI_WREADY,
		// Response ID tag. This signal is the ID tag of the
    // write response.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
		// Write response. This signal indicates the status
    // of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Optional User-defined signal in the write response channel.
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address ID. This signal is the identification
    // tag for the read address group of signals.
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each
    // read transaction.
		input wire [3 : 0] S_AXI_ARQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_ARREGION,
		// Optional User-defined signal in the read address channel.
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and
    // control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output reg  S_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
		// Read Data
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of
    // the read transfer.
		output reg [1 : 0] S_AXI_RRESP,
		// Read last. This signal indicates the last transfer
    // in a read burst.
		output reg  S_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		output reg  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4FULL signals
	reg  [`AXI_DWIDTH_BITS-1:0]						complete_rg;
	wire [`AXI_DWIDTH_BITS-1:0]         			LDM_douta_wr;
	wire 						         			complete_wr;
	reg  [C_S_AXI_ADDR_WIDTH-1 : 0]                 S_AXI_ARADDR_rg;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg [C_S_AXI_BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	    axi_araddr;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata_w;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rlast;
	reg [C_S_AXI_RUSER_WIDTH-1 : 0] 	axi_ruser;
	reg  	axi_rvalid;
	// aw_wrap_en determines wrap boundary and enables wrapping
	wire aw_wrap_en;
	// ar_wrap_en determines wrap boundary and enables wrapping
	wire ar_wrap_en;
	// aw_wrap_size is the size of the write transfer, the
	// write address wraps to a lower address if upper address
	// limit is reached
	wire [63:0]  aw_wrap_size ; 
	// ar_wrap_size is the size of the read transfer, the
	// read address wraps to a lower address if upper address
	// limit is reached
	wire [63:0]  ar_wrap_size ; 
	// The axi_awv_awr_flag flag marks the presence of write address valid
	reg axi_awv_awr_flag;
	//The axi_arv_arr_flag flag marks the presence of read address valid
	reg axi_arv_arr_flag; 
	// The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
	reg [7:0] axi_awlen_cntr;
	//The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
	reg [7:0] axi_arlen_cntr;
	reg [1:0] axi_arburst;
	reg [1:0] axi_awburst;
	reg [7:0] axi_arlen;
	reg [7:0] axi_awlen;
	//local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	//ADDR_LSB is used for addressing 32/64 bit registers/memories
	//ADDR_LSB = 2 for 32 bits (n downto 2) 
	//ADDR_LSB = 3 for 42 bits (n downto 3)

//	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32)+ 1;
    //localparam integer ADDR_LSB = C_S_AXI_DATA_WIDTH/32;
    localparam integer ADDR_LSB = 3;
	localparam integer OPT_MEM_ADDR_BITS = 12;
	localparam integer USER_NUM_MEM = 256;
	//----------------------------------------------
	//-- Signals for user logic memory space example
	//------------------------------------------------
	wire [OPT_MEM_ADDR_BITS:0] mem_address;
	wire [USER_NUM_MEM-1:0] mem_select;
	reg [C_S_AXI_DATA_WIDTH-1:0] mem_data_out[0 : USER_NUM_MEM-1];

	genvar i;
	genvar j;
	genvar mem_byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BUSER	= axi_buser;
	assign S_AXI_BVALID	= axi_bvalid;
	//assign S_AXI_ARREADY	= axi_arready;
	//assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RDATA	= (S_AXI_ARADDR_rg == `FINISH_BASE_PHYS)? complete_rg:LDM_douta_wr;
	//assign S_AXI_RRESP	= axi_rresp;
	//assign S_AXI_RLAST	= axi_rlast;
	assign S_AXI_RUSER	= axi_ruser;
	//assign S_AXI_RVALID	= axi_rvalid;
	assign S_AXI_BID = S_AXI_AWID;
	assign S_AXI_RID = S_AXI_ARID;
	assign  aw_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_awlen)); 
	assign  ar_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_arlen)); 
	assign  aw_wrap_en = ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign  ar_wrap_en = ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      S_AXI_ARREADY <= 1'b0;
		  S_AXI_RVALID	<= 1'b0;
		  S_AXI_RLAST	<= 1'b0;
	      S_AXI_RRESP	<= 2'b0;
	    end 
		else begin
		  S_AXI_ARREADY <= axi_arready;
		  S_AXI_RVALID	<= axi_rvalid;
		  S_AXI_RLAST	<= axi_rlast;
	      S_AXI_RRESP	<= axi_rresp;
		end
	end
	  
	// Implement axi_awready generation

	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      axi_awv_awr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          // slave is ready to accept an address and
	          // associated control signals
	          axi_awready <= 1'b1;
	          axi_awv_awr_flag  <= 1'b1; 
	          // used for generation of bresp() and bvalid
	        end
	      else if (S_AXI_WLAST && axi_wready)          
	      // preparing to accept next address after current write burst tx completion
	        begin
	          axi_awv_awr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_awaddr latching

	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	      axi_awlen_cntr <= 0;
	      axi_awburst <= 0;
	      axi_awlen <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag)
	        begin
	          // address latching 
	          axi_awaddr <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:0];  
	           axi_awburst <= S_AXI_AWBURST; 
	           axi_awlen <= S_AXI_AWLEN;     
	          // start address of transfer
	          axi_awlen_cntr <= 0;
	        end   
	      else if((axi_awlen_cntr <= axi_awlen) && axi_wready && S_AXI_WVALID)        
	        begin

	          axi_awlen_cntr <= axi_awlen_cntr + 1;

	          case (axi_awburst)
	            2'b00: // fixed burst
	            // The write address for all the beats in the transaction are fixed
	              begin
	                axi_awaddr <= axi_awaddr;          
	                //for awsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The write address for all the beats in the transaction are increments by awsize
	              begin
	                axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //awaddr aligned to 4 byte boundary
	                axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The write address wraps when the address reaches wrap boundary 
	              if (aw_wrap_en)
	                begin
	                  axi_awaddr <= (axi_awaddr - aw_wrap_size); 
	                end
	              else 
	                begin
	                  axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                  axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}}; 
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_awaddr <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //for awsize = 4 bytes (010)
	              end
	          endcase              
	        end
	    end 
	end       
	// Implement axi_wready generation

	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if ( ~axi_wready && S_AXI_WVALID && axi_awv_awr_flag)
	        begin
	          // slave can accept the write data
	          axi_wready <= 1'b1;
	        end
	      //else if (~axi_awv_awr_flag)
	      else if (S_AXI_WLAST && axi_wready)
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       
	// Implement write response logic generation

	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid <= 0;
	      axi_bresp <= 2'b0;
	      axi_buser <= 0;
	    end 
	  else
	    begin    
	      if (axi_awv_awr_flag && axi_wready && S_AXI_WVALID && ~axi_bvalid && S_AXI_WLAST )
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	          // 'OKAY' response 
	        end                   
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	          //check if bready is asserted while bvalid is high) 
	          //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	 end   
	// Implement axi_arready generation

	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_arv_arr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          axi_arready <= 1'b1;
	          axi_arv_arr_flag <= 1'b1;
	        end
	      else if (axi_rvalid && S_AXI_RREADY && axi_arlen_cntr == axi_arlen)
	      // preparing to accept next address after current read completion
	        begin
	          axi_arv_arr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_araddr latching

	//This process is used to latch the address when both 
	//S_AXI_ARVALID and S_AXI_RVALID are valid. 
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_araddr <= 0;
	      axi_arlen_cntr <= 0;
	      axi_arburst <= 0;
	      axi_arlen <= 0;
	      axi_rlast <= 1'b0;
	      axi_ruser <= 0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_arv_arr_flag)
	        begin
	          // address latching 
	          axi_araddr <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0]; 
	          axi_arburst <= S_AXI_ARBURST; 
	          axi_arlen <= S_AXI_ARLEN;     
	          // start address of transfer
	          axi_arlen_cntr <= 0;
	          axi_rlast <= 1'b0;
	        end   
	      else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && S_AXI_RREADY)        
	        begin
	         
	          axi_arlen_cntr <= axi_arlen_cntr + 1;
	          axi_rlast <= 1'b0;
	        
	          case (axi_arburst)
	            2'b00: // fixed burst
	             // The read address for all the beats in the transaction are fixed
	              begin
	                axi_araddr       <= axi_araddr;        
	                //for arsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The read address for all the beats in the transaction are increments by awsize
	              begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The read address wraps when the address reaches wrap boundary 
	              if (ar_wrap_en) 
	                begin
	                  axi_araddr <= (axi_araddr - ar_wrap_size); 
	                end
	              else 
	                begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_araddr <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
	                //for arsize = 4 bytes (010)
	              end
	          endcase              
	        end
	      else if((axi_arlen_cntr == axi_arlen) && ~axi_rlast && axi_arv_arr_flag )   
	        begin
	          axi_rlast <= 1'b1;
	        end          
	      else if (S_AXI_RREADY)   
	        begin
	          axi_rlast <= 1'b0;
	        end          
	    end 
	end       
	// Implement axi_arvalid generation

	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arv_arr_flag && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
			  axi_rresp  <= 2'b0; 
	          // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end            
	    end
	end 
	
	// ------------------------------------------
	// -- Example code to access user logic memory region
	// ------------------------------------------

	generate
	  if (USER_NUM_MEM >= 1)
	    begin
	      assign mem_select  = 1;
	      assign mem_address = (axi_arv_arr_flag? axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:(axi_awv_awr_flag? axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:0));
	    end
	endgenerate
	     
	// implement Block RAM(s)
	generate 
	  for(i=0; i<= USER_NUM_MEM-1; i=i+1)
	    begin:BRAM_GEN
	      wire mem_rden;
	      wire mem_wren;
	
	      assign mem_wren = axi_wready && S_AXI_WVALID ;
	
	      assign mem_rden = axi_arv_arr_flag ; //& ~axi_rvalid
	     
	      for(mem_byte_index=0; mem_byte_index<= (C_S_AXI_DATA_WIDTH/8-1); mem_byte_index=mem_byte_index+1)
	      begin:BYTE_BRAM_GEN
	        wire [8-1:0] data_in ;
	        wire [8-1:0] data_out;
	        reg  [8-1:0] byte_ram [0 : 15];
	        integer  j;
	     
	        //assigning 8 bit data
	        assign data_in  = S_AXI_WDATA[(mem_byte_index*8+7) -: 8];
	        assign data_out = byte_ram[mem_address];
	     
	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_wren && S_AXI_WSTRB[mem_byte_index])
	            begin
	              byte_ram[mem_address] <= data_in;
	            end   
	        end    
	      
	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_rden)
	            begin
	              mem_data_out[i][(mem_byte_index*8+7) -: 8] <= data_out;
	            end   
	        end    
	               
	    end
	  end       
	endgenerate
	//Output register or memory read data

	always @( mem_data_out, axi_rvalid)
	begin
	  if (axi_rvalid) 
	    begin
	      // Read address mux
	      axi_rdata <= mem_data_out[0];
	    end   
	  else
	    begin
	      axi_rdata <= 64'h0000000000000000;
	    end       
	end    

	// Add user logic here
	always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
	   if (S_AXI_ARESETN == 1'b0) begin
	       S_AXI_ARADDR_rg <= 0;
	   end
	   else begin
	       if(axi_arv_arr_flag) begin
	           S_AXI_ARADDR_rg <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0];
	       end
	       else begin
	           S_AXI_ARADDR_rg <= S_AXI_ARADDR_rg;
	       end
	   end
	end
  //-----------------------------------------------------//
  //          			 LED CONTROL                     // 
  //-----------------------------------------------------//	
    reg [7:0] LED_REG;
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
	begin
	  if ( S_AXI_ARESETN == 1'b0 ) begin
	       LED_REG <= 8'b0;
	  end
	  else begin 
	       if (S_AXI_WVALID) begin
	           if (S_AXI_AWADDR == `LED_CTROL_PHYS) begin
	               LED_REG <= S_AXI_WDATA[7:0];
	           end	           
	       end
	       else begin
	           LED_REG <= LED_REG;
	       end
	  end
    end
    assign LED0 = LED_REG[7:7];
    assign LED1 = LED_REG[6:6];
    assign LED2 = LED_REG[5:5];
    assign LED3 = LED_REG[4:4];
    assign LED4 = LED_REG[3:3];
    assign LED5 = LED_REG[2:2];
    assign LED6 = LED_REG[1:1];
    assign LED7 = LED_REG[0:0];
  //-----------------------------------------------------//
  //          			Input Signals                    // 
  //-----------------------------------------------------//	
    
	reg	start_rg;
	///ILA_Definition
	// start_rg BLOCK
	wire           ILA_S_AXI_ARESETN;
	wire           ILA_S_AXI_WREADY;
	wire           ILA_axi_awv_awr_flag;
	wire [39:0]    ILA_axi_awaddr;
	wire           ILA_start_rg;
	// configuration memory BLOCK:
	wire [`CFG_ADDR_BITS-1:0]        ILA_CFG_addra_rg;
    wire [`CFG_DATA_BITS-1:0]        ILA_CFG_dina_rg;
    wire                             ILA_CFG_ena_rg;
    wire                             ILA_CFG_wea_rg;
    wire                             ILA_S_AXI_WVALID;
    // local data memory BLOCK:
    wire [`LDM_ADDR_BITS-1:0]               ILA_LDM_addra_rg;
    wire [`LDM_DATA_BITS-1:0]               ILA_LDM_dina_rg;
    wire                                    ILA_LDM_ena_rg;
    wire                                    ILA_LDM_wea_rg;
    wire [7:0]                              ILA_s_axi_wstrb_rg;
    wire                                    ILA_S_AXI_WREADY_rg;
    // Mutual signal:
    wire [7:0]                              ILA_S_AXI_WSTRB;
    wire [63:0]                             ILA_S_AXI_WDATA;
    wire [39:0]                             ILA_S_AXI_AWADDR;
    wire                                    ILA_reset_rg;
    wire                                    ILA_complete;
    wire                                    ILA_state_start;
    wire [63:0]                             ILA_LDM_douta_wr;
    wire [39:0]                             ILA_axi_araddr;
    wire                                    ILA_axi_arv_arr_flag;
    wire                                    ILA_axi_rvalid;
    wire [39:0]                             ILA_S_AXI_ARADDR_rg;
    wire [63:0]                             ILA_complete_rg;
    wire [63:0]                             ILA_S_AXI_RDATA;
    
    assign ILA_S_AXI_AWADDR = S_AXI_AWADDR;
    assign ILA_axi_araddr = axi_araddr;
    assign ILA_axi_arv_arr_flag = axi_arv_arr_flag;
    assign ILA_axi_rvalid = axi_rvalid;
    assign ILA_S_AXI_RDATA = S_AXI_RDATA;
    ////////////ILA_DEBUG/////////
    ila_debug ila(
        .clk(S_AXI_ACLK),

        .probe0(ILA_S_AXI_ARESETN),
        .probe1(ILA_S_AXI_WREADY),
        .probe2(ILA_axi_awv_awr_flag),
        .probe3(ILA_axi_awaddr),
        .probe4(ILA_start_rg),
        .probe5(ILA_CFG_addra_rg),
        .probe6(ILA_CFG_dina_rg),
        .probe7(ILA_CFG_ena_rg),
        .probe8(ILA_CFG_wea_rg),
        .probe9(ILA_S_AXI_WVALID),
        .probe10(ILA_LDM_addra_rg),
        .probe11(ILA_LDM_dina_rg),
        .probe12(ILA_LDM_ena_rg),
        .probe13(ILA_LDM_wea_rg),
        .probe14(ILA_s_axi_wstrb_rg),
        .probe15(ILA_S_AXI_WREADY_rg),
        .probe16(ILA_S_AXI_WSTRB),
        .probe17(ILA_S_AXI_WDATA),
        .probe18(ILA_S_AXI_AWADDR),
        .probe19(ILA_reset_rg),
        .probe20(ILA_complete),
        .probe21(ILA_state_start),
        .probe22(ILA_LDM_douta_wr),
        .probe23(ILA_axi_araddr),
        .probe24(ILA_axi_arv_arr_flag),
        .probe25(ILA_axi_rvalid),
        .probe26(ILA_S_AXI_ARADDR_rg),
        .probe27(ILA_complete_rg),
        .probe28(ILA_S_AXI_RDATA)
    );
    //////////////////////////////
    reg reset_rg;
    reg state_start;
    
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_WREADY && axi_awv_awr_flag && (axi_awaddr == `RESET_BASE_PHYS))
	    begin
	      reset_rg <= 0;
	      start_rg <= 0;
	    end 
	  else
	    begin 
	      reset_rg <= 1;
	      if (S_AXI_WREADY && axi_awv_awr_flag && (axi_awaddr == `START_BASE_PHYS))
	        begin	          
	          start_rg <= S_AXI_WDATA[32:32];
	        end   
	      else begin
	          start_rg <= 0;
	        end            
	    end
	end
	
	assign ILA_S_AXI_ARESETN       = S_AXI_ARESETN;
	assign ILA_S_AXI_WREADY        = S_AXI_WREADY;
	assign ILA_axi_awv_awr_flag    = axi_awv_awr_flag;
	assign ILA_axi_awaddr          = axi_awaddr;
	assign ILA_start_rg            = start_rg;
	assign  ILA_S_AXI_WDATA        = S_AXI_WDATA;
	///*** Confiiguration Memory ***///
	reg [`CFG_ADDR_BITS-1:0]         CFG_addra_rg;
	reg [`CFG_DATA_BITS-1:0]         CFG_dina_rg;
	reg 					         CFG_ena_rg;
	reg 					         CFG_wea_rg;
	    
	always @( posedge S_AXI_ACLK )
	begin
	  if ( reset_rg == 1'b0 )
	    begin
	      CFG_addra_rg 	<= 0;
		  CFG_dina_rg 	<= 0;
		  CFG_ena_rg 	<= 1;
		  CFG_wea_rg 	<= 0;
	    end 
	  else
	    begin    
	      if (S_AXI_WREADY && (axi_awaddr[39:24] == `CFG_BASE_PHYS)) begin
	        CFG_addra_rg 	<= {48'b0,axi_awaddr[15:0]};
//			if(S_AXI_WSTRB == 8'hFF) begin
//				CFG_dina_rg 	<= S_AXI_WDATA[(C_S_AXI_DATA_WIDTH)-1 : 0];
//			end
//			else begin
//				CFG_dina_rg 	<= 0;
//			end
            if (S_AXI_WSTRB == 8'h0F || S_AXI_WSTRB == 8'hF0) begin
			     if (S_AXI_WSTRB == 8'h0F) begin
			         CFG_dina_rg <= S_AXI_WDATA[31 : 0];
			     end
			     else begin
			         CFG_dina_rg <= S_AXI_WDATA[63 : 32];
			     end
			end
			else begin
			     CFG_dina_rg <= 0;
			end			
			CFG_wea_rg 		<= S_AXI_WVALID & S_AXI_WREADY;
	      end   
	      else begin
	        CFG_addra_rg 	<= 0;
			CFG_dina_rg 	<= 0;
			CFG_ena_rg 		<= 1;
			CFG_wea_rg 		<= 0;
	        end            
	    end
	end
	assign ILA_CFG_addra_rg        = CFG_addra_rg;
    assign ILA_CFG_dina_rg         = CFG_dina_rg;
    assign ILA_CFG_ena_rg          = CFG_ena_rg;
    assign ILA_CFG_wea_rg          = CFG_wea_rg;
	///*** Local Data Memory ***///	
	reg [`LDM_ADDR_BITS-1:0]         		LDM_addra_rg;
	reg [`LDM_DATA_BITS-1:0]          		LDM_dina_rg;
	reg 					              	LDM_ena_rg;
	reg [7:0]				              	LDM_wea_rg;
    reg [7:0]                               s_axi_wstrb_rg;
    reg                                     S_AXI_WREADY_rg;
	always @(posedge S_AXI_ACLK)
	begin
	  if ( reset_rg == 1'b0 )
	    begin	      
		  LDM_addra_rg 	<= 0;
		  LDM_dina_rg 	<= 0;
		  LDM_ena_rg 	<= 0;
		  LDM_wea_rg 	<= 8'b0;
		  S_AXI_WREADY_rg <= 0;
		  s_axi_wstrb_rg <= 0;
	    end 
	  else
	    begin    
	      S_AXI_WREADY_rg <= S_AXI_WREADY;
	      s_axi_wstrb_rg <= S_AXI_WSTRB;
	      if (S_AXI_WREADY && axi_awv_awr_flag && (axi_awaddr[39:28] == `LMM_BASE_PHYS) && (s_axi_wstrb_rg == 8'hFF)) begin
	        LDM_addra_rg 	<= {48'b0,axi_awaddr[15:0]};
			LDM_dina_rg 	<= S_AXI_WDATA;
			LDM_ena_rg 		<= S_AXI_WREADY;			
			LDM_wea_rg 		<= {8{S_AXI_WREADY}};
	      end  	
          else if (axi_arv_arr_flag && (axi_araddr[39:28] == `LMM_BASE_PHYS)) begin
            LDM_addra_rg 	<= {48'b0,axi_araddr[15:0]};
            LDM_ena_rg 		<= axi_arv_arr_flag;
            LDM_wea_rg 		<= {8{~axi_arv_arr_flag}};
          end       
	      else begin 
	        LDM_addra_rg 	<= 0;
			LDM_dina_rg 	<= 0;
			LDM_ena_rg 		<= 0;
			LDM_wea_rg 		<= 8'b0;
	        end            
	    end
	end
	assign ILA_LDM_addra_rg                 = LDM_addra_rg;
    assign ILA_LDM_dina_rg                  = LDM_dina_rg;
    assign ILA_LDM_ena_rg                   = LDM_ena_rg;
    assign ILA_LDM_wea_rg                   = LDM_wea_rg;
    assign ILA_s_axi_wstrb_rg               = s_axi_wstrb_rg;
	assign ILA_S_AXI_WREADY_rg              = S_AXI_WREADY_rg;
	assign ILA_S_AXI_ARADDR_rg              = S_AXI_ARADDR_rg;

  //-----------------------------------------------------//
  //          			Output Signals                   // 
  //-----------------------------------------------------//  
  
  wire 						         				LDM_douta_valid_wr;
  
  	always @(S_AXI_ACLK)
	begin
	  if ( reset_rg == 1'b0 )
	    begin	      
		  complete_rg 	<= `AXI_DWIDTH_BITS'd0;
	    end 
	  else
	    begin     	    
	        complete_rg		<= {63'd0,complete_wr};	             
	    end
	end
	always @(posedge S_AXI_ACLK) begin
        if (start_rg == 1'b1) begin
            if (complete_wr == 1'b0) begin
                state_start <= 1'b1;
            end else if (complete_wr == 1'b1) begin
                state_start <= 1'b0;
            end
        end
        else if (complete_wr == 1'b1) begin
                state_start <= 1'b0;
        end
    end
	assign ILA_reset_rg = reset_rg;
	assign ILA_state_start = state_start;
	assign ILA_complete_rg = complete_rg;
RISCV cgra(
  .CLK(S_AXI_ACLK),
  .RST(reset_rg),

  //-----------------------------------------------------//
  //          			Input Signals                    // 
  //-----------------------------------------------------//
  .start_in(state_start),
  
  ///*** Confiiguration Memory ***///
  .CFG_addra_in_64(CFG_addra_rg),
  .CFG_dina_in(CFG_dina_rg),
  .CFG_ena_in(CFG_ena_rg),
  .CFG_wea_in(CFG_wea_rg),
				
  ///*** Local Data Memory ***///				
  .LDM_addra_in_64(LDM_addra_rg),
  .LDM_dina_in_64(LDM_dina_rg),
  .LDM_ena_in(LDM_ena_rg),
  .LDM_wea_in(LDM_wea_rg),

  //-----------------------------------------------------//
  //          			Output Signals                   // 
  //-----------------------------------------------------//  
  .complete_out(complete_wr),
  .LDM_douta_out_64(LDM_douta_wr)
 );
 assign ILA_complete = complete_wr;
 assign ILA_LDM_douta_wr = LDM_douta_wr;
////	// User logic ends


	endmodule
