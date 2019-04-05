`timescale 1ns/1ps

module Mealy (clk, rst_n, in, out, state);
input clk, rst_n;
input in;
output reg out;
output reg [2-1:0] state;

parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;

reg [2-1:0] next_state;

always @(posedge clk) begin
    if (!rst_n)
        state <= S0;
    else
        state <= next_state;
end

always @(*) begin
    case(state)
        S0:
            if (in == 1'b0) begin
                next_state = S0;
                out = 1'b0;
            end else begin
                next_state = S1;
                out = 1'b1;
            end
        S1:
            if (in == 1'b0) begin
                next_state = S1;
                out = 1'b1;
            end else begin
                next_state = S2;
                out = 1'b0;
            end
        S2:
            if (in == 1'b0) begin
                next_state = S0;
                out = 1'b0;
            end else begin
                next_state = S1;
                out = 1'b0;
            end
    endcase
end

endmodule
