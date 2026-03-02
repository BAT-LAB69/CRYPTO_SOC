`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// CLA64 - 64-bit Hierarchical Carry-Lookahead Adder
//
// 3-level hierarchy: CLA4 → CLA16 → CLA64
// Carry depth: O(log4(64)) = 3 levels instead of O(64) for ripple-carry
// Supports add (cin=0) and subtract (invert B externally, cin=1)
//////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// CLA4 - 4-bit Carry-Lookahead Adder Block
//==============================================================================
module CLA4 (
    input  wire [3:0] a, b,
    input  wire       cin,
    output wire [3:0] s,
    output wire       G, P    // Group generate & propagate
);

    wire [3:0] g = a & b;    // bit generate
    wire [3:0] p = a ^ b;    // bit propagate

    // Lookahead carries
    wire c1 = g[0] | (p[0] & cin);
    wire c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
    wire c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])
            | (p[2] & p[1] & p[0] & cin);

    // Sum
    assign s = p ^ {c3, c2, c1, cin};

    // Group generate & propagate for next level
    assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
             | (p[3] & p[2] & p[1] & g[0]);
    assign P = p[3] & p[2] & p[1] & p[0];

endmodule

//==============================================================================
// CLU4 - Carry Lookahead Unit for 4 groups
//==============================================================================
module CLU4 (
    input  wire [3:0] Gi, Pi,       // Group G, P from 4 blocks
    input  wire       cin,
    output wire [3:1] c_out,         // Carries into blocks 1, 2, 3
    output wire       Go, Po         // Group generate/propagate out
);

    assign c_out[1] = Gi[0] | (Pi[0] & cin);
    assign c_out[2] = Gi[1] | (Pi[1] & Gi[0]) | (Pi[1] & Pi[0] & cin);
    assign c_out[3] = Gi[2] | (Pi[2] & Gi[1]) | (Pi[2] & Pi[1] & Gi[0])
                    | (Pi[2] & Pi[1] & Pi[0] & cin);

    assign Go = Gi[3] | (Pi[3] & Gi[2]) | (Pi[3] & Pi[2] & Gi[1])
              | (Pi[3] & Pi[2] & Pi[1] & Gi[0]);
    assign Po = Pi[3] & Pi[2] & Pi[1] & Pi[0];

endmodule

//==============================================================================
// CLA16 - 16-bit CLA using 4× CLA4 + CLU4
//==============================================================================
module CLA16 (
    input  wire [15:0] a, b,
    input  wire        cin,
    output wire [15:0] s,
    output wire        G, P
);

    wire [3:0] gi, pi;
    wire [3:1] c;

    CLA4 u0 (.a(a[ 3: 0]), .b(b[ 3: 0]), .cin(cin),  .s(s[ 3: 0]), .G(gi[0]), .P(pi[0]));
    CLA4 u1 (.a(a[ 7: 4]), .b(b[ 7: 4]), .cin(c[1]), .s(s[ 7: 4]), .G(gi[1]), .P(pi[1]));
    CLA4 u2 (.a(a[11: 8]), .b(b[11: 8]), .cin(c[2]), .s(s[11: 8]), .G(gi[2]), .P(pi[2]));
    CLA4 u3 (.a(a[15:12]), .b(b[15:12]), .cin(c[3]), .s(s[15:12]), .G(gi[3]), .P(pi[3]));

    CLU4 u_clu (.Gi(gi), .Pi(pi), .cin(cin), .c_out(c), .Go(G), .Po(P));

endmodule

//==============================================================================
// CLA64 - 64-bit CLA using 4× CLA16 + CLU4
//==============================================================================
module CLA64 (
    input  wire [63:0] A, B,
    input  wire        cin,
    output wire [63:0] S,
    output wire        cout
);

    wire [3:0] gi, pi;
    wire [3:1] c;
    wire Go, Po;

    CLA16 u0 (.a(A[15: 0]), .b(B[15: 0]), .cin(cin),  .s(S[15: 0]), .G(gi[0]), .P(pi[0]));
    CLA16 u1 (.a(A[31:16]), .b(B[31:16]), .cin(c[1]), .s(S[31:16]), .G(gi[1]), .P(pi[1]));
    CLA16 u2 (.a(A[47:32]), .b(B[47:32]), .cin(c[2]), .s(S[47:32]), .G(gi[2]), .P(pi[2]));
    CLA16 u3 (.a(A[63:48]), .b(B[63:48]), .cin(c[3]), .s(S[63:48]), .G(gi[3]), .P(pi[3]));

    CLU4 u_clu (.Gi(gi), .Pi(pi), .cin(cin), .c_out(c), .Go(Go), .Po(Po));

    assign cout = Go | (Po & cin);

endmodule
