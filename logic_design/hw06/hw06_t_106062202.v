// 05/2018
// CS2102 Digital Logic Design
//
// HW06: Floating-Point Multiplication (FPMUL) Engine
// File: hw06_t.v
// Description: test stimulus design
//
// Chih-Tsun Huang
// cthuang@cs.nthu.edu.tw
// National Tsing Hua University
// Hsinchu Taiwan
//
`timescale 1ns/100ps
module stimulus;
  parameter cyc = 10;
  parameter delay = 0;

  reg clk, rst_n, start;
  reg [7:0] a, b;
  wire done;
  wire [7:0] y;
  wire [4:0] e;

  FPMUL fpmul01 (
// write your code here
    .CLK(clk),
    .RST_N(rst_n),
    .A(a),
    .B(b),
    .START(start),
    .Y(y),
    .E(e),
    .DONE(done)
  );

  always #(cyc/2) clk = ~clk;

  integer check;
  always @(posedge clk) begin
    check = y * (2 ** e)/(2**7);
  end

  initial begin
    $fsdbDumpfile("fpmul.fsdb");
    $fsdbDumpvars;

    $monitor("%6d %b RST_N=%b START=%b A=%d B=%d | DONE=%b Y=%b E=%d | state=%b | [%6d] ",
      $time, clk, rst_n, start, a, b, done, y, e,
      fpmul01.state, check);
  end


  initial begin
    clk = 1;
    rst_n = 1;
    start = 0;
    #(cyc);
    #(delay)
    rst_n = 0;
    #(cyc*2) rst_n = 1;

    // test pattern
    #(cyc) load; data_in(8'd128, 8'd128);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    //
    // Write your code here:
    //   Add more test patterns
    //

    // teacher's examples
    #(cyc) load; data_in(8'd255, 8'd255);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    #(cyc) load; data_in(8'd76, 8'd95);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // testing if flag_zero works
    #(cyc) load; data_in(8'd0, 8'd0);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    #(cyc) load; data_in(8'd0, 8'd34);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // testing if every bit of Y works properly

    #(cyc) load; data_in(8'd1, 8'd101);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    #(cyc) load; data_in(8'd2, 8'd21);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    #(cyc) load; data_in(8'd17, 8'd10);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    #(cyc) load; data_in(8'd22, 8'd31);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    #(cyc) load; data_in(8'd128, 8'd255);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // testing if the E works properly
    #(cyc) load; data_in(8'd1, 8'd1);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // E = 10
    #(cyc) load; data_in(8'd13, 8'd157);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // E = 15
    #(cyc) load; data_in(8'd128, 8'd255);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // truncation: expecting Y ends with 0

    // original number ends with one 1
    #(cyc) load; data_in(8'd5, 8'd101);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // original number ends with two 1s
    #(cyc) load; data_in(8'd5, 8'd199);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // original number ends with three 1s
    #(cyc) load; data_in(8'd119, 8'd17);
    #(cyc) nop;
    @(done);
    #(cyc) nop;

    // Finish the simulation
    #(cyc) nop;
    #(cyc) nop;
    #(cyc) nop;
    #(cyc) nop;
    $finish;
  end

  // tasks
  task nop;
    begin
      start = 0;
    end
  endtask
  task load;
    begin
      start = 1;
    end
  endtask
  task data_in;
    input [7:0] data1, data2;
    begin
      a = data1;
      b = data2;
    end
  endtask

endmodule
