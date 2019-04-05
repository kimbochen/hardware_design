`timescale 1ns/1ps

module Binary_to_Grey (din, dout);
input [4-1:0] din;
output [4-1:0] dout;

and conv3 (dout[3], din[3], din[3]);
xor conv2 (dout[2], din[3], din[2]);
xor conv1 (dout[1], din[2], din[1]);
xor conv0 (dout[0], din[1], din[0]);

endmodule
