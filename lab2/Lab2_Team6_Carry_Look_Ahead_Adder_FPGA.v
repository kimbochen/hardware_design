`timescale 1ns / 1ps

module Carry_Look_Ahead_Adder_FPGA (SW, AN, seg, dp);
input [9-1:0] SW;
output [4-1:0] AN;
output [7-1:0] seg;
output dp;
wire [16-1:0] term;
wire [4-1:0] sum, nsum;
wire cout;

Carry_Look_Ahead_Adder claa (
    .a (SW[8:5]), 
    .b (SW[4:1]), 
    .cin (SW[0]), 
    .cout (cout), 
    .sum (sum)
);

not inv0 (nsum[0], sum[0]);
not inv1 (nsum[1], sum[1]);
not inv2 (nsum[2], sum[2]);
not inv3 (nsum[3], sum[3]);

and an0 (AN[0], sum[0], nsum[0]);
or an1 (AN[1], sum[0], nsum[0]);
or an2 (AN[2], sum[0], nsum[0]);
or an3 (AN[3], sum[0], nsum[0]);

and term0 (term[0], nsum[3], nsum[2], nsum[1], nsum[0]);
and term1 (term[1], nsum[3], nsum[2], nsum[1], sum[0]);
and term2 (term[2], nsum[3], nsum[2], sum[1], nsum[0]);
and term3 (term[3], nsum[3], nsum[2], sum[1], sum[0]);
and term4 (term[4], nsum[3], sum[2], nsum[1], nsum[0]);
and term5 (term[5], nsum[3], sum[2], nsum[1], sum[0]);
and term6 (term[6], nsum[3], sum[2], sum[1], nsum[0]);
and term7 (term[7], nsum[3], sum[2], sum[1], sum[0]);
and term8 (term[8], sum[3], nsum[2], nsum[1], nsum[0]);
and term9 (term[9], sum[3], nsum[2], nsum[1], sum[0]);
and term10 (term[10], sum[3], nsum[2], sum[1], nsum[0]);
and term11 (term[11], sum[3], nsum[2], sum[1], sum[0]);
and term12 (term[12], sum[3], sum[2], nsum[1], nsum[0]);
and term13 (term[13], sum[3], sum[2], nsum[1], sum[0]);
and term14 (term[14], sum[3], sum[2], sum[1], nsum[0]);
and term15 (term[15], sum[3], sum[2], sum[1], sum[0]);

or CA (seg[0], term[1], term[4], term[11], term[13]);
or CB (seg[1], term[5], term[6], term[11], term[12], term[14], term[15]);
or CC (seg[2], term[2], term[12], term[14], term[15]);
or CD (seg[3], term[1], term[4], term[7], term[10], term[15]);
or CE (seg[4], term[1], term[3], term[4], term[5], term[7], term[9]);
or CF (seg[5], term[1], term[2], term[3], term[7], term[13]);
or CG (seg[6], term[0], term[1], term[7], term[12]);
not DP (dp, cout);

endmodule

module Carry_Look_Ahead_Adder (a, b, cin, cout, sum);
input [4-1:0] a, b;
input cin;
output cout;
output [4-1:0] sum;
wire c1, c2, c3;
wire [4-1:0] g, p, w;

FullAdder fa0 (
    .a (a[0]), 
    .b (b[0]), 
    .cin (cin), 
    .cout (p[0]), 
    .sum (sum[0])
);
and G0 (g[0], a[0], b[0]);
and W0 (w[0], p[0], cin);
or C1 (c1, g[0], w[0]);

FullAdder fa1 (
    .a (a[1]), 
    .b (b[1]), 
    .cin (c1), 
    .cout (p[1]), 
    .sum (sum[1])
);
and G1 (g[1], a[1], b[1]);
and W1 (w[1], p[1], c1);
or C2 (c2, g[1], w[1]);

FullAdder fa2 (
    .a (a[2]), 
    .b (b[2]), 
    .cin (c2), 
    .cout (p[2]), 
    .sum (sum[2])
);
and G2 (g[2], a[2], b[2]);
and W2 (w[2], p[2], c2);
or C3 (c3, g[2], w[2]);

FullAdder fa3 (
    .a (a[3]), 
    .b (b[3]), 
    .cin (c3), 
    .cout (p[3]), 
    .sum (sum[3])
);
and G3 (g[3], a[3], b[3]);
and W3 (w[3], p[3], c3);
or C4 (cout, g[3], w[3]);

endmodule

module FullAdder (a, b, cin, cout, sum);
input a, b, cin;
output sum, cout;
wire w, w1, w2, w3;

xor xor1 (w, a, b);
xor xor2 (sum, w, cin);

and and1 (w1, a, b);
and and2 (w2, a, cin);
and and3 (w3, b, cin);
or ans (cout, w1, w2, w3);

endmodule
