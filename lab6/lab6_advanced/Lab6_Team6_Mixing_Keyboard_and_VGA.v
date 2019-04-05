`define H 0
`define V 1

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

module clock_divisor(clk1, clk, clk22);
input clk;
output clk1;
output clk22;
reg [21:0] num;
wire [21:0] next_num;

always @(posedge clk) begin
  num <= next_num;
end

assign next_num = num + 1'b1;
assign clk1 = num[1];
assign clk22 = num[21];
endmodule

module KeyboardDecoder(
	output reg [511:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	OnePulse op (
		.signal_single_pulse(pulse_been_ready),
		.signal(been_ready),
		.clock(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end

endmodule

module mem_addr_gen(
    input clk,
    input rst,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [4-1:0] key,
    input [2-1:0] flip,
    input pause,
    output [16:0] pixel_addr
);

parameter UP = 3'd0;
parameter DW = 3'd1;
parameter LF = 3'd2;
parameter RT = 3'd3;
parameter CT = 3'd4;

reg [9-1:0] hpos = 9'b0, next_hpos;
reg [8-1:0] vpos = 8'b0, next_vpos;
reg [3-1:0] dir = UP, next_dir;
reg [2-1:0] flipped = 2'b0, next_flipped;
reg paused, next_paused;

wire [17-1:0] index;
wire [10-1:0] Hcnt, Vcnt;

assign Hcnt = (flipped[`H]) ? 640-h_cnt : h_cnt;
assign Vcnt = (flipped[`V]) ? 480-v_cnt : v_cnt;
assign index = (Hcnt >> 1) + 320 * (Vcnt >> 1);
assign pixel_addr = (index + hpos + 320 * vpos) % 76800;

always @(posedge clk) begin
    if (rst) begin
        flipped <= 2'b0;
        paused  <= 1'b1;
        hpos    <= 9'd0;
        vpos    <= 8'd0;
        dir     <= UP;
    end
    else begin
        flipped <= next_flipped;
        paused  <= next_paused;
        hpos    <= next_hpos;
        vpos    <= next_vpos;
        dir     <= next_dir;
    end
end

always @(*) begin
    next_flipped[`H] = (flip[`H] == 1'b1) ? ~flipped[`H] : flipped[`H];
    next_flipped[`V] = (flip[`V] == 1'b1) ? ~flipped[`V] : flipped[`V];
end

always @(*) begin
    next_paused = (pause == 1'b1) ? ~paused : paused;
end

always @(*) begin
    if (paused) begin
        next_hpos = hpos;
    end else begin
        case (dir)
            LF     : begin
                if (flipped[`H])
                    next_hpos = (hpos > 0) ? hpos-1'b1 : 9'd319;
                else
                    next_hpos = (hpos < 319) ? hpos+1'b1 : 9'd0;
            end
            RT     : begin
                if (flipped[`H])
                    next_hpos = (hpos < 319) ? hpos+1'b1 : 9'd0;
                else
                    next_hpos = (hpos > 0) ? hpos-1'b1 : 9'd319;
            end
            UP     : next_hpos = hpos;
            DW     : next_hpos = hpos;
            CT     : next_hpos = hpos;
            default: next_hpos = 9'd0;
        endcase
    end
end

always @(*) begin
    if (paused) begin
        next_vpos = vpos;
    end else begin
        case (dir)
            UP     : begin
                if (flipped[`V])
                    next_vpos = (vpos > 0) ? vpos-1'b1 : 8'd239;
                else
                    next_vpos = (vpos < 239) ? vpos+1'b1 : 8'd0;
            end
            DW     : begin
                if (flipped[`V])
                    next_vpos = (vpos < 239) ? vpos+1'b1 : 8'd0;
                else
                    next_vpos = (vpos > 0) ? vpos-1'b1 : 8'd239;
            end
            LF     : next_vpos = vpos;
            RT     : next_vpos = vpos;
            CT     : next_vpos = vpos;
            default: next_vpos = 8'd0;
        endcase
    end
end

always @(*) begin
    case (key)
        4'b0001: next_dir = UP;
        4'b0010: next_dir = DW;
        4'b0100: next_dir = LF;
        4'b1000: next_dir = RT;
        4'b0000: next_dir = dir;
        default: next_dir = UP;
    endcase
end

endmodule


module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);
	
	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule

`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////

module vga_controller 
  (
    input wire pclk,reset,
    output wire hsync,vsync,valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );
    
    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;
    wire hsync_default, vsync_default;
    wire [9:0] HD, HF, HS, HB, HT, VD, VF, VS, VB, VT;

   
    assign HD = 640;
    assign HF = 16;
    assign HS = 96;
    assign HB = 48;
    assign HT = 800; 
    assign VD = 480;
    assign VF = 10;
    assign VS = 2;
    assign VB = 33;
    assign VT = 525;
    assign hsync_default = 1'b1;
    assign vsync_default = 1'b1;
     
    always@(posedge pclk)
        if(reset)
            pixel_cnt <= 0;
        else if(pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
             else
                pixel_cnt <= 0;

    always@(posedge pclk)
        if(reset)
            hsync_i <= hsync_default;
        else if((pixel_cnt >= (HD + HF - 1))&&(pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 
    
    always@(posedge pclk)
        if(reset)
            line_cnt <= 0;
        else if(pixel_cnt == (HT -1))
                if(line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;
                    
    always@(posedge pclk)
        if(reset)
            vsync_i <= vsync_default; 
        else if((line_cnt >= (VD + VF - 1))&&(line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 
                    
    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));
    
    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt:10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt:10'd0;
           
endmodule
