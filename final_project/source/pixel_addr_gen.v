`timescale 1ns / 1ps

module pixel_addr_gen(
    input  [10-1:0] h_cnt, v_cnt,
    input  [10-1:0] x, y,
    input  [12-1:0] pixel, 
    input fungi_eaten,
    output [17-1:0] pixel_addr, 
    output pixel_on
    );
    
    parameter WIDTH = 60;
    parameter HEIGHT = 40;
    
    wire in_region;
    
    assign in_region = ((h_cnt-x) >= 0 && (h_cnt-x) <= WIDTH
                      &&(v_cnt-y) >= 0 && (v_cnt-y) <= HEIGHT);
    assign pixel_addr = ((h_cnt-x) + WIDTH*(v_cnt-y)) ;
    assign pixel_on = (in_region && pixel != 12'h0C0) ? 1'b1 : 1'b0;
    
endmodule
