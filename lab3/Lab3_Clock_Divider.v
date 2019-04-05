`timescale 1ns/1ps

module Clock_Divider (clk, rst_n, sel, clk1_2, clk1_4, clk1_8, clk1_3, dclk);
input clk, rst_n;
input [2-1:0] sel;
output clk1_2;
output clk1_4;
output clk1_8;
output clk1_3;
output dclk;
reg o_clk2, o_clk4, o_clk8, o_clk3;
reg cnt2;
reg [2-1:0] cnt4, cnt3;
reg [4-1:0] cnt8;

assign clk1_2 = o_clk2;
always @(posedge clk) begin
    if (!rst_n)
        o_clk2 <= 0;
    else
        o_clk2 <= ~o_clk2;  
end

assign clk1_4 = o_clk4;
always @(posedge clk) begin
    if (!rst_n)
        cnt4 <= 0;
    else if (cnt4 == 3)
        cnt4 <= 0;
    else
        cnt4 <= cnt4 + 1;
end
always @(posedge clk) begin
    if (!rst_n)
        o_clk4 <= 0;
    else if (cnt4 < 2)
        o_clk4 <= 1;
    else
        o_clk4 <= 0;
end

assign clk1_3 = o_clk3;
always @(posedge clk) begin
    if (!rst_n)
        cnt3 <= 0;
    else if (cnt3 == 2)
        cnt3 <= 0;
    else
        cnt3 <= cnt3 + 1;
end
always @(posedge clk) begin
    if (!rst_n)
        o_clk3 <= 0;
    else if (cnt3 < 2)
        o_clk3 <= 1;
    else
        o_clk3 <= 0;
end

assign clk1_8 = o_clk8;
always @(posedge clk) begin
    if (!rst_n)
        cnt8 <= 0;
    else if (cnt8 == 7)
        cnt8 <= 0;
    else
        cnt8 <= cnt8 + 1;
end
always @(posedge clk) begin
    if (!rst_n)
        o_clk8 <= 0;
    else if (cnt8 < 4)
        o_clk8 <= 1;
    else
        o_clk8 <= 0;
end

MUX4to1 mux(
    .q(dclk), 
    .sel(sel), 
    .a(clk1_2), 
    .b(clk1_4), 
    .c(clk1_8), 
    .d(clk1_3)
);

endmodule

module MUX4to1 (q, sel, a, b, c, d);
input [2-1:0] sel;
input a, b, c, d;
output q;
wire [4-1:0] w;

and and0(w[0], ~sel[0], ~sel[1], a);
and and1(w[1], sel[0], ~sel[1], b);
and and2(w[2], ~sel[0], sel[1], c);
and and3(w[3], sel[0], sel[1], d);
or out(q, w[0], w[1], w[2], w[3]);

endmodule