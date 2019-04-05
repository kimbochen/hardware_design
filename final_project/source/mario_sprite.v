`timescale 1ns / 1ps

module mario_sprite (
    input  clk, rst, 
    input  clk_25MHz,
    input clk22,
    input  btnU, btnL, btnR,
    input  [10-1:0] h_cnt,
    input  [10-1:0] v_cnt,
    input  [10-1:0] monster_x, monster_y,
    input  [10-1:0] brick_x1, brick_y1 ,
    input  [10-1:0] brick_x2, brick_y2 ,
    input  [10-1:0] brick_x3, brick_y3 ,
    input  [10-1:0] brick_x4, brick_y4 ,
    input [10-1:0] que_x , que_y,
    input fungi_eaten,
    output reg[10-1:0]mario_heigh ,mario_width,
    output mario_on, 
    output reg [10-1:0] mario_x,
    output reg [10-1:0] mario_y,
    output reg [12-1:0] pixel,
    output deadd
    );
    
wire [41:0]clktmp;
clock_divider_slow clkk(
.clk(clk),
. clknum(clktmp)
);

 
    parameter MARIO_WIDTH = 60;
    parameter MARIO_HEIGHT = 40;
    parameter  MARIO_WIDTH_LARGE = 80;
    parameter MARIO_HEIGHT_LARGE = 60;
    parameter MARIO_JUMP_HIGH = 180;
    parameter MARIO_MOVE = 10;
     parameter MONSTER_WIDTH = 50;
     parameter MONSTER_HEIGHT = 50;
	
   parameter Start= 0;
    parameter Jump = 1;
    parameter Down = 2;
    parameter Pause = 3;
	parameter Dead = 4;
    
    reg [10-1:0] next_mario_x, next_mario_y;
    reg [10-1:0] brick_x1_long;
    reg [10-1:0] brick_x2_long;
    reg [10-1:0] brick_x3_long;
    reg [10-1:0] brick_x4_long;
    reg [10-1:0] que_x_long;
    wire [16:0] pixel_addr_s;
    wire [16:0] pixel_addr_l;
    wire [16-1:0] data;
    wire [12-1:0]pixel_s, pixel_l;
    wire mario_on_l , mario_on_s;
    reg [10-1:0]rc_x,rc_y , next_rc_x,next_rc_y;
    reg [2:0]flag_UP , next_flag_UP;
    reg in_renge_x1 , in_renge_y1;
    reg in_renge_x2 , in_renge_y2;
    reg in_renge_x3 , in_renge_y3;
    reg in_renge_x4 , in_renge_y4;
	reg in_renge_x5 , in_renge_y5;
	
    wire mario_hit_left, mario_hit_right, head_hit, jump_on_brick, out_of_brick,hit_monster,dead;
    reg dhh,next_dhh;
	
    assign  mario_on = (fungi_eaten)?mario_on_l:mario_on_s;
    
    pixel_addr_gen #(
        .WIDTH(MARIO_WIDTH),
        .HEIGHT(MARIO_HEIGHT)
    ) mario_pag (
        .h_cnt (h_cnt), 
        .v_cnt (v_cnt),
        .x (mario_x),
        .y (mario_y),
        .fungi_eaten(fungi_eaten),
        .pixel (pixel),
        .pixel_addr (pixel_addr_s),
        .pixel_on (mario_on_s)
    );
    
       pixel_addr_gen #(
         .WIDTH(MARIO_WIDTH_LARGE),
         .HEIGHT(MARIO_HEIGHT_LARGE)
     ) mario_pag_l (
         .h_cnt (h_cnt), 
         .v_cnt (v_cnt),
         .x (mario_x),
         .y (mario_y),
         .fungi_eaten(fungi_eaten),
         .pixel (pixel),
         .pixel_addr (pixel_addr_l),
         .pixel_on (mario_on_l)
     );
    
    mario_rom mario_rom_unit (
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr_s),
        .dina(data[15:0]),
        .douta(pixel_s)
    );
    
      mario_l_rom mario_rom_unitt (
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr_l),
          .dina(data[15:0]),
          .douta(pixel_l)
      );
      
 
    always @(posedge clktmp or posedge rst)
    begin
        if (rst)
        begin
            mario_x = 10'd20;
            mario_y = 10'd410;
			flag_UP <=Pause;
			rc_x <= 0;
			rc_y <= 0;
			dhh <= 0;
        end
        else
        begin
            mario_x = next_mario_x;
            mario_y = next_mario_y;
			flag_UP <= next_flag_UP;
			rc_x <= next_rc_x;
			rc_y <= next_rc_y;
			dhh <= next_dhh;
        end
    end

    always @(*)
    begin
    if(btnL == 1'b1)
        if(mario_x == 10 || mario_hit_left) // too left or hit the brick edge
            next_mario_x = mario_x;
        else
            next_mario_x =mario_x - MARIO_MOVE;
    else if (btnR == 1'b1)
        if(mario_x == 480 || mario_hit_right) // too right or hit the brick edge
            next_mario_x = mario_x;
        else 
            next_mario_x =mario_x + MARIO_MOVE;
    else 
        next_mario_x =mario_x;
    end
assign mario_hit_left = (mario_x == brick_x1+50 && in_renge_y1) || (mario_x == brick_x2+50 && in_renge_y2)||(mario_x == brick_x3+50 && in_renge_y3)||(mario_x == brick_x4+50 && in_renge_y4) || (mario_x == que_x+50 && in_renge_y5);
assign mario_hit_right = (mario_x == brick_x1 - 70 && in_renge_y1) || (mario_x == brick_x2 - 70 && in_renge_y2) || (mario_x == brick_x3 - 70 && in_renge_y3) || (mario_x == brick_x4 - 70 && in_renge_y4) || (mario_x == que_x - 70 && in_renge_y5);
always @ (*)begin
	in_renge_x1 = (mario_x < brick_x1+50 && mario_x > brick_x1_long )?1:0;
	in_renge_y1 = (mario_y < brick_y1+50 && mario_y > brick_y1-mario_heigh)?1:0;
	in_renge_x2 = (mario_x < brick_x2+50 && mario_x > brick_x2_long )?1:0;
	in_renge_y2 = (mario_y < brick_y2+50 && mario_y > brick_y2-mario_heigh)?1:0;
	in_renge_x3 = (mario_x < brick_x3+50 && mario_x > brick_x3_long )?1:0;
	in_renge_y3 = (mario_y < brick_y3+50 && mario_y > brick_y3-mario_heigh)?1:0;
	in_renge_x4 = (mario_x < brick_x4+50 && mario_x > brick_x4_long )?1:0;
	in_renge_y4 = (mario_y < brick_y4+50 && mario_y > brick_y4-mario_heigh)?1:0;
	in_renge_x5 = (mario_x < que_x+50 && mario_x > que_x_long )?1:0;
	in_renge_y5 = (mario_y < que_y+50 && mario_y > que_y-mario_heigh)?1:0;
end


always @(*)begin
     mario_heigh = (!fungi_eaten)?MARIO_HEIGHT :MARIO_HEIGHT_LARGE;
	 mario_width = (!fungi_eaten)?MARIO_WIDTH :MARIO_WIDTH_LARGE;
end

always @(*)begin
    brick_x1_long = ( brick_x1 >= 50 )?brick_x1-50:50-brick_x1;
   brick_x2_long = ( brick_x2 >= 50 )?brick_x2-50:50-brick_x2;
     brick_x3_long = ( brick_x3 >= 50 )?brick_x3-50:50-brick_x3;
   brick_x4_long = ( brick_x4 >= 50 )?brick_x4-50:50-brick_x4;
   que_x_long = ( que_x >= 50 )?que_x-50:50-que_x;
end

always @(*)begin
      pixel = (fungi_eaten)?pixel_l:pixel_s;
end

always @(*)begin
      next_dhh = (flag_UP == Dead && mario_y <= 200)?1:dhh;
end

assign head_hit = (in_renge_x1 && mario_y == brick_y1 + 50 ) || (in_renge_x2 && mario_y == brick_y2 + 50 )||(in_renge_x3 && mario_y == brick_y3 + 50 )||(in_renge_x4 && mario_y == brick_y4 + 50 )||(in_renge_x5 && mario_y == que_y + 50 );
assign jump_on_brick = (in_renge_x1&&mario_y+mario_heigh==brick_y1) || (in_renge_x2&&mario_y+mario_heigh==brick_y2) || (in_renge_x3&&mario_y+mario_heigh==brick_y3) || (in_renge_x4&&mario_y+mario_heigh==brick_y4)|| (in_renge_x5&&mario_y+mario_heigh==que_y);
//assign out_of_brick = (!in_renge_x1 && mario_y+mario_heigh == brick_y1) || (!in_renge_x2 && mario_y+mario_heigh == brick_y2) || (!in_renge_x3 && mario_y+mario_heigh == brick_y3)|| (!in_renge_x4 && mario_y+mario_heigh == brick_y4) || (!in_renge_x5 && mario_y+MARIO_HEIGHT == que_y);
assign out_of_brick = (!in_renge_x1 && mario_y < brick_y1) || (!in_renge_x2 && mario_y < brick_y2) || (!in_renge_x3 && mario_y < brick_y3)|| (!in_renge_x4 && mario_y < brick_y4) || (!in_renge_x5 && mario_y < que_y);
assign hit_monster =  (mario_y > monster_y - mario_heigh) && (mario_x <= monster_x +MONSTER_WIDTH) && (mario_x >= monster_x - mario_width); 
assign dead = !fungi_eaten && hit_monster;
assign deadd = dhh && (mario_y >450);
always @(*) begin
	case(flag_UP)
		Start:begin
			next_flag_UP = (dead)?Dead:Jump;
            next_rc_y = mario_y;
            next_rc_x = mario_x;
            next_mario_y = mario_y;
            end
		Jump:begin	 
            next_flag_UP = (dead)?Dead:(mario_y == rc_y-MARIO_JUMP_HIGH || head_hit)?Down:Jump; // until jump highest or hit brick
			next_rc_y = rc_y;
			next_rc_x = rc_x;
            next_mario_y = (mario_y == rc_y-MARIO_JUMP_HIGH || head_hit ) ? mario_y : mario_y-10;  // until jump highest or hit brick
            end
        Down:begin
            next_flag_UP = (dead)?Dead:(mario_y == rc_y   ||  jump_on_brick )?Pause:Down; //back to present high or on the brick or from brick to the ground
			next_rc_y = rc_y;
			next_rc_x = rc_x;
            next_mario_y = (mario_y == rc_y   ||  jump_on_brick )? mario_y : mario_y+10;
            end
		Pause:begin				
            next_flag_UP = (dead)?Dead:(btnU == 1)?Start: ( out_of_brick) ? Down :Pause;
			next_rc_y = ( out_of_brick)?410:rc_y;
			next_rc_x = rc_x;
			next_mario_y = mario_y;
			end
		Dead :begin
			next_flag_UP = Dead;
			next_rc_y = rc_y;
			next_rc_x = rc_x;
			next_mario_y = (dhh)?mario_y+20:mario_y-20;
			end
		endcase
end

    
endmodule