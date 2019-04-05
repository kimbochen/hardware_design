`timescale 1ns/1ps

module RippleCarryAdder (a, b, cin, cout, sum);
input [4-1:0] a, b;
input cin;
output [4-1:0] sum;
output cout;
wire [3-1:0] carry;

FullAdder fa1 (
    .a (a[0]), 
    .b (b[0]), 
    .cin (cin), 
    .cout (carry[0]), 
    .sum (sum[0])
);

FullAdder fa2 (
    .a (a[1]), 
    .b (b[1]), 
    .cin (carry[0]), 
    .cout (carry[1]), 
    .sum (sum[1])
);

FullAdder fa3 (
    .a (a[2]), 
    .b (b[2]), 
    .cin (carry[1]), 
    .cout (carry[2]), 
    .sum (sum[2])
);

FullAdder fa4 (
    .a (a[3]), 
    .b (b[3]), 
    .cin (carry[2]), 
    .cout (cout), 
    .sum (sum[3])
);

endmodule

module FullAdder (a, b, cin, cout, sum);
input a, b, cin;
output sum, cout;
wire w, w1, w2, w3;

MyXor xor1 (a, b, w);
MyXor xor2 (w, cin, sum);

and and1 (w1, a, b);
and and2 (w2, a, cin);
and and3 (w3, b, cin);
or ans (cout, w1, w2, w3);

endmodule

module MyXor (a, b, out);
input a, b;
output out;
wire na, nb;
wire w1, w2;

not not1 (na, a);
not not2 (nb, b);

and and1 (w1, na, b);
and and2 (w2, a, nb);
or ans (out, w1, w2);

endmodule
