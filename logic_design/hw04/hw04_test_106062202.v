`timescale 1ns / 100ps
module test;

    parameter pattern = (1 << 16); // 2^16
    reg [7:0] a, b;
    integer i, error;

    wire [15:0] out;

    multiplier multi(.out(out), .a(a), .b(b));

    integer golden, count;

    initial begin
        $fsdbDumpfile("hw4.fsdb");
        $fsdbDumpvars;
    end


    initial begin
        a = 0;
        b = 0;
        error = 0;
        count = 0;
        for (i = 0; i < pattern; i = i + 1) begin
            a = i[15:8];
            b = i[7:0];
            golden = a * b;
            #10
            $display("<%5d> a=%d | b=%d | out=%d (%b) [%d (%b)]", i, a, b, out, out, golden, golden);

            if (golden != out) begin
                count = count + 1;
                $display("Mismatched!");
            end
        end

        if (count ==  0) $display("\n<<< PERFECT!! >>>\n");
        else $display("%d ERRORS\n", count);

        #100 $finish;
    end

endmodule


