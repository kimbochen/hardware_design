`timescale 1ns/1ps

module Flip_Flop (clk, d, q);
input clk;
input d;
output q;
wire nclk, w;

not not_clk (nclk, clk);

Latch Master (
  .clk (nclk),
  .d (d),
  .q (w)
);

Latch Slave (
  .clk (clk),
  .d (w),
  .q (q)
);

endmodule

module Latch (clk, d, q);
input clk;
input d;
output q;
wire nd, a, b, c;

not not_d (nd, d);

nand nand_a (a, d, clk);
nand nand_b (b, nd, clk);
nand nand_c (q, a, c);
nand nand_e (c, b, q);

endmodule
