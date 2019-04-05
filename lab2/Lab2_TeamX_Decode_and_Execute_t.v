`timescale 1 ns / 1 ps

module Decode_and_Execute_t;
reg [3-1:0] op_code;
reg [4-1:0] rs, rt;
wire [4-1:0] rd;

Decode_and_Execute dae (
    .op_code (op_code), 
    .rs (rs), 
    .rt (rt), 
    .rd (rd)
);

initial begin
    #1 $finish;
end

endmodule
