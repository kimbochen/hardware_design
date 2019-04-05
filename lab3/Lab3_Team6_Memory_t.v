`timescale 1ns / 1ps

module Lab3_Team6_Memory_t;
reg  clk = 1'b1;
reg  ren = 1'b1;
reg  wen = 1'b1;
reg  [6-1:0] addr;
reg  [8-1:0] din;
wire [8-1:0] dout;
reg  [8-1:0] golden;
wire check = (dout == golden);
integer i = 0;

Memory memory(
    .clk(clk),
    .ren(ren),
    .wen(wen),
    .addr(addr),
    .din(din),
    .dout(dout)
);

always #2 clk = ~clk;

initial begin
    addr   = 4'b0;
    ren    = 1'b1;
    wen    = 1'b0;
    golden = 8'b0;
    for(i = 0; i < 8; i=i+1) begin
        din = i+1;
        #4 addr = addr + 6'b000001;
    end

    addr = 4'b0;
    ren = 1'b0;
    wen = 1'b1;
    din = 8'b0;
    golden = 1;
    for (i = 0; i < 8; i=i+1) begin
        #4 addr   = addr   + 6'b000001;
           golden = golden + 1;
    end

    addr = 4'b0;
    ren  = 1'b0;
    wen  = 1'b0;
    din  = 8'd39;
    golden = 1;
    for (i = 0; i < 8; i=i+1) begin
        #4 addr   = addr   + 6'b000001;
           golden = golden + 1;
    end

    addr = 4'b0;
    ren  = 1'b1;
    wen  = 1'b1;
    din  = 8'b0;
    golden = 8'b0;
    for (i = 0; i < 8; i=i+1) begin
        #4 addr = addr + 6'b000001;
    end

    #4 $finish;
end
endmodule
