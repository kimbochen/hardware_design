`timescale 1ns / 1ps

module testbench;
reg  up  = 1'b0;
reg  dw  = 1'b0;
reg  clk = 1'b1;
reg  [9-1:0] sw = 9'h1E1;
wire [4-1:0] an;
wire [7-1:0] seg;

parameter cyc = 4;

Parameterized_Ping_Pong_Counter_FPGA pppc_fpga(
    .UP(up),
    .DOWN(dw),
    .clk(clk),
    .SW(sw),
    .AN(an),
    .seg(seg)
);

always #(cyc/2) clk = ~clk;

initial begin
    #(2*cyc)  dw = 1'b1;
    #(4*cyc)  dw = 1'b0;
    #(20*cyc) $finish;
end

endmodule
