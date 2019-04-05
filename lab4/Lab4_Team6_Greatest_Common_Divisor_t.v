`timescale 1ns/1ps

module Greatest_Common_Divisor_t;
reg clk   = 1'b1;
reg rst_n = 1'b0;
reg start = 1'b0;
reg [8-1:0] a, b;
wire done;
wire [8-1:0] gcd;

Greatest_Common_Divisor gcdvr(
    .clk   (clk  ),
    .rst_n (rst_n), 
    .start (start),
    .a     (a    ),
    .b     (b    ),
    .done  (done ),
    .gcd   (gcd  )
);

parameter cyc = 4;

always #(cyc/2) clk = ~clk;

initial begin
	$fsdbDumpfile("greatest_common_divisor.fsdb");
	$fsdbDumpvars;
end

task do_test;
	input [8-1:0] ia, ib;
	begin
		a = ia;
		b = ib;
		start = 1'b1;
		#(cyc) start = 1'b0;
		#(cyc*10);
	end
endtask


initial begin
    a = 8'd12;
    b = 8'd15;
	@(negedge clk) rst_n = 1'b1;
    #(cyc*3 ) start = 1'b1;
	#(cyc   ) start = 1'b0;
    #(cyc   ) rst_n = 1'b0;
	#(cyc*5 ) rst_n = 1'b1;

	do_test(8'd12, 8'd15);
	
	do_test(8'd0, 8'd0);

	do_test(8'd1, 8'd8);
	
	$finish;
end

endmodule
