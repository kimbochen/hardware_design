`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
input clk, rst_n;
input in;
output dec;

parameter S0  = 4'd0;
parameter SA1 = 4'd1;
parameter SA2 = 4'd2;
parameter SA3 = 4'd3;
parameter SB1 = 4'd4;
parameter SB2 = 4'd5;
parameter SB3 = 4'd6;
parameter W2  = 4'd7;
parameter W3  = 4'd8;

reg [4-1:0] state, next_state;
reg dout;

always @(posedge clk) begin
	if (!rst_n)
		state <= S0;
	else
		state <= next_state;
end

always @(*) begin
	case (state)
		S0     : next_state = (in == 1'b1 ? SA1 : SB1);
		SA1    : next_state = (in == 1'b1 ? SA2 : W2);
		SA2    : next_state = (in == 1'b0 ? SA3 : W3);
		SA3    : next_state = S0;
		SB1    : next_state = (in == 1'b0 ? SB2 : W2);
		SB2    : next_state = (in == 1'b1 ? SB3 : W3);
		W2     : next_state = W3;
		W3     : next_state = S0; 
		default: next_state = S0;
	endcase
end

always @(*) begin
	case (state)
		SA3    : dout = (in == 1'b0 ? 1'b1 : 1'b0);
		SB3    : dout = (in == 1'b1 ? 1'b1 : 1'b0);
		default: dout = 1'b0;
	endcase
end

assign dec = dout;

endmodule
