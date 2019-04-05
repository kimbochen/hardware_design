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

// :: Let wen = 1 and d = 0 all the time
// :: if you do not write any data into the SRAM.
// :: Note: You may use the following code segment but it will cause
// :: a warning because there is no event to check with @*
// :: If you want to avoid the warning, replace with assign and define
// :: the output wen and d as wires.
//
// always @* begin
//   wen = 1;
//   d = 0;
// end

parameter IDLE    = 3'b000;
parameter LOADFC  = 3'b001;
parameter LOADBM  = 3'b011;
parameter CONVOL  = 3'b010;
parameter OUTPUT  = 3'b110;

integer a = 0, b = 0;
integer i = 0, j = 0;
integer x = 0, y = 0;

reg signed [15:0] array_fc[4:0][4:0];
reg [2:0] state, next_state;
reg signed [15:0] next_out_pixel = 0;
reg product_zero = 0;

wire conv_end, finish;

assign wen = 1;
assign d = 0;
assign conv_end = (x == 4 && y == 4);
assign finish = (i == 256 && j == 0);

initial begin
  @(negedge rst_n);
end

always @(negedge clk) begin
  if(~rst_n) begin
    state <= IDLE;
  end else begin
    state <= next_state;
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
        next_state = LOADBM;
      end
    end
    LOADBM : begin
      next_state = CONVOL;
    end
    CONVOL : begin
      if(conv_end) begin
        next_state = OUTPUT;
      end else begin
        next_state = LOADBM;
      end
    end
    OUTPUT : begin
      if(finish) begin
        next_state = IDLE;
      end else begin
        next_state = LOADBM;
      end
    end
  endcase
end

always @(negedge clk) begin
  case (state)
    IDLE : begin
    end
    LOADFC : begin
      if(b < 4) begin
        b = b + 1;
      end else begin
        a = a + 1;
        b = 0;
      end
    end
    LOADBM : begin

    end
    CONVOL : begin
      #1
      if(y < 4) begin
        y = y + 1;
      end else begin
        x = x + 1;
        y = 0;
      end
    end
    OUTPUT : begin
      #1
      if(j < 255) begin
        j = j + 1;
      end else begin
        i = i + 1;
        j = 0;
      end
    end
  endcase
end

always @(negedge clk) begin
  case (state)
    IDLE : begin
      out_pixel = 0;
      addr = 0;
    end
    LOADFC : begin
      array_fc[a][b] = fc;
      // $display("%d %d %d",a, b, array_fc[a][b]);
    end
    LOADBM : begin
      if(0 <= (x + i - 2) && (x + i - 2) <= 255 && 
         0 <= (y + j - 2) && (y + j - 2) <= 255) begin
        addr = 256 * (x + i - 2) + (y + j - 2);
        product_zero = 0;
      end
      else begin
        product_zero = 1;
      end
      out_valid = 0;
    end
    CONVOL : begin
      if(!product_zero) begin
        next_out_pixel = next_out_pixel + array_fc[x][y] * working_pixel;
        $display("%d %d %d %d %d %d %d",i, j, x, y, array_fc[x][y], working_pixel, next_out_pixel);
      end
    end
    OUTPUT : begin
      if(next_out_pixel > 255) begin
        next_out_pixel = 255;
      end
      else if (next_out_pixel < 0) begin
        next_out_pixel = 0;
      end
      else begin
        next_out_pixel = out_pixel;
      end
      out_pixel = next_out_pixel;
      out_valid = 1;
      next_out_pixel = 0;
      x = 0;
      y = 0;
      // $display("%d",out_pixel);
    end
  endcase
end

endmodule
