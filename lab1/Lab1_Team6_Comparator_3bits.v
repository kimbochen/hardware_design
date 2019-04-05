`timescale 1ns/1ps

module Comparator_3bits_top (a, b, gt, eq, lt);
input [3-1:0] a, b;
output [3-1:0] gt, lt;
output [10-1:0] eq;
wire g, e, l;
wire ng, ne, nl;

Comparator_3bits cmp3bits (
    .a (a),
    .b (b),
    .a_lt_b (l),
    .a_gt_b (g),
    .a_eq_b (e)
);

not not_g (ng, g);
not out_g0 (gt[0], ng);
not out_g1 (gt[1], ng);
not out_g2 (gt[2], ng);

not not_l (nl, l);
not out_l0 (lt[0], nl);
not out_l1 (lt[1], nl);
not out_l2 (lt[2], nl);

not not_e (ne, e);
not out_e0 (eq[0], ne);
not out_e1 (eq[1], ne);
not out_e2 (eq[2], ne);
not out_e3 (eq[3], ne);
not out_e4 (eq[4], ne);
not out_e5 (eq[5], ne);
not out_e6 (eq[6], ne);
not out_e7 (eq[7], ne);
not out_e8 (eq[8], ne);
not out_e9 (eq[9], ne);

endmodule

module Comparator_3bits (a, b, a_lt_b, a_gt_b, a_eq_b);
input [3-1:0] a, b;
output a_lt_b, a_gt_b, a_eq_b;
wire [3-1:0] lt, gt, eq;
wire [2-1:0] lt_w, gt_w;

Comparator_1bit cmp0 (
    .a (a[0]),
    .b (b[0]),
    .lt (lt[0]),
    .gt (gt[0]),
    .eq (eq[0])
);

Comparator_1bit cmp1 (
    .a (a[1]),
    .b (b[1]),
    .lt (lt[1]),
    .gt (gt[1]),
    .eq (eq[1])
);

Comparator_1bit cmp2 (
    .a (a[2]),
    .b (b[2]),
    .lt (lt[2]),
    .gt (gt[2]),
    .eq (eq[2])
);

and and_lt1 (lt_w[0], eq[2], lt[1]);
and and_lt2 (lt_w[1], eq[2], eq[1], lt[0]);
or out_lt (a_lt_b, lt[2], lt_w[1], lt_w[0]);

and and_gt1 (gt_w[0], eq[2], gt[1]);
and and_gt2 (gt_w[1], eq[2], eq[1], gt[0]);
or out_gt (a_gt_b, gt[2], gt_w[1], gt_w[0]);

and out_eq (a_eq_b, eq[2], eq[1], eq[0]);

endmodule

module Comparator_1bit (a, b, lt, gt, eq);
input a, b;
output lt, gt, eq;
wire na, nb;

not not_a (na, a);
not not_b (nb, b);

and out_lt (lt, na, b);
and out_gt (gt, a, nb);
nor out_eq (eq, lt, gt);

endmodule
