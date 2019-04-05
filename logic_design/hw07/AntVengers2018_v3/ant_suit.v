module Antman (
  input wire clk,
  input wire rst_n,
  input wire ant_r,
  input wire ant_l,
  input wire hit,
  input wire escape,
// challenge mode
`ifdef CHALLENGE
  output reg [`PH_WIDTH - 1:0] ph_drop,
  input wire [`PH_WIDTH - 1:0] ph_detected,
`endif
  output reg [1:0] move
);

  // parameters: action
  parameter [1:0] halt       = `HALT;
  parameter [1:0] turn_right = `RIGHT;
  parameter [1:0] turn_left  = `LEFT;
  parameter [1:0] forward    = `FORWARD;
  parameter cyc = `CYC;
  parameter delay = `DELAY;

  initial begin
    #cyc;
    #cyc;
    @(posedge rst_n);   // move after reset

    standing_still;
    standing_still;
    moving_forward;
    turning_right;
    turning_left;
    turning_right;
    turning_right;
    moving_forward;
    moving_forward;
    turning_right;
    moving_forward;
    moving_forward;
    turning_left;
    moving_forward;
    moving_forward;
    turning_left;
    moving_forward;
    moving_forward;
    turning_right;
    moving_forward;
    moving_forward;
    turning_right;
    moving_forward;
    turning_left;
    moving_forward;
    moving_forward;
    moving_forward;
  end

// challenge mode: deploy pheromone immediate after
// no pheromone being detected
`ifdef CHALLENGE
  always @* begin
    if (ph_detected == 0) ph_drop = 2'b1;
    else ph_drop = 0;
  end
`endif

  task moving_forward;
    begin
      @(posedge clk) move = forward;
    end
  endtask

  task turning_left;
    begin
      @(posedge clk) move = turn_left;
    end
  endtask

  task turning_right;
    begin
      @(posedge clk) move = turn_right;
    end
  endtask

  task standing_still;
    begin
      @(posedge clk) move = halt;
    end
  endtask

endmodule
