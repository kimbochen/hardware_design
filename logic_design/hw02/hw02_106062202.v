module RPS(r1, r0, s1, s0, y1, y0);
2     input r1, r0, s1, s0;
3     output y1, y0;
4     wire y1, y0;
5     assign y1 = (~r1 & r0 & (s1 ^ s0)) | (r1 & ((~r0 & s1) | (r0 & s0)));
6     assign y0 = (r1 & ~r0 & (s1 ^ s0)) | (r0 & ((~r1 & s0) | (r1 & s1)));
7 endmodule
