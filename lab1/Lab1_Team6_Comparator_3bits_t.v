`timescale 1ns / 1ps

module Lab1_Team6_Comparator_3bits_t;
reg [3-1:0] a = 3'b000;
reg [3-1:0] b = 3'b000;
wire a_lt_b, a_gt_b, a_eq_b;

Comparator_3bits com(
    .a(a), 
    .b(b), 
    .a_lt_b(a_lt_b), 
    .a_gt_b(a_gt_b), 
    .a_eq_b(a_eq_b)
);
initial begin
    repeat (2 ** 6) begin
        #1 {a, b} = {a, b} + 3'b001;
    end
    $finish;
end
endmodule
