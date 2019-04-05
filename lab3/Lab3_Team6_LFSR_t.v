`timescale 1ns/1ps
`define cyc 4

module LFSR_t;
reg clk = 1'b0;
reg rst_n = 1'b0;
wire out;
integer i;

LFSR lfsr(
    .clk(clk), 
    .rst_n(rst_n), 
    .out(out)
);

always #(`cyc/2) clk = ~clk;

task do_reset;
    begin
        rst_n = 1'b0;
        #(`cyc) rst_n = 1'b1;
    end
endtask

initial begin
    @(negedge clk) rst_n = 1'b0;
    @(posedge clk) rst_n = 1'b1;
    
    for (i = 1; i < 9; i = i + 1) begin
        #(`cyc*i) do_reset;
    end
    
    #`cyc $finish;
end

endmodule
