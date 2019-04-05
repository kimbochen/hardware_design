module top(
   input clk,
   input rst,
   inout PS2_DATA,
   inout PS2_CLK,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync
    );

    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480

  parameter UP = 3'd0,
            DW = 3'd1,
            LF = 3'd2,
            RT = 3'd3,
            PS = 3'd4,
            HF = 3'd5,
            VF = 3'd6;
  
  parameter KEY_W = 9'h1D,
            KEY_A = 9'h1C,
            KEY_S = 9'h1B,
            KEY_D = 9'h23,
            KEY_P = 9'h4D,
            KEY_H = 9'h33,
            KEY_V = 9'h2A;

  wire key_valid;
  wire [9  -1:0] last_change;
  wire [512-1:0] key_down;
  wire [7-1:0] key;

  assign key[UP] = (key_down[KEY_W] == 1'b1) ? 1'b1 : 1'b0;
  assign key[DW] = (key_down[KEY_S] == 1'b1) ? 1'b1 : 1'b0;
  assign key[LF] = (key_down[KEY_A] == 1'b1) ? 1'b1 : 1'b0;
  assign key[RT] = (key_down[KEY_D] == 1'b1) ? 1'b1 : 1'b0;
  assign key[PS] = (key_down[KEY_P] == 1'b1) ? 1'b1 : 1'b0;
  assign key[HF] = (key_down[KEY_H] == 1'b1) ? 1'b1 : 1'b0;
  assign key[VF] = (key_down[KEY_V] == 1'b1) ? 1'b1 : 1'b0;
  
  KeyboardDecoder kb_decoder(
    .key_down (key_down),
    .key_valid (key_valid),
    .last_change (last_change),
    .PS2_DATA (PS2_DATA),
    .PS2_CLK (PS2_CLK),
    .rst (rst),
    .clk (clk)
  );

  assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

     clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    );

    mem_addr_gen mem_addr_gen_inst(
    .clk(clk_22),
    .rst(rst),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .key(key[3:0]),
    .flip({ key[VF], key[HF] }),
    .pause(key[PS]),
    .pixel_addr(pixel_addr)
    );
     
 
    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel)
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
      
endmodule
