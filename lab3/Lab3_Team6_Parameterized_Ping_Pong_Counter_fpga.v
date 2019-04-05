`timescale 1ns/1ps

//`include "pppc.v"
//`include "push_button_setter.v"
//`include "clock_divider.v"
//`include "time_multiplexor.v"
//`include "segment_converter.v"

`define REFRESH 17
`define COUNT   25

module Parameterized_Ping_Pong_Counter_FPGA(
    input  UP,
    input  DOWN,
    input  clk,
    input  [9-1:0] SW,
    output [4-1:0] AN,
    output [7-1:0] seg
);

wire flip, dir, rst, rst_n;
wire [4-1:0] out;

assign rst_n = ~rst;

Push_Button_Setter pbsetr_up(
    .pb    (UP),
    .clk   (clk),
    .pbout (flip)
);

Push_Button_Setter pbsetr_dw(
    .pb    (DOWN),
    .clk   (clk),
    .pbout (rst)
);

Parameterized_Ping_Pong_Counter pppc(
    .clk       (clk), 
    .rst_n     (rst_n), 
    .enable    (SW[0]), 
    .flip      (flip), 
    .max       (SW[8:5]), 
    .min       (SW[4:1]), 
    .direction (dir), 
    .out       (out)
);

Time_Multiplexor tmux(
    .clk (clk), 
    .AN  (AN)
);

Segment_Converter segconvr(
    .dir (dir),
    .AN(AN),
    .out (out),
    .seg (seg)
);

endmodule

module Push_Button_Setter(
    input  pb,
    input  clk,
    output pbout
);

wire pb_db;

Debounce dbc(
    .pb    (pb),
    .clk   (clk),
    .pb_db (pb_db)
);

One_Pulse ops(
    .pb_db     (pb_db),
    .clk       (clk),
    .pb_1pulse (pbout)
);

endmodule

module Parameterized_Ping_Pong_Counter(
    input  clk,
    input  rst_n,
    input  enable,
    input  flip,
    input  [4-1:0] max,
    input  [4-1:0] min,
    output [4-1:0] out,
    output direction
);

reg  [4-1:0] cnt, nx_cnt;
reg  dir, nx_dir;
wire d_clk, bnd, valid;

assign out       = cnt;
assign direction = dir;
assign bnd       = ((cnt == max) && !dir) || ((cnt == min) && dir);
assign valid     = (min <= cnt && cnt <= max && min < max);

Clock_Divider #(.POW(`COUNT)) clk_divr(
    .clk(clk),
    .o_clk(d_clk)
);

always @(posedge d_clk) begin
    if (!rst_n) begin
        cnt <= min;
        dir <= 0;
    end else begin
        cnt <= nx_cnt;
        dir <= nx_dir;
    end
end

always @(*) begin
    if (flip || bnd) begin
        nx_dir = ~dir;
    end else begin
        nx_dir = dir;
    end
end

always @(*) begin
    if (!enable || !valid) begin
        nx_cnt = cnt;
    end else begin
        nx_cnt = cnt + 1 - 2*(flip^bnd^dir);
    end
end

endmodule

module Time_Multiplexor(
    input  clk,
    output reg [4-1:0] AN
);

wire div_clk;
wire [2-1:0] sel;

Clock_Divider #(.POW(`REFRESH)) clkdivr(
    .clk   (clk), 
    .o_clk (div_clk)
);

Counter #(.POW(2)) cntr(
    .clk (div_clk), 
    .cnt (sel)
);

always @(posedge div_clk) begin
    case(sel)
        2'b00  : AN = 4'b1110;
        2'b01  : AN = 4'b1101;
        2'b10  : AN = 4'b1011;
        default: AN = 4'b0111;
    endcase
end

endmodule

module Segment_Converter(
    input  dir, 
    input  [4 -1:0] AN, 
    input  [4-1:0] out, 
    output [7 -1:0] seg
);

wire [16-1:0] dec;
wire [7 -1:0] dig[4-1:0];

Decoder4X16 dec4x16 (
    .bin  (out), 
    .dout (dec)
);

assign dig[0][0] = dec[1] || dec[4] || dec[11] || dec[14];
assign dig[0][1] = dec[5] || dec[6] || dec[15];
assign dig[0][2] = dec[2] || dec[12]; 
assign dig[0][3] = dec[1] || dec[4] || dec[7] || dec[11] || dec[14];
assign dig[0][4] = dec[1] || dec[3] || dec[4] || dec[5] || dec[7] || dec[9] || dec[11] || dec[13] || dec[14] || dec[15];
assign dig[0][5] = dec[1] || dec[2] || dec[3] || dec[7] || dec[11] || dec[12] || dec[13];
assign dig[0][6] = dec[0] || dec[1] || dec[7] || dec[10] || dec[11];

assign dig[1][0] = |dec[15:10];
assign dig[1][1] = 1'b0;
assign dig[1][2] = 1'b0;
assign dig[1][3] = |dec[15:10];
assign dig[1][4] = |dec[15:10];
assign dig[1][5] = |dec[15:10];
assign dig[1][6] = 1'b1;

assign {dig[2][1:0], dig[2][5]} = {3{dir}};
assign dig[2][4:2] = {3{~dir}};
assign dig[2][6] = 1'b1;

assign {dig[3][1:0], dig[3][5]} = {3{dir}};
assign dig[3][4:2] = {3{~dir}};
assign dig[3][6] = 1'b1;

assign seg[0] = (dig[0][0] && !AN[0]) || (dig[1][0] && !AN[1]) || (dig[2][0] && !AN[2]) || (dig[3][0] && !AN[3]);
assign seg[1] = (dig[0][1] && !AN[0]) || (dig[1][1] && !AN[1]) || (dig[2][1] && !AN[2]) || (dig[3][1] && !AN[3]);
assign seg[2] = (dig[0][2] && !AN[0]) || (dig[1][2] && !AN[1]) || (dig[2][2] && !AN[2]) || (dig[3][2] && !AN[3]);
assign seg[3] = (dig[0][3] && !AN[0]) || (dig[1][3] && !AN[1]) || (dig[2][3] && !AN[2]) || (dig[3][3] && !AN[3]);
assign seg[4] = (dig[0][4] && !AN[0]) || (dig[1][4] && !AN[1]) || (dig[2][4] && !AN[2]) || (dig[3][4] && !AN[3]);
assign seg[5] = (dig[0][5] && !AN[0]) || (dig[1][5] && !AN[1]) || (dig[2][5] && !AN[2]) || (dig[3][5] && !AN[3]);
assign seg[6] = (dig[0][6] && !AN[0]) || (dig[1][6] && !AN[1]) || (dig[2][6] && !AN[2]) || (dig[3][6] && !AN[3]);

endmodule

module Clock_Divider #(parameter POW = 17)(
    input  clk, 
    output o_clk
);

wire [POW-1:0] cnt;

Counter #(.POW(POW)) cntr(
    .clk(clk), 
    .cnt(cnt)
);

assign o_clk = (cnt < (2**POW)/2);

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

module One_Pulse(
    input      pb_db, 
    input      clk, 
    output reg pb_1pulse
);

reg delay;
wire d_clk;

Clock_Divider #(.POW(`COUNT)) clk_divr(
    .clk(clk),
    .o_clk(d_clk)
);

always @(posedge d_clk) begin
    delay     <= pb_db;
    pb_1pulse <= (~delay) & pb_db;
end

endmodule

module Counter #(parameter POW = 2)(
    input      clk, 
    output reg [POW-1:0] cnt
);

reg [POW-1:0] nxt_cnt = 0;

always @(posedge clk) begin
    cnt <= nxt_cnt;
end

always @(*) begin
    if (cnt < (2**POW)-1) begin
        nxt_cnt = cnt + 1;
    end else begin
        nxt_cnt = 0;
    end
end

endmodule

module Decoder4X16(
    input  [4 -1:0] bin,
    output [16-1:0] dout
);

assign dout = 16'h0001 << bin;

endmodule

