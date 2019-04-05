`timescale 1ns / 1ps

module game_fsm(
    input  clk, rst,
    input  enter_key,
    input win, lose,
    output reg [2-1:0] state
    );
    
    localparam START = 2'd0,
               GAME  = 2'd1,
               WIN   = 2'd2,
               LOSE  = 2'd3;
    
    reg [2-1:0] next_state;
    
    always @(posedge clk)
    begin
        if (rst)
            state <= START;
        else
            state <= next_state;
    end
    
    always @(*)
    begin
        case (state)
            START : next_state = (enter_key) ? GAME : state;
            GAME  : next_state = (win) ? WIN : (lose) ? LOSE : state;
            WIN   : next_state = state;
            LOSE  : next_state = state;
        endcase
    end
endmodule
