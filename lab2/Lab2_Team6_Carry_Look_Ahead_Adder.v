`timescale 1ns/1ps

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

