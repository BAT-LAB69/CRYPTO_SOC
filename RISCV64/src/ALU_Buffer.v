`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2024 11:35:52
// Design Name: 
// Module Name: ALU_buffer
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

module ALU_buffer(
    input [`DATA_BITS-1:0] Data_in_0,
    input [`DATA_BITS-1:0] Data_in_1,
    input [`DATA_BITS-1:0] Data_in_2,
    input [`DATA_BITS-1:0] Data_in_3,
    input [`DATA_BITS-1:0] Data_in_4,
    input [`DATA_BITS-1:0] Data_in_5,
    input [`DATA_BITS-1:0] Data_in_6,
    input [`DATA_BITS-1:0] Data_in_7,
    input [`DATA_BITS-1:0] Data_in_8,
    input [`DATA_BITS-1:0] Data_in_9,
    input [`DATA_BITS-1:0] Data_in_10,
    input [`DATA_BITS-1:0] Data_in_11,
    input [`DATA_BITS-1:0] Data_in_12,
    input [`DATA_BITS-1:0] Data_in_13,
    input [`DATA_BITS-1:0] Data_in_14,
    input [`DATA_BITS-1:0] Data_in_15,
    input [`DATA_BITS-1:0] Data_in_16,
    input [`DATA_BITS-1:0] Data_in_17,
    input [`DATA_BITS-1:0] Data_in_18,
    input [`DATA_BITS-1:0] Data_in_19,
    input [`DATA_BITS-1:0] Data_in_20,
    input [`DATA_BITS-1:0] Data_in_21,
    input [`DATA_BITS-1:0] Data_in_22,
    input [`DATA_BITS-1:0] Data_in_23,
    input [`DATA_BITS-1:0] Data_in_24,
    output [`DATA_BITS-1:0] Data_out_0,
    output [`DATA_BITS-1:0] Data_out_1,
    output [`DATA_BITS-1:0] Data_out_2,
    output [`DATA_BITS-1:0] Data_out_3,
    output [`DATA_BITS-1:0] Data_out_4,
    output [`DATA_BITS-1:0] Data_out_5,
    output [`DATA_BITS-1:0] Data_out_6,
    output [`DATA_BITS-1:0] Data_out_7,
    output [`DATA_BITS-1:0] Data_out_8,
    output [`DATA_BITS-1:0] Data_out_9,
    output [`DATA_BITS-1:0] Data_out_10,
    output [`DATA_BITS-1:0] Data_out_11,
    output [`DATA_BITS-1:0] Data_out_12,
    output [`DATA_BITS-1:0] Data_out_13,
    output [`DATA_BITS-1:0] Data_out_14,
    output [`DATA_BITS-1:0] Data_out_15,
    output [`DATA_BITS-1:0] Data_out_16,
    output [`DATA_BITS-1:0] Data_out_17,
    output [`DATA_BITS-1:0] Data_out_18,
    output [`DATA_BITS-1:0] Data_out_19,
    output [`DATA_BITS-1:0] Data_out_20,
    output [`DATA_BITS-1:0] Data_out_21,
    output [`DATA_BITS-1:0] Data_out_22,
    output [`DATA_BITS-1:0] Data_out_23,
    output [`DATA_BITS-1:0] Data_out_24
    );
    wire [`DATA_BITS-1:0] BCa, BCe, BCi, BCo, BCu;
    wire [`DATA_BITS-1:0] Da, De, Di, Do, Du;
    
    wire [`DATA_BITS-1:0] Aba1, Abe1, Abi1, Abo1, Abu1;
    wire [`DATA_BITS-1:0] Aga1, Age1, Agi1, Ago1, Agu1;
    wire [`DATA_BITS-1:0] Aka1, Ake1, Aki1, Ako1, Aku1;
    wire [`DATA_BITS-1:0] Ama1, Ame1, Ami1, Amo1, Amu1;
    wire [`DATA_BITS-1:0] Asa1, Ase1, Asi1, Aso1, Asu1;
    
    wire [`DATA_BITS-1:0] Fba, Fbe, Fbi, Fbo, Fbu;
    wire [`DATA_BITS-1:0] Fga, Fge, Fgi, Fgo, Fgu;
    wire [`DATA_BITS-1:0] Fka, Fke, Fki, Fko, Fku;
    wire [`DATA_BITS-1:0] Fma, Fme, Fmi, Fmo, Fmu;
    wire [`DATA_BITS-1:0] Fsa, Fse, Fsi, Fso, Fsu;
   
    assign BCa = Data_in_0 ^ Data_in_5 ^ Data_in_10 ^ Data_in_15 ^ Data_in_20;
    assign BCe = Data_in_1 ^ Data_in_6 ^ Data_in_11 ^ Data_in_16 ^ Data_in_21;
    assign BCi = Data_in_2 ^ Data_in_7 ^ Data_in_12 ^ Data_in_17 ^ Data_in_22;
    assign BCo = Data_in_3 ^ Data_in_8 ^ Data_in_13 ^ Data_in_18 ^ Data_in_23;
    assign BCu = Data_in_4 ^ Data_in_9 ^ Data_in_14 ^ Data_in_19 ^ Data_in_24;
    
    assign Da = BCu ^ (BCe << 1) ^ (BCe >> (64-1));
    assign De = BCa ^ (BCi << 1) ^ (BCi >> (64-1));
    assign Di = BCe ^ (BCo << 1) ^ (BCo >> (64-1));
    assign Do = BCi ^ (BCu << 1) ^ (BCu >> (64-1));
    assign Du = BCo ^ (BCa << 1) ^ (BCa >> (64-1));
    
    assign Aba1 = Data_in_0 ^ Da;    
    assign Age1 = Data_in_6 ^ De;
    assign Aki1 = Data_in_12 ^ Di;
    assign Amo1 = Data_in_18 ^ Do;
    assign Asu1 = Data_in_24 ^ Du;
    assign Abo1 = Data_in_3 ^ Do;
    assign Agu1 = Data_in_9 ^ Du;
    assign Aka1 = Data_in_10 ^ Da;
    assign Ame1 = Data_in_16 ^ De;
    assign Asi1 = Data_in_22 ^ Di;
    assign Abe1 = Data_in_1 ^ De;
    assign Agi1 = Data_in_7 ^ Di;
    assign Ako1 = Data_in_13 ^ Do;
    assign Amu1 = Data_in_19 ^ Du;
    assign Asa1 = Data_in_20 ^ Da;
    assign Abu1 = Data_in_4 ^ Du;
    assign Aga1 = Data_in_5 ^ Da;
    assign Ake1 = Data_in_11 ^ De;
    assign Ami1 = Data_in_17 ^ Di;
    assign Aso1 = Data_in_23 ^ Do;
    assign Abi1 = Data_in_2 ^ Di;
    assign Ago1 = Data_in_8 ^ Do;
    assign Aku1 = Data_in_14 ^ Du;
    assign Ama1 = Data_in_15 ^ Da;
    assign Ase1 = Data_in_21 ^ De;
    
    assign Fba = Aba1;
    assign Fbe = (Abe1 << 1) ^ (Abe1 >> (64-1)); 
    assign Fbi = (Abi1 << 62) ^ (Abi1 >> (64-62)); 
    assign Fbo = (Abo1 << 28) ^ (Abo1 >> (64-28)); 
    assign Fbu = (Abu1 << 27) ^ (Abu1 >> (64-27)); 
    assign Fga = (Aga1 << 36) ^ (Aga1 >> (64-36)); 
    assign Fge = (Age1 << 44) ^ (Age1 >> (64-44)); 
    assign Fgi = (Agi1 << 6) ^ (Agi1 >> (64-6)); 
    assign Fgo = (Ago1 << 55) ^ (Ago1 >> (64-55)); 
    assign Fgu = (Agu1 << 20) ^ (Agu1 >> (64-20)); 
    assign Fka = (Aka1 << 3) ^ (Aka1 >> (64-3)); 
    assign Fke = (Ake1 << 10) ^ (Ake1 >> (64-10)); 
    assign Fki = (Aki1 << 43) ^ (Aki1 >> (64-43)); 
    assign Fko = (Ako1 << 25) ^ (Ako1 >> (64-25)); 
    assign Fku = (Aku1 << 39) ^ (Aku1 >> (64-39)); 
    assign Fma = (Ama1 << 41) ^ (Ama1 >> (64-41)); 
    assign Fme = (Ame1 << 45) ^ (Ame1 >> (64-45)); 
    assign Fmi = (Ami1 << 15) ^ (Ami1 >> (64-15)); 
    assign Fmo = (Amo1 << 21) ^ (Amo1 >> (64-21)); 
    assign Fmu = (Amu1 << 8) ^ (Amu1 >> (64-8)); 
    assign Fsa = (Asa1 << 18) ^ (Asa1 >> (64-18)); 
    assign Fse = (Ase1 << 2) ^ (Ase1 >> (64-2)); 
    assign Fsi = (Asi1 << 61) ^ (Asi1 >> (64-61)); 
    assign Fso = (Aso1 << 56) ^ (Aso1 >> (64-56)); 
    assign Fsu = (Asu1 << 14) ^ (Asu1 >> (64-14));  
      
    assign Data_out_0 = Fba ^ ((~Fge) & Fki);
    assign Data_out_1 = Fge ^ ((~Fki) & Fmo);
    assign Data_out_2 = Fki ^ ((~Fmo) & Fsu);
    assign Data_out_3 = Fmo ^ ((~Fsu) & Fba);
    assign Data_out_4 = Fsu ^ ((~Fba) & Fge);
    assign Data_out_5 = Fbo ^ ((~Fgu) & Fka);
    assign Data_out_6 = Fgu ^ ((~Fka) & Fme);
    assign Data_out_7 = Fka ^ ((~Fme) & Fsi);
    assign Data_out_8 = Fme ^ ((~Fsi) & Fbo);
    assign Data_out_9 = Fsi ^ ((~Fbo) & Fgu);
    assign Data_out_10 = Fbe ^ ((~Fgi) & Fko);
    assign Data_out_11 = Fgi ^ ((~Fko) & Fmu);
    assign Data_out_12 = Fko ^ ((~Fmu) & Fsa);
    assign Data_out_13 = Fmu ^ ((~Fsa) & Fbe);
    assign Data_out_14 = Fsa ^ ((~Fbe) & Fgi);
    assign Data_out_15 = Fbu ^ ((~Fga) & Fke);
    assign Data_out_16 = Fga ^ ((~Fke) & Fmi);
    assign Data_out_17 = Fke ^ ((~Fmi) & Fso);
    assign Data_out_18 = Fmi ^ ((~Fso) & Fbu);
    assign Data_out_19 = Fso ^ ((~Fbu) & Fga);
    assign Data_out_20 = Fbi ^ ((~Fgo) & Fku);
    assign Data_out_21 = Fgo ^ ((~Fku) & Fma);
    assign Data_out_22 = Fku ^ ((~Fma) & Fse);
    assign Data_out_23 = Fma ^ ((~Fse) & Fbi);
    assign Data_out_24 = Fse ^ ((~Fbi) & Fgo);
endmodule
