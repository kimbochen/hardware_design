`timescale 1ns / 1ps
`define CYC 4
module para_pp_t;
reg clk = 1'b1, rst_n = 1'b1;
reg enable = 1'b0, flip = 1'b0;
reg [4-1:0] max = 9, min = 0;
wire dir;
wire [4-1:0] out;

Parameterized_Ping_Pong_Counter pppc (
    .clk(clk), 
    .rst_n(rst_n), 
    .enable(enable), 
    .flip(flip), 
    .max(max), 
    .min(min), 
    .direction(dir), 
    .out(out)
);

always #(`CYC/2) clk = ~clk;

task test_enable;
begin
    enable = 1'b0;
    #`CYC enable = 1'b1;
end
endtask

task test_maxgtmin;
begin
    max = 0;
    min = 1;
    #`CYC max = 9;
          min = 0;
    #(`CYC*3) max = 3;
              min = 3;
    #(`CYC*3) max = 9;
              min = 0;
end
endtask

task test_cntinrange;
begin
    max = 1;
    #(`CYC*3) max = 9;
end
endtask

task test_flip;
begin
    flip = 1'b1;
    #`CYC flip = 1'b0;
end
endtask

initial begin
   @ (negedge clk)
       rst_n = 1'b0;
   @ (negedge clk)
       rst_n = 1'b1;
       enable = 1'b1;
    
    #(`CYC*14) test_enable;
    #`CYC test_cntinrange;
    #(`CYC*5) test_maxgtmin;
    #(`CYC*6) test_flip;
    #`CYC $finish;
end

endmodule
