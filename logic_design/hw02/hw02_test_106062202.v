1`timescale 1ns / 100ps
2 module test2;
3     reg [3:0] count;
4     wire y1, y2;
5
6     RPS m(count[0], count[1], count[2], count[3], y1, y2);
7     initial begin
8         $fsdbDumpfile("hw2.fsdb");
9         $fsdbDumpvars;
10     end
11
12     initial begin
13         count = 4'b0000;
14
15         $display  ("+-------------+");
16         $display  ("|Input |Output|");
17         $display  ("|------+------|");
18
19         repeat(16) begin
20             #100
21             $display("| %b |  %b%b  |", count, y1, y2);
22             count = count + 4'b0001;
23         end
24
25         $display  ("+-------------+");
26     end
27 endmodule
