`timescale 1ns/1ps
module tsttb();
    reg [31:0] A;
    wire [31:0] f_sqrt;
    tst s1 (.A(A),.f_sqrt(f_sqrt)
);
    initial begin
    $monitor("A=%h, f_sqrt=%h", A, f_sqrt);
        A = 32'h42040000; // 33
    #20 A = 32'h42aa0000; // 85
    #20 A = 32'h42b80000; // 92
    #20 A = 32'h44208000; // 642
    #20 A = 32'h4517f000; // 2431
    #20 $finish;
    end

endmodule
