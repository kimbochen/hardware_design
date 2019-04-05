`timescale 1ns/1ps

module RippleCarryAdder_t;
reg [4-1:0] a, b;
reg cin = 4'b0000;
wire [5-1:0] result;

RippleCarryAdder rca (
    .a (a), 
    .b (b), 
    .cin (cin), 
    .cout (result[4]), 
    .sum (result[3:0])
);

initial begin
    a = 4'b0000;
    b = 4'b0000;
    
    #1
    a = 4'b0001;
    b = 4'b0001;
    
    #1
    a = 4'b0010;
    b = 4'b0010;
    
    #1
    a = 4'b0100;
    b = 4'b0100;
    
    #1
    a = 4'b1000;
    b = 4'b1000;
    
    #1
    a = 4'b1111;
    b = 4'b1111;
    
    #1 $finish;
end

endmodule
