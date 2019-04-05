module Antman (
  input wire clk,
  input wire rst_n,
  input wire ant_r,
  input wire ant_l,
  input wire hit,
  input wire escape,
  output reg [1:0] move
);

  // parameters: action
  parameter [1:0] halt       = `HALT;
  parameter [1:0] turn_right = `RIGHT;
  parameter [1:0] turn_left  = `LEFT;
  parameter [1:0] forward    = `FORWARD;
  parameter cyc = `CYC;
  parameter delay = `DELAY;
  parameter [1:0] wall_left = 2'b10;
  parameter [1:0] wall_right = 2'b01;
  parameter [1:0] wall_ahead = 2'b11;
  parameter [1:0] wall_space = 2'b00;

  reg [1:0] prev_move;
  reg [1:0] prev_wall;
  wire [1:0] now_wall;

  assign now_wall = {ant_l, ant_r};

  always @(posedge clk or negedge rst_n) begin
    if (rst_n == 0) begin
      prev_move <= halt;
    end else begin
      prev_move <= move;
      prev_wall <= now_wall;
    end
  end

  always @(*) begin
    case (prev_move)
      halt: begin
        if (escape == 1) begin
          move = halt;
        end else begin
          if (now_wall == wall_left) begin
            move = forward;
          end
          else if (now_wall == wall_right) begin
            move = turn_right;
          end
          else if (now_wall == wall_ahead) begin
            move = turn_right;
          end
          else begin
            move = forward;
          end
        end
      end
      forward: begin
        if (prev_wall == wall_left && now_wall == wall_left) begin
          move = forward;
        end
        else if (prev_wall == wall_left && now_wall == wall_ahead) begin
          move = turn_right;
        end
        else if (prev_wall == wall_left && now_wall == wall_space) begin
          move = turn_left;
        end
        else if (prev_wall == wall_right && now_wall == wall_right) begin
          move = forward;
        end
        else if (prev_wall == wall_right && now_wall == wall_space) begin
          move = turn_right;
        end
        else if (prev_wall == wall_space && now_wall == wall_left) begin
          move = forward;
        end
        else if (prev_wall == wall_space && now_wall == wall_right) begin
          move = turn_right;
        end
        else if (prev_wall == wall_space && now_wall == wall_ahead) begin
          move = turn_right;
        end
        else if (prev_wall == wall_space && now_wall == wall_space) begin
          move = forward;
        end
        else begin
          move = halt;
        end
      end
      turn_left: begin
        if (prev_wall == wall_left && now_wall == wall_ahead) begin
          move = turn_right;
        end
        else if (prev_wall == wall_right && now_wall == wall_left) begin
          move = forward;
        end
        else if (prev_wall == wall_right && now_wall == wall_space) begin
          move = turn_left;
        end
        else if (prev_wall == wall_ahead && now_wall == wall_left) begin
          move = turn_right;
        end
        else if (prev_wall == wall_ahead && now_wall == wall_right) begin
          move = turn_right;
        end
        else if (prev_wall == wall_ahead && now_wall == wall_ahead) begin
          move = turn_right;
        end
        else if (prev_wall == wall_space && now_wall == wall_left) begin
          move = forward;
        end
        else if (prev_wall == wall_space && now_wall == wall_space) begin
          move = forward;
        end
        else begin
          move = halt;
        end
      end
      turn_right: begin
        if (prev_wall == wall_left && now_wall == wall_right) begin
          move = turn_left;
        end
        else if (prev_wall == wall_left && now_wall == wall_space) begin
          move = turn_left;
        end
        else if (prev_wall == wall_right && now_wall == wall_ahead) begin
          move = turn_right;
        end
        else if (prev_wall == wall_ahead && now_wall == wall_left) begin
          move = forward;
        end
        else if (prev_wall == wall_ahead && now_wall == wall_ahead) begin
          move = turn_right;
        end
        else if (prev_wall == wall_space && now_wall == wall_right) begin
          move = turn_left;
        end
        else if (prev_wall == wall_space && now_wall == wall_space) begin
          move = forward;
        end
        else begin
          move = halt;
        end
      end
    endcase
  end
endmodule
