`timescale 1ns/1ps

module mode00(
    input [2:0]x,
    input [2:0]y,
    output [7:0]ans
);
    integer numx, numy, numans;
    assign numx = x;
    assign numy = y;
    assign numans = (8 * numx) + numy;
    assign ans = numans;
endmodule

module mode01(
    input [2:0]x,
    input [2:0]y,
    output [7:0]ans
);
    integer numx, numy, numans;
    assign numx = x;
    assign numy = y;
    assign numans = numx + (16 * numy);
    assign ans = numans;
endmodule

    