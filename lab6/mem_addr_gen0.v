module mem_addr_gen(
   input clk,
   input rst,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   input [5-1:0] key,
   output [16:0] pixel_addr
   );
    
   reg [7:0] position[2-1:0], next_position[2-1:0];

//horizontal flip
// wire [10-1:0] rv_h_cnt, rv_v_cnt;
// assign rv_h_cnt = 640 - h_cnt;
// assign pixel_addr = ((rv_h_cnt>>1)+320*(v_cnt>>1) + 320*position)% 76800;
   
//  assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1) + 320*position)% 76800;  //640*480 --> 320*240 
 
  //left-right move
   //assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1) -position)% 76800;  //640*480 --> 320*240 
   
  //set back to origin
   // assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1))% 76800;  //640*480 --> 320*240 

/*
   always @ (posedge clk or posedge rst) begin
      if(rst)
          position <= 239;
       else if(position >0)
           position <= position - 1;
       else
           position <= 239;
   end
  */ 
 
   // left-right move
   /*
      always @ (posedge clk or posedge rst) begin
         if(rst)
             position <= 0;
          else if(position < 321)
              position <= position + 1;
          else
              position <= 0;
      end
*/
// always @ (posedge clk or posedge rst) begin
//     if(rst)
//         position <= 0;
//     else if(position <239)
//         position <= position + 1;
//     else
//         position <= 0;
// end

parameter UP = 3'd0;
parameter DW = 3'd1;
parameter LF = 3'd2;
parameter RT = 3'd3;
parameter CT = 3'd4;

parameter ud = 1'd0;
parameter lf = 1'd1;

reg [3-1:0] dir, next_dir;
reg [10-1:0] index;

assign pixel_addr = index + 320*position[ud] + position[lf];

always @(posedge clk) begin
    if (rst)
        dir <= CT;
    else
        dir <= next_dir;
end

always @(*) begin
    

always @(*) begin
    if (key[`PAUSE]) begin
        case (key)
            5'b00001: next_dir = UP;
            5'b00010: next_dir = DW;
            5'b00100: next_dir = LF;
            5'b01000: next_dir = RT;
            default : next_dir = CT;
        endcase
    end
    else begin
        case (key)
            5'b00001: next_dir = UP;
            5'b00010: next_dir = DW;
            5'b00100: next_dir = LF;
            5'b01000: next_dir = RT;
            default : next_dir = CT;
        endcase

        case (dir)
            UP     : begin
                next_position[ud] = (position[ud] < 239) ? position[ud] + 1'b1 : 7'b0;
                next_position[lf] = position[lf];
            end
            DW     : begin
                next_position[ud] = (position[ud] > 0) ? position[ud] - 1'b1 : 7'd239;
                next_position[lf] = position[lf];
            end
            RT     : begin
                next_position[lf] = (position[lf] < 319) ? position[lf] + 1'b1 : 7'd0;
                next_position[ud] = position[ud];
            end
            LF     : begin
                next_position[lf] = (position[lf] > 0) ? position[lf] - 1'b1 : 7'd319;
                next_position[ud] = position[ud];
            end
            default: next_position = position;
        endcase 
    end
end

endmodule
