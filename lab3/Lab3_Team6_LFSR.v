`timescale 1ns/1ps

module LFSR (clk, rst_n, out);
input clk, rst_n;
output out;
reg [5-1:0] data, nxt_data;

assign out = data[0];

always @(posedge clk) begin
    if (!rst_n) begin
        data <= 5'b01001;
    end else begin
        data <= nxt_data;
    end
end

always @(*) begin
    nxt_data = {(data[3]^data[0]), data[4:1]};
end

endmodule
