`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
input clk, rst_n;
input in;
output dec;

parameter S0 = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter W1 = 3'd4;
parameter W2 = 3'd5;
parameter W3 = 3'd6;

reg [3-1:0] state, next_state;
reg dout;

always @(posedge clk) begin
	if (!rst_n)
		state <= S0;
	else
		state <= next_state;
end

always @(*) begin
	case (state)
		S0	   : next_state = (in == 1'b1 ? S1 : W1);
		S1	   : next_state = (in == 1'b0 ? S2 : W2);
		S2	   : next_state = (in == 1'b0 ? S3 : W3);
		S3	   : next_state = S0;
		W1	   : next_state = W2;
		W2	   : next_state = W3;
		W3	   : next_state = S0;
		default: next_state = S0;
	endcase
end

always @(*) begin
	case (state)
		S3	   : dout = (in == 1'b1 ? 1'b1 : 1'b0);
		default: dout = 1'b0;
	endcase
end

assign dec = dout;

endmodule
