`timescale 1ns / 1ps

module win_sprite(
    input  clk, rst, 
    input  clk22, clk_25MHz, 
    input  [10-1:0] h_cnt, v_cnt, 
    output win_on,
    output [12-1:0] pixel
    );
    
    localparam WN_WIDTH  = 49,
               WN_HEIGHT = 46;
    
    wire [10-1:0] x, y;
    wire [17-1:0] pixel_addr;
    wire [12-1:0] data;
    
    assign x = 10'd320 - WN_WIDTH/2;
    assign y = 10'd240 - WN_HEIGHT/2;
    
     pixel_addr_gen #(
           .WIDTH  (WN_WIDTH),
           .HEIGHT (WN_HEIGHT)
        ) WN_pag (
           .h_cnt (h_cnt),
           .v_cnt (v_cnt),
           .x (x),
           .y (y),
           .fungi_eaten (0),
           .pixel (pixel),
           .pixel_addr (pixel_addr),
           .pixel_on (win_on)
        );
          
        win_rom win_rom_unit (
             .clka (clk_25MHz),
             .wea   (0),
             .addra (pixel_addr),
             .dina  (data),
             .douta (pixel)
         );
    
endmodule
