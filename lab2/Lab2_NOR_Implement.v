`timescale 1ns/1ps

module NOR_Implement(a, b, sel, out);
input a, b;
input [3-1:0] sel;
output out;
wire [7:0] d;

NOT g0(
    .out (d[0]), 
    .a (a)
    );

nor g1 (d[1], a, b);

AND g2(
    .out (d[2]), 
    .a (a), 
    .b (b)
    );

OR g3(
    .out (d[3]), 
    .a (a), 
    .b (b)
    );
    
XOR g4(
    .out (d[4]), 
    .a (a), 
    .b (b)
    );

XNOR g5(
    .out (d[5]), 
    .a (a), 
    .b (b)
    );

NAND g6(
    .out (d[6]), 
    .a (a), 
    .b (b)
    );

NAND g7(
    .out (d[7]), 
    .a (a), 
    .b (b)
    );
    
MUX8to1 ans(
    .out (out), 
    .d0 (d[0]), 
    .d1 (d[1]), 
    .d2 (d[2]), 
    .d3 (d[3]), 
    .d4 (d[4]), 
    .d5 (d[5]), 
    .d6 (d[6]), 
    .d7 (d[7]), 
    .sel (sel)
    );


endmodule

module NOT(out, a);
input a;
output out;

nor ans (out, a, a);

endmodule

module OR(out, a, b);
input a, b;
output out;
wire w;

nor nor1 (w, a, b);
nor nor2 (out, w, w);

endmodule

module AND(out, a, b);
input a, b;
output out;
wire wa, wb;

nor nor_a (wa, a, a);
nor nor_b (wb, b, b);
nor ans (out, wa, wb);

endmodule

module NAND(out, a, b);
input a, b;
output out;
wire wa, wb, w;

nor nor_a (wa, a, a);
nor nor_b (wb, b, b);
nor nor1 (w, wa, wb);
nor ans (out, w, w);

endmodule

module XNOR(out, a, b);
input a, b;
output out;
wire wa, wb, w1, w2;

nor nor_a (wa, a, a);
nor nor_b (wb, b, b);
nor nor1 (w1, wa, b);
nor nor2 (w2, a, wb);
nor ans (out, w1, w2);

endmodule

module XOR(out, a, b);
input a, b;
output out;
wire wa, wb, w1, w2;

nor nor_a (wa, a, a);
nor nor_b (wb, b, b);
nor nor1 (w1, a, b);
nor nor2 (w2, wa, wb);
nor ans (out, w1, w2);

endmodule

module MUX2to1(out, a, b, sel);
input a, b, sel;
output out;
wire nsel, wa, wb;

not not1 (nsel, sel);
and and_a (wa, a, nsel);
and and_b (wb, b, sel);
or ans (out, wa, wb);

endmodule

module MUX4to1(out, d0, d1, d2, d3, sela, selb);
input d0, d1, d2, d3, sela, selb;
output out;
wire w1, w2;

MUX2to1 mux1(
    .out (w1), 
    .a (d0), 
    .b (d1), 
    .sel (sela)
    );

MUX2to1 mux2(
    .out (w2), 
    .a (d2), 
    .b (d3), 
    .sel (sela)
    );
    
MUX2to1 mux3(
        .out (out), 
        .a (w1), 
        .b (w2), 
        .sel (selb)
        );

endmodule

module MUX8to1(out, d0, d1, d2, d3, d4, d5, d6, d7, sel);
input d0, d1, d2, d3, d4, d5, d6, d7;
input [3-1:0] sel;
output out;
wire w1, w2;

MUX4to1 mux1(
    .out (w1), 
    .d0 (d0), 
    .d1 (d1), 
    .d2 (d2), 
    .d3 (d3), 
    .sela (sel[0]), 
    .selb (sel[1])
    );

MUX4to1 mux2(
    .out (w2), 
    .d0 (d4), 
    .d1 (d5), 
    .d2 (d6), 
    .d3 (d7), 
    .sela (sel[0]), 
    .selb (sel[1])
    );

MUX2to1 mux3(
    .out (out), 
    .a (w1), 
    .b (w2), 
    .sel (sel[2])
    );

endmodule
