`include "Lab1_seg7display.v"

module Lab1_top (input [2:0] X,
                 input [2:0] Y,
                 input [1:0] sel,      // sel[1] LSB
                 output reg [7:0] out,
                 output reg [6:0] DN0,
                 output reg [7:0] seg_en); // Select which 7-segment display to enable, 8 seg7 in Total, only use seg_en[1] and seg_en[0] for DK1 DK0
    
    wire [3:0] numx, numy;
    wire [6:0] seg_digit_x, seg_digit_y;
    assign numx      = X + 3'b010; // X + 2
    assign numy      = Y << 1; // 2 * Y

    seg7_counter xdigits(.data(numx), .seg(seg_digit_x));
    seg7_counter ydigits(.data(numy), .seg(seg_digit_y));

    always @(*) begin
        case (sel)
            2'b00: out   = (X << 3) + Y;   // binary representation of 8X + Y
            2'b01: out   = (Y << 4) + X;   // binary representation of 16Y + X
            2'b10: out   = X << Y;         // Logic shift left X by Y bits
            2'b11: out   = Y >> X;         // Logic shift right Y by X bits
            default: out = 8'b00000000;  // default 0
        endcase
        case (sel[1])
            1'b0: seg_en = 8'b01000000; // Show Y on DK2
            1'b1: seg_en = 8'b10000000; // Show X on DK1
            default: seg_en = 8'b00000000; // Show nothing
        endcase
        case (sel[1])
            1'b0: DN0 = seg_digit_y; // Show Y on DK2
            1'b1: DN0 = seg_digit_x; // Show X on DK1
            default: DN0 = 7'b0000000; // Show nothing
        endcase
    end
    
endmodule
