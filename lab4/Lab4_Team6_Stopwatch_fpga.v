`timescale 1ns / 1ps

module Lab4_Team6_Stopwatch_fpga (
    input  clk,
    input  start,
    input  reset,
    output dot,
    output [4-1:0] AN,
    output [7-1:0] seg
);

wire [4-1:0] digit[4-1:0];
wire rst_db, rst_n_db;
wire srt_db;

assign rst_n_db  = ~rst_db;

Debounce start_dbc(
    .pb    (start ),
    .clk   (clk   ),
    .pb_db (srt_db)
);

Debounce reset_dbc(
    .pb    (reset ),
    .clk   (clk   ),
    .pb_db (rst_db)
);

Stopwatch stopwatch (
    .clk    (clk     ),
    .rst_n  (rst_n_db),
    .start  (srt_db  ),
    .minute (digit[3]),
    .decasc (digit[2]),
    .second (digit[1]),
    .decisc (digit[0])
);

SevSegDisplay_Controller sevseg (
    .clk (clk     ),
    .min (digit[3]),
    .dca (digit[2]),
    .sec (digit[1]),
    .dci (digit[0]),
    .dot (dot     ),
    .AN  (AN      ),
    .seg (seg     )
);

endmodule

module Debounce(
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

module Stopwatch (
    input  clk,
    input  rst_n,
    input  start,
    output reg [4-1:0] minute,
    output reg [4-1:0] decasc,
    output reg [4-1:0] second,
    output reg [4-1:0] decisc
);

parameter RESET = 2'b00;
parameter COUNT = 2'b01;
parameter WAIT  = 2'b10;

reg  [2 -1:0] state, nxt_state;
reg  [4 -1:0] nxt_minute;
reg  [4 -1:0] nxt_decasc;
reg  [4 -1:0] nxt_second;
reg  [4 -1:0] nxt_decisc;
wire [15-1:0] digits;
wire stop;
wire dClk;

assign digits = { minute, decasc, second, decisc };
assign stop   = (digits == { 4'd9, 4'd5, { 2{4'd9} } });

Clock_Divider #(
    .RFS  (24   ),
    .MAX  (10**7)) clkdvr (
    .clk  (clk  ),
    .dClk (dClk )
);

always @(posedge clk) begin
    if (dClk == 1'b1) begin
        if (!rst_n) begin
            state  <= RESET;
            minute <= 4'b0;
            decasc <= 4'b0;
            second <= 4'b0;
            decisc <= 4'b0;
        end
        else begin
            state  <= nxt_state;
            minute <= nxt_minute;
            decasc <= nxt_decasc;
            second <= nxt_second;
            decisc <= nxt_decisc;
        end
    end
end

always @(*) begin
    case (state)
        RESET  : nxt_state = WAIT;
        WAIT   : nxt_state = (start ? COUNT : WAIT);
        COUNT  : nxt_state = (stop  ? WAIT  : COUNT); 
        default: nxt_state = WAIT;
    endcase
end

always @(*) begin
    case (state)
        COUNT  : begin
            if ({ decasc, second, decisc } == { 4'd5, { 2{4'd9} } })
                nxt_minute = (minute == 4'd9 ? 4'd0 : minute+1);
            else
                nxt_minute = minute;

            if ({ second, decisc } == { { 2{4'd9} } })
                nxt_decasc = (decasc == 4'd5 ? 4'b0 : decasc+1);
            else
                nxt_decasc = decasc;

            if (decisc == 4'd9)
                nxt_second = (second == 4'd9 ? 4'b0 : second+1);
            else
                nxt_second = second;

            nxt_decisc = (decisc == 4'd9 ? 4'b0 : decisc+1);
        end
        default: begin
            nxt_minute = 4'b0;
            nxt_decasc = 4'b0;
            nxt_second = 4'b0;
            nxt_decisc = 4'b0;
        end
    endcase
end

endmodule

module SevSegDisplay_Controller (
    input  clk,
    input  [4-1:0] min,
    input  [4-1:0] dca,
    input  [4-1:0] sec,
    input  [4-1:0] dci,
    output dot,
    output reg [4-1:0] AN,
    output reg [7-1:0] seg
);

reg  [4-1:0] bcd;
reg  [2-1:0] rfs;
wire rfsClk;

Clock_Divider #(
    .RFS  (17    ),
    .MAX  (2**17 )) clkdvr (
    .clk  (clk   ),
    .dClk (rfsClk)
);

always @(posedge clk) begin
    if (rfsClk) begin
        if (rfs < 3)
            rfs <= rfs+1;
        else
            rfs <= 0;
    end
end

always @(*) begin
    case (rfs)
        2'b00: begin
            AN  = 4'b0111;
            bcd = min;
        end
        2'b01: begin
            AN  = 4'b1011;
            bcd = dca;
        end
        2'b10: begin
            AN  = 4'b1101;
            bcd = sec;
        end
        2'b11: begin
            AN  = 4'b1110;
            bcd = dci;
        end
    endcase
end

assign dot = (rfs != 2'b10);

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

module Clock_Divider #(
    parameter RFS = 17,
    parameter MAX = 2**17) (
    input  clk,
    output dClk
);

reg [RFS-1:0] cnt;

assign dClk = (cnt == 0);

always @(posedge clk) begin
    if (cnt < MAX-1)
        cnt <= cnt+1;
    else
        cnt <= 0;
end

endmodule
