`timescale 1ns/1ns
module root_restoring_tb;
    reg  [31:0] d;
    reg         load;
    reg         clk,reset;
    wire [15:0] q;
    wire [16:0] r;
    wire        busy;
    wire        ready;
    wire  [3:0] count;
    root_restoring rt (d,load,clk,reset,q,r,busy,ready,count);
    initial begin
        $dumpfile ("root_restoring.vcd");
        $dumpvars (0, root_restoring);
        $monitor ("At ",$time, ": D=%d, Root=%d, Remainder=%d",d,q,r);
             reset  = 0; load  = 0; clk   = 1; d     = 32'h0000007f;
        #5   reset  = 1; load  = 1;
        #10  load  = 0;
        #250 reset  = 0; load  = 0; clk   = 1; d     = 32'h000000c4;
        #5   reset  = 1; load  = 1;
        #10  load  = 0;
        #250 reset  = 0; load  = 0; clk   = 1; d     = 32'h000000e3;
        #5   reset  = 1; load  = 1;
        #10  load  = 0;
        #250 reset  = 0; load  = 0; clk   = 1; d     = 32'h000000e3;
        #5   reset  = 1; load  = 1;
        #10  load  = 0;
        #250 $finish;
    end
    always #5 clk = !clk;
endmodule
