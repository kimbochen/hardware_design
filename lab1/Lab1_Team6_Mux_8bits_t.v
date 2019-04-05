`timescale 1ns / 1ps
module Lab1_TeamX_Mux_8bits_t;
reg [8-1:0] a, b;
reg sel;
wire [8-1:0] f;

Mux_8bits mx (
    .a (a), 
    .b (b), 
    .sel (sel), 
    .f (f)
);

initial begin
    sel = 1'b0;
    a = 8'b0000_0001;
    b = 8'b0000_0000;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b0000_0010;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b0000_0100;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b0000_1000;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b0001_0000;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b0010_0000;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b0100_0000;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b1000_0000;
    #1 sel = 1'b1;
    
    #1 sel = 1'b0;
    a = 8'b1111_1111;
    b = 8'b0000_0000;
    #1 sel = 1'b1;
    
    #1 $finish;
end

endmodule
