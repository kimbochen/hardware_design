`timescale 1ns/1ps

module Mux_8bits (a, b, sel, f);
input [8-1:0] a, b;
input sel;
output [8-1:0] f;

Mux_1bit mux0 (a[0], b[0], sel, f[0]);
Mux_1bit mux1 (a[1], b[1], sel, f[1]);
Mux_1bit mux2 (a[2], b[2], sel, f[2]);
Mux_1bit mux3 (a[3], b[3], sel, f[3]);
Mux_1bit mux4 (a[4], b[4], sel, f[4]);
Mux_1bit mux5 (a[5], b[5], sel, f[5]);
Mux_1bit mux6 (a[6], b[6], sel, f[6]);
Mux_1bit mux7 (a[7], b[7], sel, f[7]);

endmodule

module Mux_1bit (a, b, sel, f);
input a, b;
input sel;
output f;
wire nsel, w1, w2;

not not1 (nsel, sel);
and and1 (w1, sel, a);
and and2 (w2, nsel, b);
or ans (f, w1, w2);

endmodule
