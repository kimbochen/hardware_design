module mac(out, a, b, c);

     input [3:0] a;
     input [3:0] b;
     input [4:0] c;

     output [7:0] out;

     reg [7:0] out;

     always @* begin
         out = a * b + c;
     end

endmodule

module f_adder(a, b, out);
     input [7:0] a;
     input [7:0] b;

     output [8:0] out;
     reg [8:0] out;

     always @(*) begin
         out = a + b;
     end
endmodule

module multiplier(out, a, b);

     input [7:0] a;
     input [7:0] b;

     output[15:0] out;

     wire [7:0] rr;
     wire [7:0] lr;
     wire [7:0] rl;
     wire [8:0] sum;
     wire [7:0] ll;

     mac mac1(.out(rr), .a(a[3:0]), .b(b[3:0]), .c(0));
     mac mac2(.out(lr), .a(a[7:4]), .b(b[3:0]), .c(rr[7:4]));
     mac mac3(.out(rl), .a(a[3:0]), .b(b[7:4]), .c(0));
     f_adder add1(.out(sum), .a(rl), .b(lr));
     mac mac4(.out(ll), .a(a[7:4]), .b(b[7:4]), .c(sum[8:4]));

     assign out = {ll, sum[3:0], rr[3:0]};

endmodule
