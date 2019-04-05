`timescale 1ns/1ps 

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output direction;
output [4-1:0] out;

reg [4-1:0] cnt, nx_cnt;
reg dir, nx_dir;
wire bnd = ((cnt == max) && !dir) || ((cnt == min) && dir);
wire valid = (min <= cnt && cnt <= max && min < max);

assign out = cnt;
assign direction = dir;

always @(posedge clk) begin
    if (!rst_n) begin
        cnt <= min;
        dir <= 0;
    end else begin
        cnt <= nx_cnt;
        dir <= nx_dir;
    end
end

always @(*) begin
    if (flip || bnd) begin
        nx_dir = ~dir;
    end else begin
        nx_dir = dir;
    end
end

always @(*) begin
    if (!enable || !valid) begin
        nx_cnt = cnt;
    end else begin
        nx_cnt = cnt + 1 - 2*(flip^bnd^dir);
    end
end

endmodule
