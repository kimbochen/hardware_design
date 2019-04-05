`timescale 1 ns/ 1 ps

module Carry_Look_Ahead_Adder_t;
reg [4-1:0] a, b;
reg cin;
wire cout;
wire [4-1:0] sum;

Carry_Look_Ahead_Adder claa (
    .a (a), 
    .b (b), 
    .cin (cin), 
    .cout (cout), 
    .sum (sum)
);

wire check;
wire [5-1:0] ans;
assign ans = a + b;
assign check = (ans == {cout, sum});

initial begin
    a = 4'b0000;
    b = 4'b0000;
    cin = 1'b0;
    
    repeat (2 ** 8) begin
        #1 {a, b} = {a, b} + 8'b0001;
    end
    
    #1 $finish;
end

endmodule
