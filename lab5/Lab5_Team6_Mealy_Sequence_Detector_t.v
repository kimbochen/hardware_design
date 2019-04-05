`timescale 1ns/1ps

module Mealy_Sequence_Detector_t ();
reg  clk;
reg  rst_n;
reg  in   ;
wire o_dec;

reg  [4-1:0] seq;
wire check = (o_dec || seq == 4'b1100 || seq == 4'b0011);

parameter cyc = 4;
integer i, j;

Mealy_Sequence_Detector msd(
    .clk  (clk  ),
    .rst_n(rst_n),
    .in   (in   ),
    .dec  (o_dec)
);

task Reset;
	begin
		rst_n = 1'b0;
		#(cyc);
		rst_n = 1'b1;
	end
endtask

always #(cyc/2) clk = ~clk;

initial begin
	$fsdbDumpfile("mealy_sequence_detecter.fsdb");
	$fsdbDumpvars;
end

initial begin
	clk = 1'b0;
	seq = 4'b0;
	in  = 1'b0;
end

initial begin
	Reset;
	for (i=0; i<16; i=i+1) begin
		for (j=0; j<4; j=j+1) begin
			in = seq[3'd3-j];
			#(cyc);
		end
		
		seq = seq + 1'b1;
	end
	
	$finish;
end

endmodule
