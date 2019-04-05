`timescale 1ns/1ps

module Greatest_Common_Divisor (clk, rst_n, start, a, b, done, gcd);
input clk, rst_n;
input start;
input [8-1:0] a;
input [8-1:0] b;
output reg [8-1:0] gcd;
output done;

parameter WAIT = 2'b00;
parameter CAL = 2'b01;
parameter FINISH = 2'b10;

reg [2-1:0] state, next_state;
reg [8-1:0] ra, next_ra;
reg [8-1:0] rb, next_rb;

assign done = (state == FINISH);

always @(posedge clk) begin
    if (!rst_n) begin
        state <= WAIT;
        ra    <= a;
        rb    <= b;
    end
    else begin
        state <= next_state;
        ra    <= next_ra;
        rb    <= next_rb;
        case (state)
            WAIT  : $display("WAIT  : start = %b | next_state = %d | done = %b | gcd = %d", start, next_state, done, gcd);
            CAL   : $display("CAL   : ra    = %d | rb = %d | next_state = %d", ra, rb, next_state);
            FINISH: $display("FINISH: gcd   = %d | a  = %d | b = %d | next_state = %d | done = %b", gcd, a, b, next_state, done);
            default: $display("UNKNOWN STATE");
        endcase
    end
end

always @(*) begin
    case (state)
        WAIT: begin
            if (start)
                if (ra == 0 || rb == 0)
                    next_state = FINISH;
                else
                    next_state = CAL;
            else
                next_state = WAIT;
            next_ra = ra;
            next_rb = rb;
            gcd     = 8'd0;
        end
        CAL: begin
            if (ra > rb)
                next_ra = ra - rb;
            else
                next_rb = rb - ra;
            next_state = (next_rb == 0 ? FINISH : CAL);
            gcd = 8'd0;
        end
        FINISH: begin
            next_state = WAIT;
            gcd = (ra == 0 ? rb : ra);
        end
    endcase
end

endmodule
