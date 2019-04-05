`timescale 1ns/1ps

module Ping_Pong_Counter (clk, rst_n, enable, direction, out);
input clk, rst_n;
input enable;
output direction;
output [4-1:0] out;
reg [4-1:0] cnt, nx_cnt;
reg dir, nx_dir;


assign out = cnt;
assign direction = dir;

always @(posedge clk) begin
    if (!rst_n) begin
        cnt <= 0;
        dir <= 1'b0;
    end else begin
        cnt <= nx_cnt;
        dir <= nx_dir;
    end
end

always @(*) begin
    if (enable)
        nx_cnt = cnt + 1 - nx_dir * 2;
    else
        nx_cnt = cnt;    
end    

always @(*) begin
    if (cnt == 15)
        nx_dir = 1;
    else if (cnt == 0)
        nx_dir = 0;
    else
        nx_dir = dir;
end

endmodule
