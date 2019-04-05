`timescale 1ns / 1ps

module start_button_sprite (
    input  clk, rst, 
    input  clk22, clk_25MHz, 
    input  [10-1:0] h_cnt, v_cnt, 
    output start_bt_on,
    output [12-1:0] pixel
    );
    
    localparam SB_WIDTH  = 140,
               SB_HEIGHT = 59;
               
    wire [10-1:0] x, y;
    wire [17-1:0] pixel_addr;
    wire [12-1:0] data;
    
    assign x = 10'd320 - SB_WIDTH/2;
    assign y = 10'd240 - SB_HEIGHT/2;
    
    pixel_addr_gen #(
        .WIDTH  (SB_WIDTH),
        .HEIGHT (SB_HEIGHT)
    ) SB_pag (
        .h_cnt (h_cnt),
        .v_cnt (v_cnt),
        .x (x),
        .y (y),
        .fungi_eaten (0),
        .pixel (pixel),
        .pixel_addr (pixel_addr),
        .pixel_on (start_bt_on)
    );
    
    start_button_rom start_button_rom_unit (
        .clka (clk_25MHz),
        .wea   (0),
        .addra (pixel_addr),
        .dina  (data),
        .douta (pixel)
    );
    
endmodule
