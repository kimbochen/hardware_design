`timescale 1ns/1ps

module Memory (clk, ren, wen, addr, din, dout);
input clk;
input ren, wen;
input [6-1:0] addr;
input [8-1:0] din;
output [8-1:0] dout;

parameter m = 64, n = 8;
reg [n-1:0] mem[m-1:0];
reg [8-1:0] out;

assign dout = out;

always @(posedge clk) begin
    if (ren == 1'b0) begin
        out = mem[addr];
    end else begin
        if (wen == 1'b0) begin
            out = 8'd0;
            mem[addr] = din;
        end 
        else begin
            out = 8'd0;
        end
    end
end

endmodule
