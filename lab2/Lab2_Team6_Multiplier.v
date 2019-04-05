`timescale 1ns/1ps

module Multiplier (a, b, p);
input [4-1:0] a, b;
output [8-1:0] p;
wire [3-1:0] x, carry;
wire [3-1:0] sum1, sum2;
wire [4-1:0] y, z, w;

and A0B0 (p[0], a[0], b[0]);
and A1B0 (x[0], a[1], b[0]);
and A2B0 (x[1], a[2], b[0]);
and A3B0 (x[2], a[3], b[0]);

and A0B1 (y[0], a[0], b[1]);
and A1B1 (y[1], a[1], b[1]);
and A2B1 (y[2], a[2], b[1]);
and A3B1 (y[3], a[3], b[1]);

and A0B2 (z[0], a[0], b[2]);
and A1B2 (z[1], a[1], b[2]);
and A2B2 (z[2], a[2], b[2]);
and A3B2 (z[3], a[3], b[2]);

and A0B3 (w[0], a[0], b[3]);
and A1B3 (w[1], a[1], b[3]);
and A2B3 (w[2], a[2], b[3]);
and A3B3 (w[3], a[3], b[3]);

Adder_4bit adder1 (
    .a ({1'b0, x[2:0]}), 
    .b (y), 
    .cout (carry[0]), 
    .sum ({sum1, p[1]})
);

Adder_4bit adder2 (
    .a ({carry[0], sum1}), 
    .b (z),  
    .cout (carry[1]), 
    .sum ({sum2, p[2]})
);

Adder_4bit adder3 (
    .a ({carry[1], sum2}), 
    .b (w),  
    .cout (p[7]), 
    .sum (p[6:3])
);

endmodule

module Adder_4bit (a, b, cout, sum);
input [4-1:0] a, b;
output cout;
output [4-1:0] sum;
wire c1, c2, c3;
wire [4-1:0] g, p, w;

Full_Adder fa0 (
    .a (a[0]),
    .b (b[0]),
    .cin (1'b0),
    .cout (p[0]),
    .sum (sum[0])
);
and G0 (g[0], a[0], b[0]);
and W0 (w[0], p[0], 1'b0);
or C1 (c1, g[0], w[0]);

Full_Adder fa1 (
    .a (a[1]),
    .b (b[1]),
    .cin (c1),
    .cout (p[1]),
    .sum (sum[1])
);
and G1 (g[1], a[1], b[1]);
and W1 (w[1], p[1], c1);
or C2 (c2, g[1], w[1]);

Full_Adder fa2 (
    .a (a[2]),
    .b (b[2]),
    .cin (c2),
    .cout (p[2]),
    .sum (sum[2])
);
and G2 (g[2], a[2], b[2]);
and W2 (w[2], p[2], c2);
or C3 (c3, g[2], w[2]);

Full_Adder fa3 (
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


module Full_Adder (a, b, cin, cout, sum);
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

