`define H 0
`define V 1

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
    
//reg [7:0] position;

//assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;  //640*480 --> 320*240 

//always @ (posedge clk or posedge rst) begin
//    if(rst)
//        position <= 0;
//    else if(position < 239)
//        position <= position + 1;
//    else
//        position <= 0;
//end

parameter UP = 3'd0;
parameter DW = 3'd1;
parameter LF = 3'd2;
parameter RT = 3'd3;
parameter CT = 3'd4;

reg [9-1:0] hpos = 9'b0, next_hpos;
reg [8-1:0] vpos = 8'b0, next_vpos;
reg [3-1:0] dir = CT, next_dir;
reg [2-1:0] flipped = 2'b0, next_flipped;
reg paused = 1'b0, next_paused;

wire [17-1:0] index;
wire [10-1:0] Hcnt, Vcnt;

assign Hcnt = (flipped[`H]) ? 640-h_cnt : h_cnt;
assign Vcnt = (flipped[`V]) ? 480-v_cnt : v_cnt;
assign index = (Hcnt >> 1) + 320 * (Vcnt >> 1);
assign pixel_addr = (index + hpos + 320 * vpos) % 76800;

always @(posedge clk) begin
    if (rst) begin
        flipped <= 2'b0;
        paused  <= 1'b0;
        hpos    <= 9'd0;
        vpos    <= 8'd0;
        dir     <= CT;
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
        default: next_dir = CT;
    endcase
end

endmodule
