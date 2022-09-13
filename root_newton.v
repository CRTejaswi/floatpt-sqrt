module root_newton (d,clk,reset,start,q,busy,ready,count);
    // Number d, Sqrt q
    input  [31:0] d;
    input         clk, reset;
    input         start;
    output [31:0] q;
    output reg    busy, ready;
    output  [2:0] count;
    reg    [31:0] reg_d;
    reg    [33:0] reg_x;
    reg     [1:0] count;
    // Partial Sums for: X[i+1] = Xi * (3 - Xi * Xi * d) / 2
    // X2, X2d, (3-X2d), X(3-X2d), Xd, X0
    wire   [67:0] X2     = reg_x * reg_x;
    wire   [67:0] X2d    = reg_d * X2[67:32];
    wire   [33:0] k_X2d  = 34'h300000000 - X2d[65:32];
    wire   [67:0] Xk_X2d = reg_x * k_X2d;
    wire   [65:0] Xd     = reg_d * reg_x;
    wire    [7:0] X0     = lut(d[31:27]);
    assign        q      = Xd[63:32] + |Xd[31:0]; // RoundOff
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            busy  <= 0; ready <= 0;
        end else begin
            if (start) begin
                reg_d <= d; reg_x <= {2'b1,X0,24'b0};
                busy  <= 1; ready <= 0; count <= 0;
            end else begin
                reg_x <= Xk_X2d[66:33];
                count <= count + 2'b1;
                if (count == 2'h2) begin // max 3 iterations
                    busy <= 0; ready <= 1;
                end
            end
        end
    end
    function [7:0] lut; // 1/sqrt(d)
        input [4:0] d;
        case (d)
            5'h08: lut = 8'hff; //
            5'h09: lut = 8'he1; //
            5'h0a: lut = 8'hc7; //
            5'h0b: lut = 8'hb1; //
            5'h0c: lut = 8'h9e; //
            5'h0d: lut = 8'h9e; //
            5'h0e: lut = 8'h7f; //
            5'h0f: lut = 8'h72; //
            5'h10: lut = 8'h66; //
            5'h11: lut = 8'h5b; //
            5'h12: lut = 8'h51; //
            5'h13: lut = 8'h48; //
            5'h14: lut = 8'h3f; //
            5'h15: lut = 8'h37; //
            5'h16: lut = 8'h30; //
            5'h17: lut = 8'h29; //
            5'h18: lut = 8'h23; //
            5'h19: lut = 8'h1d; //
            5'h1a: lut = 8'h17; //
            5'h1b: lut = 8'h12; //
            5'h1c: lut = 8'h0d; //
            5'h1d: lut = 8'h08; //
            5'h1e: lut = 8'h04; //
            5'h1f: lut = 8'h00; //
          default: lut = 8'hff; //
        endcase
    endfunction
endmodule
