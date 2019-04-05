module filter (
  input wire clk,
  input wire rst_n,
  input wire fc_valid,
  input wire [7:0] working_pixel,
  input signed [7:0] fc,
  input wire start,
  output reg [7:0] out_pixel,
  output reg out_valid,
  output reg [15:0] addr,
  output wire wen,
  output wire [7:0] d
);

parameter IDLE    = 3'b000;
parameter LOADFC  = 3'b001;
parameter SETADDR = 3'b010;
parameter CONVOL  = 3'b100;
parameter SETCNTR = 3'b101;
parameter OUTPUT  = 3'b110;

reg [2:0] state, next_state;
reg [2:0] m, next_m;
reg [2:0] n, next_n;
reg signed [3:0] x, next_x;
reg signed [3:0] y, next_y;
reg signed [16:0] i, next_i;
reg signed [16:0] j, next_j;
reg signed [16:0] conv, next_conv;
reg signed [16:0] filter[4:0][4:0];
reg signed [16:0] bm_x, bm_y;
reg addr_valid, conv_done, all_done;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    state <= IDLE;
  end else begin
    state <= next_state;
    m <= next_m;
    n <= next_n;
    x <= next_x;
    y <= next_y;
    i <= next_i;
    j <= next_j;
    conv <= next_conv;
  end
end

always @(*) begin
  case (state)
    IDLE : begin
      if(start) begin
        next_state = LOADFC;
      end else begin
        next_state = IDLE;
      end
    end
    LOADFC : begin
      if(fc_valid) begin
        next_state = LOADFC;
      end else begin
        next_state = SETADDR;
      end
    end
    SETADDR : begin
      next_state = CONVOL;
    end
    CONVOL : begin
      if(conv_done) begin
        next_state = OUTPUT;
      end else begin
        next_state = SETCNTR;
      end
    end
    SETCNTR : begin
      next_state = SETADDR;
    end
    OUTPUT : begin
      if(all_done) begin
        next_state = IDLE;
      end else begin
        next_state = SETCNTR;
      end
    end
  endcase
end

always @(negedge clk) begin
  case (state)
    IDLE : begin
      out_pixel = 0;
      out_valid = 0;
      addr = 0;
      next_m = 0;
      next_n = 0;
      next_x = 0;
      next_y = 0;
      next_i = 0;
      next_j = 0;
      next_conv = 0;
      addr_valid = 0;
      conv_done = 0;
      all_done = 0;
    end
    LOADFC : begin
      if(fc_valid) begin
        filter[m][n] = fc;

      if(n < 4) begin
        next_n = n + 1;
      end else begin
        next_m = m + 1;
        next_n = 0;
      end

      out_pixel = 0;
      out_valid = 0;
      addr = 0;
      next_x = 0;
      next_y = 0;
      next_i = 0;
      next_j = 0;
      next_conv = 0;
      addr_valid = 0;
      conv_done = 0;
      all_done = 0;
      end
    end
    SETADDR : begin
      bm_x = x + i - 2;
      bm_y = y + j - 2;
      if(0 <= bm_x && bm_x <= 255 && 0 <= bm_y && bm_y <= 255) begin
        addr = 256 * bm_x + bm_y;
        addr_valid = 1;
      end else begin
        addr = 0;
        addr_valid = 0;
      end

      out_pixel = 0;
      out_valid = 0;
      next_m = 0;
      next_n = 0;
    end
    CONVOL : begin
      if(addr_valid) begin
        next_conv = conv + filter[x][y] * working_pixel;
      end else begin
        next_conv = conv;
      end

      out_pixel = 0;
      out_valid = 0;
      next_m = 0;
      next_n = 0;
    end
    SETCNTR : begin
      if(conv_done) begin
        if(j < 255) begin
          next_j = j + 1;
        end else begin
          next_j = 0;
          next_i = i + 1;
        end

        next_x = 0;
        next_y = 0;
        next_conv = 0;
      end else begin
        if(y < 4) begin
          next_y = y + 1;
        end else begin
          next_y = 0;
          next_x = x + 1;
        end
      end

      if(next_x == 4 && next_y == 4) begin
          conv_done = 1;
      end else begin
          conv_done = 0;
      end

      if(conv_done && i == 255 && j == 255) begin
        all_done = 1;
      end else begin
        all_done = 0;
      end

      out_pixel = 0;
      out_valid = 0;
      addr = 0;
      next_m = 0;
      next_n = 0;
    end
    OUTPUT : begin
      if(conv > 255) begin
        out_pixel = 255;
      end
      else if(conv < 0) begin
        out_pixel = 0;
      end
      else begin
        out_pixel = conv;
      end

      out_valid = 1;
      addr = 0;
      next_m = 0;
      next_n = 0;
      next_x = 0;
      next_y = 0;
      next_conv = 0;
    end
  endcase
end

endmodule
