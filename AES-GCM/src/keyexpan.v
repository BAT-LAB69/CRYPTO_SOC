`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: keyexpan
// Description: AES-256 Key Expansion (pure structural RTL with sbox instances)
//////////////////////////////////////////////////////////////////////////////////

module keyexpan(
    input  wire [255:0]  key,
    output wire [1919:0] roundKeys   // 15 round keys x 128 bit = 1920 bit
);
    wire [31:0] w [0:59];

    // w[0..7] directly from 256-bit key
    assign w[0] = key[255:224];
    assign w[1] = key[223:192];
    assign w[2] = key[191:160];
    assign w[3] = key[159:128];
    assign w[4] = key[127:96];
    assign w[5] = key[95:64];
    assign w[6] = key[63:32];
    assign w[7] = key[31:0];

    // Helper functions for rotWord and rcon
    function [31:0] rotWord(input [31:0] x);
        begin
            rotWord = {x[23:0], x[31:24]};
        end
    endfunction

    // 13 subWord operations needed for AES-256 key schedule:
    // idx 0: i=8  (rotWord(w[7]))
    // idx 1: i=12 (w[11])
    // idx 2: i=16 (rotWord(w[15]))
    // idx 3: i=20 (w[19])
    // idx 4: i=24 (rotWord(w[23]))
    // idx 5: i=28 (w[27])
    // idx 6: i=32 (rotWord(w[31]))
    // idx 7: i=36 (w[35])
    // idx 8: i=40 (rotWord(w[39]))
    // idx 9: i=44 (w[43])
    // idx 10: i=48 (rotWord(w[47]))
    // idx 11: i=52 (w[51])
    // idx 12: i=56 (rotWord(w[55]))

    wire [31:0] sub_in  [0:12];
    wire [31:0] sub_out [0:12];

    assign sub_in[0]  = rotWord(w[7]);
    assign sub_in[1]  = w[11];
    assign sub_in[2]  = rotWord(w[15]);
    assign sub_in[3]  = w[19];
    assign sub_in[4]  = rotWord(w[23]);
    assign sub_in[5]  = w[27];
    assign sub_in[6]  = rotWord(w[31]);
    assign sub_in[7]  = w[35];
    assign sub_in[8]  = rotWord(w[39]);
    assign sub_in[9]  = w[43];
    assign sub_in[10] = rotWord(w[47]);
    assign sub_in[11] = w[51];
    assign sub_in[12] = rotWord(w[55]);

    // Instantiate 13 x 4 = 52 S-Boxes directly
    genvar g;
    generate
        for (g = 0; g < 13; g = g + 1) begin : gen_sbox
            sbox sb3 (.a(sub_in[g][31:24]), .c(sub_out[g][31:24]));
            sbox sb2 (.a(sub_in[g][23:16]), .c(sub_out[g][23:16]));
            sbox sb1 (.a(sub_in[g][15:8]),  .c(sub_out[g][15:8]));
            sbox sb0 (.a(sub_in[g][7:0]),   .c(sub_out[g][7:0]));
        end
    endgenerate

    // RCON constants:
    // rcon(1) = 32'h01000000
    // rcon(2) = 32'h02000000
    // rcon(3) = 32'h04000000
    // rcon(4) = 32'h08000000
    // rcon(5) = 32'h10000000
    // rcon(6) = 32'h20000000
    // rcon(7) = 32'h40000000

    // i = 8..15
    assign w[8]  = w[0] ^ sub_out[0] ^ 32'h01000000;
    assign w[9]  = w[1] ^ w[8];
    assign w[10] = w[2] ^ w[9];
    assign w[11] = w[3] ^ w[10];
    assign w[12] = w[4] ^ sub_out[1];
    assign w[13] = w[5] ^ w[12];
    assign w[14] = w[6] ^ w[13];
    assign w[15] = w[7] ^ w[14];

    // i = 16..23
    assign w[16] = w[8]  ^ sub_out[2] ^ 32'h02000000;
    assign w[17] = w[9]  ^ w[16];
    assign w[18] = w[10] ^ w[17];
    assign w[19] = w[11] ^ w[18];
    assign w[20] = w[12] ^ sub_out[3];
    assign w[21] = w[13] ^ w[20];
    assign w[22] = w[14] ^ w[21];
    assign w[23] = w[15] ^ w[22];

    // i = 24..31
    assign w[24] = w[16] ^ sub_out[4] ^ 32'h04000000;
    assign w[25] = w[17] ^ w[24];
    assign w[26] = w[18] ^ w[25];
    assign w[27] = w[19] ^ w[26];
    assign w[28] = w[20] ^ sub_out[5];
    assign w[29] = w[21] ^ w[28];
    assign w[30] = w[22] ^ w[29];
    assign w[31] = w[23] ^ w[30];

    // i = 32..39
    assign w[32] = w[24] ^ sub_out[6] ^ 32'h08000000;
    assign w[33] = w[25] ^ w[32];
    assign w[34] = w[26] ^ w[33];
    assign w[35] = w[27] ^ w[34];
    assign w[36] = w[28] ^ sub_out[7];
    assign w[37] = w[29] ^ w[36];
    assign w[38] = w[30] ^ w[37];
    assign w[39] = w[31] ^ w[38];

    // i = 40..47
    assign w[40] = w[32] ^ sub_out[8] ^ 32'h10000000;
    assign w[41] = w[33] ^ w[40];
    assign w[42] = w[34] ^ w[41];
    assign w[43] = w[35] ^ w[42];
    assign w[44] = w[36] ^ sub_out[9];
    assign w[45] = w[37] ^ w[44];
    assign w[46] = w[38] ^ w[45];
    assign w[47] = w[39] ^ w[46];

    // i = 48..55
    assign w[48] = w[40] ^ sub_out[10] ^ 32'h20000000;
    assign w[49] = w[41] ^ w[48];
    assign w[50] = w[42] ^ w[49];
    assign w[51] = w[43] ^ w[50];
    assign w[52] = w[44] ^ sub_out[11];
    assign w[53] = w[45] ^ w[52];
    assign w[54] = w[46] ^ w[53];
    assign w[55] = w[47] ^ w[54];

    // i = 56..59
    assign w[56] = w[48] ^ sub_out[12] ^ 32'h40000000;
    assign w[57] = w[49] ^ w[56];
    assign w[58] = w[50] ^ w[57];
    assign w[59] = w[51] ^ w[58];

    // Pack all 15 round keys
    assign roundKeys = {
        w[0],  w[1],  w[2],  w[3],    // K0
        w[4],  w[5],  w[6],  w[7],    // K1
        w[8],  w[9],  w[10], w[11],   // K2
        w[12], w[13], w[14], w[15],   // K3
        w[16], w[17], w[18], w[19],   // K4
        w[20], w[21], w[22], w[23],   // K5
        w[24], w[25], w[26], w[27],   // K6
        w[28], w[29], w[30], w[31],   // K7
        w[32], w[33], w[34], w[35],   // K8
        w[36], w[37], w[38], w[39],   // K9
        w[40], w[41], w[42], w[43],   // K10
        w[44], w[45], w[46], w[47],   // K11
        w[48], w[49], w[50], w[51],   // K12
        w[52], w[53], w[54], w[55],   // K13
        w[56], w[57], w[58], w[59]    // K14
    };

endmodule
