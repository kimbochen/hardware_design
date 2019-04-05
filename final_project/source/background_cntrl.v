`timescale 1ns / 1ps

module background_cntrl(
    input clk, rst,
    input clk_25MHz,
    input [10-1:0] h_cnt,
    input [10-1:0] v_cnt,
    output [12-1:0] pixel
    );
    
    wire [17-1:0] pixel_addr;
    wire [12-1:0] data;
    
    assign pixel_addr = ((h_cnt>>1) + 320*(v_cnt>>1)) % 76800;
    
    game_bg_rom game_bg_rom_unit (
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel)
        );
    
endmodule
