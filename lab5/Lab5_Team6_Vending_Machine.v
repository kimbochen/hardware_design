module Vending_Machine_FPGA (
	input  clk,
	input  [5-1:0] button,
	inout  PS2_DATA,
	inout  PS2_CLK,
	output [7-1:0] SEG,
	output [4-1:0] LED,
	output [4-1:0] AN,
	output dot
);

parameter FIV = 0;
parameter TEN = 1;
parameter FTY = 2;
parameter RST = 3;
parameter CNL = 4;

wire [4-1:0] wH;
wire [5-1:0] wG;
wire [7-1:0] wJ;

Button_Setter bt_set (
	.clk    (clk   ),
	.button (button),
	.btout  (wG    )
);

KBKey_Controller (
	.clk    (clk     ),
	.rst    (wG[RST] ),
	.DATA   (PS2_DATA),
	.CLK    (PS2_CLK ),
	.signal (wH      )
);

Vending_Machine vend_mach (
	.clk    (clk                        ),
	.rst    (wG[RST]		    ),
	.cnl    (wG[CNL]		    ),
	.pick   (wH			    ),
	.nt     ({ wG[FTY],wG[TEN],wG[FIV] }),
	.drink  (LED		            ),
	.amount (wJ			    )
);

SevSegDisplay_Controller ssd_cntrl (
	.clk  (clk    ),
	.data (wJ     ),
	.AN   (AN     ),
	.seg  (SEG    ),
	.dot  (dot    )
);

endmodule

module Button_Setter (
	input  clk,
	input  [5-1:0] button,
	output [5-1:0] btout
);

Push_Button_Setter pbset[5-1:0] (
	.clk   ({5{clk}}),
	.pb    (button  ),
	.pbout (btout   )
);

endmodule

module Push_Button_Setter (
    input  clk,
    input  pb,
    output pbout
);

wire pb_db;

Debounce dbc(
    .pb    (pb   ),
    .clk   (clk  ),
    .pb_db (pb_db)
);

One_Pulse ops(
    .pb_db     (pb_db),
    .clk       (clk  ),
    .pb_1pulse (pbout)
);

endmodule

module Debounce (
    input  pb,
    input  clk,
    output pb_db
);

reg [4-1:0] DFF;

always @(posedge clk) begin
    DFF[3:1] <= DFF[2:0];
    DFF[0]   <= pb;
end

assign pb_db = (DFF == 4'b1111);

endmodule

module One_Pulse (
    input      clk,
    input      pb_db,
    output reg pb_1pulse
);

reg delay;

always @(posedge clk) begin
    delay     <= pb_db;
    pb_1pulse <= (~delay) & pb_db;
end

endmodule

module KBKey_Controller (
	input  clk,
	input  rst,
	input  DATA,
	input  CLK,
	output [4-1:0] signal
);

parameter COF = 2'd0;
parameter COK = 2'd1;
parameter OOL = 2'd2;
parameter WAT = 2'd3;

parameter CODE_A = 9'h1C;
parameter CODE_S = 9'h1B;
parameter CODE_D = 9'h23;
parameter CODE_F = 9'h2B;

wire [8  :0] last_change;
wire [511:0] key_down;
wire been_ready;

KeyboardDecoder key_de (
    .key_down    (key_down   ),
    .last_change (last_change),
    .key_valid   (been_ready ),
    .PS2_DATA    (DATA       ),
    .PS2_CLK     (CLK        ),
    .rst         (rst        ),
    .clk         (clk        )
);

assign signal[COF] = key_down[CODE_A];
assign signal[COK] = key_down[CODE_S];
assign signal[OOL] = key_down[CODE_D];
assign signal[WAT] = key_down[CODE_F];

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

module Vending_Machine (
    input  clk,
    input  rst,
    input  cnl,
    input  [4-1:0] pick,
    input  [3-1:0] nt,
    output [4-1:0] drink,
    output reg [7-1:0] amount
);

parameter COF = 2'd0;
parameter COK = 2'd1;
parameter OOL = 2'd2;
parameter WAT = 2'd3;

parameter FIV = 2'd0;
parameter TEN = 2'd1;
parameter FTY = 2'd2;

parameter INSERT  = 1'd0;
parameter CHANGE  = 1'd1;

reg state, next_state;
reg [7-1 :0] next_amount;
reg [27-1:0] cnt, next_cnt;

wire [8-1:0] coin, price;
wire clear, dclk, served;

assign coin   = (5*nt[FIV] + 10*nt[TEN] + 50*nt[FTY]);
assign price  = (55*pick[COF] + 20*pick[COK] + 25*pick[OOL] + 30*pick[WAT]);
assign clear  = (state  == CHANGE && amount == 7'd0);
assign served = |(drink & pick);
assign dclk   = (cnt == 10**8);

always @(posedge clk) begin
    if (state == CHANGE) begin
	if (cnt < 10**8)
	    cnt <= cnt + 1'd1;
	else
	    cnt <= 27'd1;
    end
    else begin
	cnt <= 27'd1;
    end
end

always @(posedge clk) begin
    if (rst) begin
    	state  <= INSERT;
    	amount <= 7'd0;
    end
    else begin
        state  <= next_state;
        amount <= next_amount;
    end
end

always @(*) begin
    case (state)
	INSERT : begin
	    if (served || cnl) begin
		next_state = CHANGE;
	    end
	    else begin
		next_state = INSERT;
	    end
	end
	CHANGE : begin
	    if (clear)
	        next_state = INSERT;
	    else
	        next_state = CHANGE;
	end

	default: next_state = INSERT;
    endcase
end

always @(*) begin
    case (state)
	INSERT : begin
	    if (!served)
		if (amount+coin >= 80)
		    next_amount = 80;
		else
		    next_amount = amount + coin;
	    else
		next_amount = amount - price;
	end
	CHANGE : begin
	    if (dclk == 1'b1)
		if (amount <= 5)
		    next_amount = 7'd0;
		else
		    next_amount = amount-7'd5;
	    else
		next_amount = amount;
	end

	default: next_amount = 7'd0;
    endcase
end

assign drink[COF] = (amount >= 55);
assign drink[COK] = (amount >= 20);
assign drink[OOL] = (amount >= 25);
assign drink[WAT] = (amount >= 30);

endmodule

module SevSegDisplay_Controller (
    input  clk,
    input  [7-1:0] data,
    output reg [4-1:0] AN,
    output reg [7-1:0] seg,
    output dot
);

reg  rfs;
reg  [4-1:0] bcd;
wire [4-1:0] tens, units;
wire rfsClk;

Number_Converter num_conv (
	.num   (data ),
	.tens  (tens ),
	.units (units)
);

Clock_Divider #(
    .RFS  (17    ),
    .MAX  (2**17 )
) clkdvr (
    .clk  (clk   ),
    .dclk (rfsClk)
);


always @(posedge clk) begin
    if (rfsClk) begin
        if (rfs < 1'b1)
            rfs <= rfs + 1'b1;
        else
            rfs <= 1'b0;
    end
    else begin
	rfs <= rfs;
    end
end

always @(*) begin
    if (rfs == 1'b1) begin
	AN  = 4'b1110;
	bcd = units;
    end
    else begin
	AN  = 4'b1101;
	bcd = tens;
    end
end

assign dot = 1'b1;

always @(*) begin
    case(bcd)
        4'b0000: seg = 7'b1000000;
        4'b0001: seg = 7'b1111001;
        4'b0010: seg = 7'b0100100;
        4'b0011: seg = 7'b0110000;
        4'b0100: seg = 7'b0011001;
        4'b0101: seg = 7'b0010010;
        4'b0110: seg = 7'b0000010;
        4'b0111: seg = 7'b1111000;
        4'b1000: seg = 7'b0000000;
        4'b1001: seg = 7'b0010000;
        default: seg = 7'b1000000;
    endcase
end

endmodule

module Number_Converter (
    input  [7-1:0] num,
    output reg [4-1:0] tens,
    output reg [4-1:0] units
);

always @(*) begin
    if (0 <= num && num < 10) begin
        tens  = 4'd0;
        units = num;
    end
    else if (10 <= num && num < 20) begin
        tens  = 4'd1;
        units = num - 10;
    end
    else if (20 <= num && num < 30) begin
        tens  = 4'd2;
        units = num - 20;
    end
    else if (30 <= num && num < 40) begin
        tens  = 4'd3;
        units = num - 30;
    end
    else if (40 <= num && num < 50) begin
        tens  = 4'd4;
        units = num - 40;
    end
    else if (50 <= num && num < 60) begin
        tens  = 4'd5;
        units = num - 50;
    end
    else if (60 <= num && num < 70) begin
        tens  = 4'd6;
        units = num - 60;
    end
    else if (70 <= num && num < 80) begin
        tens  = 4'd7;
        units = num - 70;
    end
    else begin
        tens  = 4'd8;
        units = 4'd0;
    end
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

module Clock_Divider #(
    parameter RFS = 17,
    parameter MAX = 2**17) (
    input  clk,
    output dclk
);

reg [RFS-1:0] cnt;

assign dclk = (cnt == 1'd1);

always @(posedge clk) begin
    if (cnt < MAX)
	cnt <= cnt + 1'd1;
    else
	cnt <= 1'd1;
end

endmodule
