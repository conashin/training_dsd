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

module mode10(
    input [2:0]x,
    input [2:0]y,
    output [7:0]ans
);
    integer shifting;
    assign shifting = y;
    assign ans = x << shifting;
endmodule

module mode11(
    input [2:0]x,
    input [2:0]y,
    output [7:0]ans
);
    integer shifting;
    assign shifting = x;
    assign ans = y >> shifting;
endmodule

module calulator(
    input [1:0]mode,
    input [2:0]x,
    input [2:0]y,
    output [7:0]ans
);
    wire [7:0]ans;
    mode00 mode00(x, y, ans);
    mode01 mode01(x, y, ans);
    mode10 mode10(x, y, ans);
    mode11 mode11(x, y, ans);
endmodule

