`timescale 1ns/1ns
module root_newton_tb;
    reg  [31:0] d;
    reg         start;
    reg         clk,reset;
    wire [31:0] q;
    wire        busy;
    wire        ready;
    wire  [1:0] count;
    root_newton root (d,clk,reset,start,q,busy,ready,count);
    initial begin
        $dumpfile ("root_newton.vcd");
        $dumpvars (0, root_newton);
        $monitor ("At ",$time, ": D=0.%h, Root=0.%h",d,q);

        // d = 0x0.40000000 = 0.25
        // sqrt(d) = 0x0.80000000 = 0.5 (0.5)
             reset=0; start=0; clk=1; d=32'h40000000;
        #35  reset=1; start=1;
        #70  start= 0;
        
        // d = 0x0.c0000000 = 0.75
        // sqrt(d) = 0.8660254038 = 0x0.ddb3d743
        #455 d    = 32'hc0000000;
        #35  start= 1;
        #70  start= 0;

        // d = 0x0.f8000000 = 0.96875
        // sqrt(d) = 0x0.fbe00000 = 0.9842509843
        #455 d    = 32'hf8000000;
        #35  start= 1;
        #70  start= 0;

        // d = 0x0.fffe0001 = 0.9999694827, sqrt(d) = 0.
        //#455 d    = 32'hfffe0001; // d = 0x0. = 
        //#35  start= 1;
        //#70  start= 0;
        #455 $finish;
    end
    always #35 clk = !clk;
endmodule
