`timescale 1 ns / 1 ps

module Binary_to_Grey_t;
reg [4-1:0] bin;
wire [4-1:0] grey;

Binary_to_Grey btg (
    .din(bin), 
    .dout(grey)
);

initial begin
    bin = 4'b0000;

    repeat (2 ** 4) begin
        #1 bin = bin + 4'b0001;
    end
    
    #1 $finish;
end

endmodule
