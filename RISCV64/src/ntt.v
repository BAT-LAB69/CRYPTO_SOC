`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2025 10:06:28 PM
// Design Name: 
// Module Name: ntt_v2
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


module ntt(
    input  wire         clk,
    input  wire         srst,
    input  wire         start,
    input  wire         we,
    input  wire         md,
    input  wire [31:0]  din,
    output reg         valid,
    output reg [31:0]  dout,
    output reg         done,
    output reg          ntt_ready
    );
    
    reg  [ 4:0] state, next_state;
    reg			s0, s1, valid_output;
    reg 		bram_we;
    reg  [ 7:0] bram_addra, bram_addrb;
    reg  [15:0] bram_dina, bram_dinb;
    wire [15:0] bram_douta, bram_doutb;
    wire [ 6:0] rom_addr;  
    reg  [63:0] rom_dout;    
    wire [63:0] rom_dout_0, rom_dout_1, rom_dout_2, rom_dout_3, rom_dout_4, rom_dout_5, rom_dout_6;
    wire [15:0] rom_dout_7;           
    reg         counter_ce, counter_sclr;
    reg  [ 6:0] counter_q;
    wire [ 7:0] mux0, mux1, mux2, mux3;
    wire [15:0] mux4, mux5;
    wire [31:0] mux6;
    reg  [15:0] zeta, bu_zeta, zeta_1, bu_zeta1, bu_zeta0;
    wire        bu_s;
    wire [15:0] bu_a, bu_b, bu_u, bu_v, bu_d, bu_t;
    wire [15:0] reg_d, reg_q;
    reg  [ 1:0] stage_sel_0, stage_sel_1;
    reg  [ 7:0] bram_addra_1, bram_addrb_1;
    reg  [15:0] bram_dina_1, bram_dinb_1;
    wire [15:0] bram_douta_1, bram_doutb_1;
    wire [ 7:0] mux0_1, mux1_1, mux2_1, mux3_1;
    wire [15:0] mux4_1, mux5_1;
    wire [31:0] mux6_1;
    reg  [63:0] rom_dout_s1;
    reg         bram_we_1, we_1, we_0;
    reg         s1_1;
    wire [15:0] addr_out;
    reg         s2; //odd or even stage
    reg         s3; //stage 0 or not
    wire [15:0] bred0, bred1;
    wire [31:0] p0, p1;
    wire [15:0] mred0, mred1;
    reg  [15:0] bred0_delay, bred1_delay;
    reg  [31:0] data_output;
    reg         done_output;
    wire [31:0] bu_dout;
    reg ntt_ready_delay;
    
    
    blk_mem_gen_0      BRAM_0   (.clka(clk), .wea(bram_we), .addra(bram_addra), .dina(bram_dina), .douta(bram_douta), .clkb(clk), .web(bram_we), .addrb(bram_addrb), .dinb(bram_dinb), .doutb(bram_doutb));
    blk_mem_gen_0      BRAM_1   (.clka(clk), .wea(bram_we_1), .addra(bram_addra_1), .dina(bram_dina_1), .douta(bram_douta_1), .clkb(clk), .web(bram_we_1), .addrb(bram_addrb_1), .dinb(bram_dinb_1), .doutb(bram_doutb_1));
    rom_gen_0          ROM_0    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_0));
    rom_gen_1          ROM_1    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_1));
    rom_gen_2          ROM_2    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_2));
    rom_gen_3          ROM_3    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_3));
    rom_gen_4          ROM_4    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_4));
    rom_gen_5          ROM_5    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_5));
    rom_gen_6          ROM_6    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_6));
    rom_gen_7          ROM_7    (.clk(clk), .srst(srst), .addr(rom_addr), .dout(rom_dout_7));
    butterfly_unit_0     BU     (.clk(clk), .srst(srst), .s(bu_s), .a(bu_a), .b(bu_b), .zeta(bu_zeta), .u(bu_u), .v(bu_v), .d(bu_d), .t(bu_t));
    c_shift_ram_3      Sft_RAM(.CLK(clk), .D(reg_d), .Q(reg_q));
    bart_red            BRed_0     (.clk(clk), .srst(srst), .din(bram_douta_1), .dout(bred0));
    bart_red            BRed_1     (.clk(clk), .srst(srst), .din(bram_doutb_1), .dout(bred1));
    mult_constants_ninv Mult_NInv_0(.clk(clk), .srst(srst), .din(bram_douta_1), .dout(p0));
    mult_constants_ninv Mult_NInv_1(.clk(clk), .srst(srst), .din(bram_doutb_1), .dout(p1));
    mont_red            MRed_0     (.clk(clk), .srst(srst), .din(p0), .dout(mred0));
    mont_red            MRed_1     (.clk(clk), .srst(srst), .din(p1), .dout(mred1));
    
    assign rom_addr = counter_q;
    assign mux0     = s0 ? rom_dout[15:8] : rom_dout[47:40];
    assign mux1     = s0 ? rom_dout[ 7:0] : rom_dout[39:32];
    assign mux2     = s1 ? mux0 : (s3 ? addr_out[15:8] : {counter_q, 1'h0});
    assign mux3     = s1 ? mux1 : (s3 ? addr_out[ 7:0] : ({counter_q, 1'h0} + 1'h1));
    assign mux4     = s0 ? rom_dout[15:0] : rom_dout[47:32];    
    assign mux5     = s0 ? rom_dout[31:16] : rom_dout[63:48];   
    assign mux6     = s0 ? {bu_u, bu_v} : {bu_d, bu_t};         
    assign bu_s     = s0; 
    assign bu_a     = s2 ? bram_douta_1 : bram_douta;
    assign bu_b     = s2 ? bram_doutb_1 : bram_doutb;
    assign reg_d    = s2 ? mux4_1 : mux4;                 
    //assign valid    = valid_output;
    assign md_out   = s0;
    assign addr_out = reg_q;
    assign bu_dout     = mux6;
    //assign dout     = data_output;
    assign mux0_1     = s0 ? rom_dout_s1[15:8] : rom_dout_s1[47:40];
    assign mux1_1     = s0 ? rom_dout_s1[ 7:0] : rom_dout_s1[39:32];
    assign mux2_1     = s1_1 ? mux0_1 : addr_out[15:8];            
    assign mux3_1     = s1_1 ? mux1_1 : addr_out[ 7:0];   
    assign mux4_1     = s0 ? rom_dout_s1[15:0] : rom_dout_s1[47:32];    
    assign mux5_1     = s0 ? rom_dout_s1[31:16] : rom_dout_s1[63:48];   
    assign mux6_1     = s0 ? {bred0_delay, bred1_delay} : {mred0, mred1};
    //assign done     = done_output;
    
    always @(posedge clk) begin         //NTT_mode
        if (srst) dout <= 0;
        else dout <= data_output;
    end
    
    always @(posedge clk) begin         //NTT_mode
        if (srst) valid <= 0;
        else valid <= valid_output;
    end
    
    always @(posedge clk) begin         //NTT_mode
        if (srst) done <= 0;
        else done <= done_output;
    end
    
    always @(posedge clk) begin         //NTT_mode
        if (srst) ntt_ready <= 0;
        else ntt_ready <= ntt_ready_delay;
    end
    
    always @ (*) begin
        case (stage_sel_0)
            2'h0:       rom_dout = rom_dout_0;
            2'h1:       rom_dout = rom_dout_2;
            2'h2:       rom_dout = rom_dout_4;
            2'h3:       rom_dout = rom_dout_6;
            default:    rom_dout = rom_dout_0;          
        endcase
    end
    always @ (*) begin
        case (stage_sel_1)
            2'h0:       rom_dout_s1 = rom_dout_1;
            2'h1:       rom_dout_s1 = rom_dout_3;
            2'h2:       rom_dout_s1 = rom_dout_5;
            2'h3:       rom_dout_s1 = {16'h0, rom_dout_7, 16'h0, rom_dout_7};
            default:    rom_dout_s1 = rom_dout_1;          
        endcase
    end
    
    always @(posedge clk) begin
        if (srst) counter_q <= 7'h0;
        else begin 
            if (counter_sclr) counter_q <= 7'h0;
            else if (counter_ce | we) counter_q <= counter_q + 1'h1;
            else counter_q <= counter_q;
        end
    end
    
    always @(posedge clk) begin         //NTT_mode
        if (srst) s0 <= 1'h0;
        else s0 <= start ? md : s0;
    end

    always @(posedge clk) begin         //BRAM_WE
        if (srst) bram_we <= 1'h0;
        else bram_we <= s3 ? we_0 : we;
    end
    

    always @(posedge clk) begin         //BRAM_WE
        if (srst) bram_we_1 <= 1'h0;
        else bram_we_1 <= we_1;
    end
    
    
    always @(posedge clk) begin         //BRAM_AddrA
        if (srst) bram_addra <= 8'h0;
        else bram_addra <= mux2;
    end
    
    always @(posedge clk) begin         //BRAM_AddrB
        if (srst) bram_addrb <= 8'h0;
        else bram_addrb <= mux3;
    end
    
    always @(posedge clk) begin         //A_In
        if (srst) bram_dina <= 16'h0;
        else bram_dina <= s3 ? bu_dout[31:16] : din[31:16];
    end
    
    always @(posedge clk) begin         //B_in
        if (srst) bram_dinb <= 16'h0;
        else bram_dinb <= s3 ? bu_dout[15:0] : din[15:0];
    end
    
    always @(posedge clk) begin         //Zeta
        if (srst) zeta <= 16'h0;
        else zeta <= mux5;
    end
    
    always @(posedge clk) begin         //Delayed_zeta
        if (srst) bu_zeta <= 16'h0;
        else bu_zeta <= s2 ? (s0 ? bu_zeta1 : zeta_1) : (s0 ? (s3 ? bu_zeta0 : zeta) : zeta);
    end
    
    always @(posedge clk) begin         //Counter
        if (srst) state <= 5'h0;
        else      state <= next_state;
    end
    
    always @(posedge clk) begin         //Zeta
        if (srst) zeta_1 <= 16'h0;
        else zeta_1 <= mux5_1;
    end
    
    always @(posedge clk) begin         //Delayed_zeta
        if (srst) bu_zeta1 <= 16'h0;
        else bu_zeta1 <= zeta_1;
    end
    
    always @(posedge clk) begin         //Delayed_zeta
        if (srst) bu_zeta0 <= 16'h0;
        else bu_zeta0 <= zeta;
    end
    
    always @(posedge clk) begin
        if (srst) bram_addra_1 <= 8'h0;
        else bram_addra_1 <= mux2_1;
    end
    
    always @(posedge clk) begin
        if (srst) bram_addrb_1 <= 8'h0;
        else bram_addrb_1 <= mux3_1;
    end
    
    always @(posedge clk) begin
        if (srst) bram_dina_1 <= 16'h0;
        else bram_dina_1 <= bu_dout[31:16];
    end
    
    always @(posedge clk) begin
        if (srst) bram_dinb_1 <= 16'h0;
        else bram_dinb_1 <= bu_dout[15:0];
    end
    
    always @(posedge clk) begin
        if (srst) bred0_delay <= 16'h0;
        else      bred0_delay <= bred0;
    end
    
    always @(posedge clk) begin
        if (srst) bred1_delay <= 16'h0;
        else      bred1_delay <= bred1;
    end
    
    always @(posedge clk) begin
        if (srst) data_output <= 32'h0;
        else data_output <= mux6_1;
    end
    
    reg stage_sclr_0, stage_ce_0, stage_sclr_1, stage_ce_1;
    
    always @(posedge clk) begin
        if (srst) stage_sel_0 <= 2'h0;
        else begin 
            if (stage_sclr_0) stage_sel_0 <= 2'h0;
            else if (stage_ce_0) stage_sel_0 <= stage_sel_0 + 1'h1;
            else stage_sel_0 <= stage_sel_0;
        end
    end
    
    always @(posedge clk) begin
        if (srst) stage_sel_1 <= 2'h3;
        else begin 
            if (stage_sclr_1) stage_sel_1 <= 2'h3;
            else if (stage_ce_1) stage_sel_1 <= stage_sel_1 + 1'h1;
            else stage_sel_1 <= stage_sel_1;
        end
    end
    
    always @(*) case (state)
        5'h0: next_state = start ? (state + 1'h1) : state;
        5'h1: next_state = (counter_q == 7'h09) ? (state + 1'h1) : state;
        5'h2: next_state = state + 1'h1;
        5'h3: next_state = (counter_q == 7'h7f) ? (state + 1'h1) : state;
        5'h4: next_state = (counter_q == 7'h08) ? (state + 1'h1) : state;
        5'h5: next_state = state + 1'h1;
        5'h6: next_state = state + 1'h1;
        5'h7: next_state = (counter_q == 7'h09) ? (state + 1'h1) : state;
        5'h8: next_state = (counter_q == 7'h7f) ? (state + 1'h1) : state;
        5'h9: next_state = (counter_q == 7'h08) ? (state + 1'h1) : state;
        5'ha: next_state = state + 1'h1;
        5'hb: next_state = state + 1'h1;
        5'hc: next_state = (counter_q == 7'h09) ? (state + 1'h1) : state;
        5'hd: next_state = (counter_q == 7'h7f) ? (state + 1'h1) : state;
        5'he: next_state = (counter_q == 7'h08) ? (state + 1'h1) : state;
        5'hf: next_state = (stage_sel_0 == 2'h3) ? (state + 1'h1) : 5'h6;
        5'h10: next_state = state + 1'h1;
        5'h11: next_state = (counter_q == 7'h07) ? (state + 1'h1) : state;
        5'h12: next_state = (counter_q == 7'h08) ? (state + 1'h1) : state;
        5'h13: next_state = (counter_q == 7'h09) ? (state + 1'h1) : state;
        5'h14: next_state = (counter_q == 7'h7f) ? (state + 1'h1) : state;
        5'h15: next_state = (counter_q == 7'h08) ? (state + 1'h1) : state;
        default: next_state = 3'h0;
    endcase
    
    always @(*) case (state)
        5'h0: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h0;  
            we_1         = 1'h0; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay    = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h1: begin
            s1           = 1'h1;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0;  
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h2, 5'h3, 5'h4: begin
            s1           = 1'h1;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h1; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h5: begin
            s1           = 1'h1;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h1; 
            we_1         = 1'h1; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h6: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h0; 
            we_1         = 1'h0; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h1;
        end
        5'h7: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h1;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h8, 5'h9: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h1;
            we_0         = 1'h1;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'ha: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h1;
            we_0         = 1'h1;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'hb: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h0; 
            we_1         = 1'h0; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h1;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h1;
            stage_ce_1   = 1'h0;
        end
        5'hc: begin
            s1           = 1'h1;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h1;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'hd, 5'he: begin
            s1           = 1'h1;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h1; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h1;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'hf: begin
            s1           = 1'h1;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
            we_1         = 1'h1; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h1;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h10: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h1;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h1;
        end
        5'h11: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay    = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h12: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h1;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h13: begin
            s1           = 1'h0;
            valid_output = 1'h1;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h1;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h14, 5'h15: begin
            s1           = 1'h0;
            valid_output = 1'h1;
            counter_ce   = 1'h1;
            counter_sclr = 1'h0;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        5'h16: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h1;
            we_1         = 1'h0; 
            s1_1         = 1'h1;
            s2           = 1'h1;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h1;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h1;
            stage_sclr_1 = 1'h1;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
        default: begin
            s1           = 1'h0;
            valid_output = 1'h0;
            counter_ce   = 1'h0;
            counter_sclr = 1'h0; 
            we_1         = 1'h0; 
            s1_1         = 1'h0;
            s2           = 1'h0;
            s3           = 1'h0;
            we_0         = 1'h0;
            done_output  = 1'h0;
            ntt_ready_delay  = 1'h0;
            stage_sclr_0 = 1'h0;
            stage_sclr_1 = 1'h0;
            stage_ce_0   = 1'h0;
            stage_ce_1   = 1'h0;
        end
    endcase
endmodule
