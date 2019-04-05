`timescale 1 ns / 1 ps

module Multiplier_t;
reg [4-1:0] a, b;
wire [8-1:0] p, ans;
wire check;

Multiplier mlt (
    .a (a), 
    .b (b), 
    .p (p)
);

assign ans  = a * b;
assign check = (p === ans);

initial begin
    a = 4'b0000;
    b = 4'b0000;
    
    repeat (2 ** 8) begin
        #1 {a, b} = {a, b} + 4'b0001;
    end

    #1 $finish;
end

endmodule
