module game_top (
    input  clk, rst,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync, vsync,
    output pmod_1, pmod_2, pmod_4,
    inout  PS2_DATA, PS2_CLK
    );
    
    // game_top signals
    reg  [12-1:0] vgaColor;
    wire clk_25MHz;
    wire clk_22;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    
    // mario_sprite signals
    wire mario_on;
	wire brick1_on;
	wire brick2_on;
	wire brick3_on;
	wire brick4_on;
	wire que_on;
	wire fungi_on;
	wire monster_on;
	wire fungi_eaten;
	wire start_bt_on;
	wire lose_on;
	wire win_on;
	
    wire [10-1:0] mario_x, mario_y;
    wire [10-1:0] brick1_x, brick1_y;
	wire [10-1:0] brick2_x, brick2_y;
	wire [10-1:0] brick3_x, brick3_y;
	wire [10-1:0] brick4_x, brick4_y;
	wire [10-1:0] fungi_x, fungi_y;
	wire [10-1:0] que_x , que_y; 
	wire [10-1:0]monster_x, monster_y;
    wire [10-1:0]mario_heigh ,mario_width;
    wire [12-1:0] mario_pixel;
    wire [12-1:0] brick1_pixel;
	wire [12-1:0] brick2_pixel;
	wire [12-1:0] brick3_pixel;
	wire [12-1:0] brick4_pixel;
    wire [12-1:0] fungi_pixel;
    wire [12-1:0] monster_pixel;
    wire [12-1:0] que_pixel;
    // background_cntrl signals
    wire [12-1:0] bg_pixel;
    
    wire [12-1:0] start_bt_pixel;
    wire [12-1:0] lose_pixel;
    wire [12-1:0] win_pixel;
    
    // signal for player wins or loses
    wire win, lose;
    
    localparam START = 2'd0,
               GAME  = 2'd1,
               WIN   = 2'd2,
               LOSE  = 2'd3;
    wire [2-1:0] state;
    
    // keyboard_cntrl signals
    localparam U = 2'd0,
               L = 2'd1,
               R = 2'd2,
               E = 2'd3;
    wire [4-1:0] key;

    assign {vgaRed, vgaGreen, vgaBlue} = vgaColor;
    
    always @(*)
    begin
        if (valid)
        begin
            case (state)
                START: begin
                    if (start_bt_on)
                        vgaColor = start_bt_pixel;
                    else
                        vgaColor = 12'h0;
                end
                GAME: begin
                    if (mario_on)
                        vgaColor = mario_pixel;
                    else if(brick1_on)
                        vgaColor = brick1_pixel;
                    else if(brick2_on)
                        vgaColor = brick2_pixel;
                    else if(que_on)
                            vgaColor = que_pixel;
                    else if(brick3_on)
                        vgaColor = brick3_pixel;
                    else if(brick4_on)
                        vgaColor = brick4_pixel;						
                    else if (fungi_on && !fungi_eaten)
                        vgaColor = fungi_pixel;
                    else if (monster_on)
                        vgaColor = monster_pixel;
                    else
                        vgaColor = bg_pixel;
                      
                end
                WIN : begin
                    vgaColor = (win_on) ? win_pixel : 12'hFFF;
                end
                LOSE: begin
                    vgaColor = (lose_on) ? lose_pixel : 12'hFFF;
                end
                default: begin
                    vgaColor = 12'h0;
                end
            endcase
        end
        else
        begin
            vgaColor = 12'h0;
        end
    end
    
    game_fsm game_fsm_unit (
        .clk (clk),
        .rst (rst),
        .enter_key (key[E]),
        .win (win),
        .lose (lose),
        .state (state)
    );
        
    clock_divider clk_wiz_0_inst(
        .clk(clk),
        .clk1(clk_25MHz),
        .clk22(clk_22)
    );
    
    keyboard_cntrl #(
        .UP (U),
        .LF (L),
        .RT (R),
        .ET (E)
    ) keyboard_cntrl_unit (
        .clk (clk),
        .rst (rst), 
        .PS2_DATA (PS2_DATA),
        .PS2_CLK (PS2_CLK),
        .key (key)
    );
    
    mario_sprite mario_sprite_unit (
        .clk (clk),
        .clk22(clk_22),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
        .btnU (key[U]),
        .btnL (key[L]),
        .btnR (key[R]),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .mario_on (mario_on),
        .deadd(lose),
        .fungi_eaten(fungi_eaten),
        .monster_x (monster_x),
        .monster_y (monster_y),
        .mario_heigh(mario_heigh) ,
        .mario_width(mario_width),
        .brick_x1 (brick1_x),
        .brick_y1 (brick1_y),
        .brick_x2 (brick2_x),
        .brick_y2 (brick2_y),
        .brick_x3 (brick3_x),
        .brick_y3 (brick3_y),
        .brick_x4 (brick4_x),
        .brick_y4 (brick4_y),
        .que_x (que_x),
        .que_y (que_y),
        .mario_x (mario_x),
        .mario_y (mario_y),
        .pixel (mario_pixel)
    );
    
    start_button_sprite start_button_sprite_unit (
        .clk (clk),
        .clk22 (clk_22),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .start_bt_on (start_bt_on),
        .pixel (start_bt_pixel)
    );
    
    lose_sprite lose_sprite_unit (
        .clk (clk),
        .clk22 (clk_22),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .lose_on (lose_on),
        .pixel (lose_pixel)
    );
    
    win_sprite win_sprite_unit (
        .clk (clk),
        .clk22 (clk_22),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .win_on (win_on),
        .pixel (win_pixel)
    );
    
    brick brick_unit (
        .clk (clk),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
       .btnR (key[R]),
       .btnL (key[L]),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .brick_on (brick1_on),
        .mario_x (mario_x),
        .mario_y (mario_y),
		.brick_x (brick1_x),
		.brick_y (brick1_y),
        .pixel (brick1_pixel)
    );
	
	brick2 brick_unit2 (
        .clk (clk),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
       .btnR (key[R]),
       .btnL (key[L]),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .brick_on (brick2_on),
        .mario_x (mario_x),
        .mario_y (mario_y),
		.brick_x (brick2_x),
		.brick_y (brick2_y),
        .pixel (brick2_pixel)
    );
	
	  que que_unit (
    .clk (clk),
    .rst (rst),
    .clk_25MHz (clk_25MHz),
   .btnR (key[R]),
   .btnL (key[L]),
    .h_cnt (h_cnt),
    .v_cnt (v_cnt),
    .que_on (que_on),
    .mario_x (mario_x),
    .mario_y (mario_y),
    .que_x (que_x),
    .que_y (que_y),
    .pixel (que_pixel)
);
	
	brick3 brick_unit3 (
        .clk (clk),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
       .btnR (key[R]),
       .btnL (key[L]),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .brick_on (brick3_on),
        .mario_x (mario_x),
        .mario_y (mario_y),
		.brick_x (brick3_x),
		.brick_y (brick3_y),
        .pixel (brick3_pixel)
    );
	
	brick4 brick_unit4 (
        .clk (clk),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
       .btnR (key[R]),
       .btnL (key[L]),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .brick_on (brick4_on),
        .mario_x (mario_x),
        .mario_y (mario_y),
		.brick_x (brick4_x),
		.brick_y (brick4_y),
        .pixel (brick4_pixel),
       .win (win)
    );
    
		fungi fungi_unit (
        .clk (clk),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .fungi_on (fungi_on),
        .fungi_eaten(fungi_eaten),
        .mario_x (mario_x),
        .mario_y (mario_y),
		.que_x (que_x),
		.que_y (que_y),
		.fungi_x (fungi_x),
		.fungi_y (fungi_y),
        .pixel (fungi_pixel)
    );
    
    monster monster_unit(
            .clk (clk),
           .rst (rst),
           .clk_25MHz (clk_25MHz),
           .h_cnt (h_cnt),
           .v_cnt (v_cnt),
           .monster_on (monster_on),
            .mario_heigh(mario_heigh) ,
           .mario_width(mario_width),
           .mario_x (mario_x),
           .mario_y (mario_y),
           .monster_x (monster_x),
           .monster_y (monster_y),
           .pixel (monster_pixel)
    );
    
    background_cntrl background_cntrl_unit (
        .clk (clk),
        .rst (rst),
        .clk_25MHz (clk_25MHz),
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .pixel (bg_pixel)
    );
    
    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
   );
   
   music_cntrl music_cntrl_unit (
        .clk (clk),
        .reset (rst),
        .pmod_1 (pmod_1),
        .pmod_2 (pmod_2),
        .pmod_4 (pmod_4)
    );
      
endmodule
