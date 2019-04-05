`timescale 1ns/1ps

module Mealy_Sequence_Detector_t;
reg  clk   = 1'b1;
reg  rst_n = 1'b0;
reg  in    = 1'b0;
wire o_dec;

reg  [3-1:0] i;
reg  [4-1:0] seq;
wire check = (o_dec == 1'b1 || seq == 4'b1001);

parameter cyc = 4;

Mealy_Sequence_Detector msd(
    .clk  (clk  ),
    .rst_n(rst_n),
    .in   (in   ),
    .dec  (o_dec)
);

always #(cyc/2) clk = ~clk;

initial begin
	$fsdbDumpfile("mealy_sequence_detecter.fsdb");
	$fsdbDumpvars;
end

always #(cyc) if (check) $display("seq = %b, in = %b, o_dec = %b", seq, in, o_dec);

initial begin
	@(negedge clk) rst_n = 1'b1;

	seq = 4'b0;

	repeat(2**4) begin
		i = 2'b0;

		repeat(4) begin
			in = seq[i];
			#(cyc) i = i + 1'b1;
		end

		seq = seq + 1'b1;
	end
/*
	seq = 4'b1001;
	#(cyc/2) in = 1'b1;
    #( cyc ) in = 1'b0;
    #( cyc ) in = 1'b0;	
    #( cyc ) in = 1'b1;
*/
	$finish;
end

endmodule
