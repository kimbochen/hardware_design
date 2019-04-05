`timescale 1ns/100ps
module FPMUL (
  input wire CLK,
  input wire RST_N,
  input wire [7:0] A,
  input wire [7:0] B,
  input wire START,
  output reg [7:0] Y,
  output reg signed [4:0] E,
  output reg DONE
);

parameter IDLE = 2'b00;
parameter MULT = 2'b01;
parameter SHIFT = 2'b10;
parameter FINISH = 2'b11;

reg [15:0] product, next_product;
reg [3:0] state, next_state;
reg [7:0] next_Y;
reg [4:0] next_E;
reg next_DONE;

wire flag_zero, flag_leadz;
assign flag_zero = (A == 0 || B == 0)? 1 : 0;
assign flag_leadz = (next_product[15] == 0)? 1 : 0;

always @(posedge CLK, negedge RST_N) begin
	if (RST_N == 0) begin
		state = IDLE;
    end else begin
		state = next_state;
        product = next_product;
        Y = next_Y;
        E = next_E;
        DONE = next_DONE;
    end
end

always @(*) begin
  case(state)
  	IDLE: begin
		if (START && flag_zero) begin
			next_state = FINISH;
        end
		else if (START && !flag_zero) begin
			next_state = MULT;
        end
		else begin
			next_state = IDLE;
        end
	end
	MULT: begin
		if (!flag_leadz) begin
			next_state = FINISH;
        end else begin
			next_state = SHIFT;
        end
	end
	SHIFT: begin
		if (flag_leadz) begin
			next_state = SHIFT;
        end else begin
			next_state = FINISH;
        end
	end
	FINISH: begin
		next_state = IDLE;
	end
	endcase
end

always @(*) begin
  case(state)
	IDLE: begin
		next_Y = 0;
		next_E = 0;
        next_product = 0;
		next_DONE = 0;
	end
	MULT: begin
        next_Y = 0;
        next_E = 15;
		next_product = A * B;
		next_DONE = 0;
	end
	SHIFT: begin
        next_Y = 0;
		if (flag_leadz) begin
            next_E = E - 1;
            next_product = product << 1;
        end
		next_DONE = 0;
	end
	FINISH: begin
		if (flag_zero == 1) begin
            next_Y = 0;
			next_E = 0;
		end else begin
            next_Y = product[15:8];
		end
		next_DONE = 1;
	end	
	endcase
end

endmodule

