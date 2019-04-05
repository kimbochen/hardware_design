`timescale 1ns / 1ps

module Lab1_Team6_Decoder_t;
reg [4-1:0] din = 4'b0000;
wire [16-1:0] dout;

Decoder de(
    .din(din), 
    .dout(dout)
);

initial begin
    repeat (2 ** 4) begin
        #1 din = din + 4'b0001;
    end
    $finish;
end

endmodule