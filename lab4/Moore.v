`timescale 1ns/1ps

module Moore (clk, rst_n, in, out, state);
input clk, rst_n;
input in;
output out;
output reg [2-1:0] state;

parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;
parameter S3 = 2'b11;

reg [2-1:0] next_state;

always @(posedge clk) begin
    if (!rst_n) begin
        state <= S0;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        S0:
            if (in == 1'b0)
                next_state = S0;
            else
                next_state = S1;
        S1:
            if (in == 1'b0)
                next_state = S2;
            else
                next_state = S1;
        S2:
            if (in == 1'b0)
                next_state = S0;
            else
                next_state = S3;
        default:
            if (in == 1'b0)
                next_state = S2;
            else
                next_state = S1;
    endcase
end

assign out = (state == S1 || state == S3);

endmodule
