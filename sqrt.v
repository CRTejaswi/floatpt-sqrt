`timescale 1ns/1ps
module tst(
    input [31:0]A,
    input clk,
    input reset,
    output [31:0] f_sqrt
);
    wire [7:0] A_exponent;
    wire [22:0] A_mantissa;
    wire A_sign;
    wire [31:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8,temp;
    wire [31:0] x0,x1,x2,x3;
    wire [31:0] sqrt_1by05; // 1/sqrt(0.5)
    wire [31:0] sqrt_2;     // sqrt(2)
    wire [31:0] sqrt_1by2;  // sqrt(0.5)
    wire [7:0] Exp_2;
    wire remainder;
    wire pos;

    // LookUp Values
    assign x0 = 32'h3f5a827a;
    assign sqrt_1by05 = 32'h3fb504f3;
    assign sqrt_2 = 32'h3fb504f3;
    assign sqrt_1by2 = 32'h3f3504f3;
    
    // Number in IEEE754 Format
    assign A_sign = A[31];
    assign A_exponent = A[30:23];
    assign A_mantissa = A[22:0];

    // First Iteration
    divide D1(.A({1'b0,8'd126,A_mantissa}),.B(x0),.C(temp1));
    add A1(.A(temp1),.B(x0),.C(temp2));
    assign x1 = {temp2[31],temp2[30:23]-1,temp2[22:0]};

    // Second Iteration
    divide D2(.A({1'b0,8'd126,A_mantissa}),.B(x1),.C(temp3));
    add A2(.A(temp3),.B(x1),.C(temp4));
    assign x2 = {temp4[31],temp4[30:23]-1,temp4[22:0]};

    // Third Iteration
    divide D3(.A({1'b0,8'd126,A_mantissa}),.B(x2),.C(temp5));
    add A3(.A(temp5),.B(x2),.C(temp6));
    assign x3 = {temp6[31],temp6[30:23]-1,temp6[22:0]};
    multiply M1(.A(x3),.B(sqrt_1by05),.C(temp7));

    assign pos = (A_exponent>=8'd127) ? 1'b1 : 1'b0;
    assign Exp_2 = pos ? (A_exponent-8'd127)/2 : (A_exponent-8'd127-1)/2 ;
    assign remainder = (A_exponent-8'd127)%2;
    assign temp = {temp7[31],Exp_2 + temp7[30:23],temp7[22:0]};
    //assign temp7[30:23] = Exp_2 + temp7[30:23];
    multiply M2(.A(temp),.B(sqrt_2),.C(temp8));
    assign f_sqrt = remainder ? temp8 : temp;

endmodule

module divide(
    input [31:0]A,
    input [31:0]B,
    output [31:0]C
);
    wire [7:0] exp_Brec;
    wire [31:0] B_reciprocal;
    wire [31:0] x0,x1,x2,x3;
    wire [31:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,debug;

    //Initial value
    multiply M1(.A({{1'b0,8'd126,B[22:0]}}),.B(32'h3ff0f0f1),.C(temp1)); //verified
    assign debug = {1'b1,temp1[30:0]};
    add A1(.A(32'h4034b4b5),.B({1'b1,temp1[30:0]}),.C(x0));

    //First Iteration
    multiply M2(.A({{1'b0,8'd126,B[22:0]}}),.B(x0),.C(temp2));
    add A2(.A(32'h40000000),.B({!temp2[31],temp2[30:0]}),.C(temp3));
    multiply M3(.A(x0),.B(temp3),.C(x1));

    //Second Iteration
    multiply M4(.A({1'b0,8'd126,B[22:0]}),.B(x1),.C(temp4));
    add A3(.A(32'h40000000),.B({!temp4[31],temp4[30:0]}),.C(temp5));
    multiply M5(.A(x1),.B(temp5),.C(x2));

    //Third Iteration
    multiply M6(.A({1'b0,8'd126,B[22:0]}),.B(x2),.C(temp6));
    add A4(.A(32'h40000000),.B({!temp6[31],temp6[30:0]}),.C(temp7));
    multiply M7(.A(x2),.B(temp7),.C(x3));

    //Reciprocal : 1/B
    assign exp_Brec = x3[30:23]+8'd126-B[30:23];
    assign B_reciprocal = {B[31],exp_Brec,x3[22:0]};

    //Multiplication A*(1/B)
    multiply M8(.A(A),.B(B_reciprocal),.C(C));

endmodule


module multiply (
    input [31:0]A,
    input [31:0]B,
    output [31:0] C
);
    reg [23:0] A_mantissa,B_mantissa;
    reg [22:0] C_mantissa;
    reg [47:0] Temp_mantissa;
    reg [7:0] A_exponent,B_exponent,Temp_exponent,C_exponent;
    reg A_sign,B_sign,C_sign;

    always@(*) begin
        A_mantissa = {1'b1,A[22:0]};
        A_exponent = A[30:23];
        A_sign = A[31];

        B_mantissa = {1'b1,B[22:0]};
        B_exponent = B[30:23];
        B_sign = B[31];

        Temp_exponent = A_exponent+B_exponent-127;
        Temp_mantissa = A_mantissa*B_mantissa;
        C_mantissa = Temp_mantissa[47] ? Temp_mantissa[46:24] : Temp_mantissa[45:23];
        C_exponent = Temp_mantissa[47] ? Temp_exponent+1'b1 : Temp_exponent;
        C_sign = A_sign^B_sign;
    end
    assign C = {C_sign,C_exponent,C_mantissa};

endmodule


module add(
    input [31:0]A,
    input [31:0]B,
    output reg [31:0] C);

    reg [23:0] a_mantissa,b_mantissa,temp_mantissa;
    reg [22:0] C_mantissa;
    reg [7:0] C_exponent,A_exponent,B_exponent,temp_exponent,diff_exponent;
    reg C_sign,A_sign,B_sign,Temp_sign;
    wire MSB;
    reg [32:0] Temp;
    reg carry,load;
    reg comp;
    reg [7:0] exp_adjust;
    integer i;

    always @(*) begin

        comp = (A[30:23] >= B[30:23])? 1'b1 : 1'b0;

        a_mantissa = comp ? {1'b1,A[22:0]} : {1'b1,B[22:0]};
        A_exponent = comp ? A[30:23] : B[30:23];
        A_sign = comp ? A[31] : B[31];

        b_mantissa = comp ? {1'b1,B[22:0]} : {1'b1,A[22:0]};
        B_exponent = comp ? B[30:23] : A[30:23];
        B_sign = comp ? B[31] : A[31];

        diff_exponent = A_exponent-B_exponent;
        b_mantissa = (b_mantissa >> diff_exponent);
        {carry,temp_mantissa} = (A_sign ~^ B_sign)? a_mantissa + b_mantissa : a_mantissa-b_mantissa ;
        exp_adjust = A_exponent;
        if(carry) begin
            temp_mantissa = temp_mantissa>>1;
            exp_adjust = exp_adjust+1'b1;
        end else begin
            load =0;
            for (i=0;i<24;i=i+1) begin
                if (temp_mantissa[23] ==0 && load ==0) begin
                   temp_mantissa = temp_mantissa<<1;
                   exp_adjust =  exp_adjust-1'b1;
                end else load =1;
            end
        end

        C_sign = A_sign;
        C_mantissa = temp_mantissa[22:0];
        C_exponent = exp_adjust;
        C= {C_sign,C_exponent,C_mantissa};

    end

endmodule

