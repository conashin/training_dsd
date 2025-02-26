module seg7_decoder(
    input [3:0] in,
    output [7:0] out // p(point)gfedcba
);

    assign out = 8'b00000000;
    case (in)
        4'b0000: out = 8'b11000000; // 0
        4'b0001: out = 8'b11111001; // 1
        4'b0010: out = 8'b10100100; // 2
        4'b0011: out = 8'b10110000; // 3
        4'b0100: out = 8'b10011001; // 4
        4'b0101: out = 8'b10010010; // 5
        4'b0110: out = 8'b10000010; // 6
        4'b0111: out = 8'b11111000; // 7
        4'b1000: out = 8'b10000000; // 8
        4'b1001: out = 8'b10010000; // 9
        4'b1010: out = 8'b10001000; // A
        4'b1011: out = 8'b10000011; // B
        4'b1100: out = 8'b11000110; // C
        4'b1101: out = 8'b10100001; // D
        4'b1110: out = 8'b10000110; // E
        4'b1111: out = 8'b10001110; // F
        default: out = 8'b11111111; // default 0
    endcase

endmodule

module Lab1_top ( 
    input  [2:0] X,
    input  [2:0] Y,
    input  [1:0] sel, // Which is LSB? sel[1] or sel[0]?
    output reg [7:0] out, 
    output [15:0] seg7, // Two 7-segment displays seg7[15:8] pgfedcba, seg7[7:0] pgfedcba
    output [1:0] seg_en // Select which 7-segment display to enable, [1] for seg7[15:8], [0] for seg7[7:0]
);

    wire [3:0] numx, numy;
    assign numx = X + 3'b010; // X + 2
    assign numy = Y << 1; // 2 * Y

    seg7_decoder seg7_0(.in(numx), .out(seg7[7:0]));
    seg7_decoder seg7_1(.in(numy), .out(seg7[15:8]));

    always @(*) begin
        case (sel)
            2'b00: out = (X << 3) + Y;   // binary representation of 8X + Y
            2'b01: out = (Y << 4) + X;   // binary representation of 16Y + X
            2'b10: out = X << Y;         // Logic shift left X by Y bits
            2'b11: out = Y >> X;         // Logic shift right Y by X bits
            default: out = 8'b00000000;  // default 0
        endcase
        
        case (sel[1])
            1'b0: seg_en[1] = 1'b0; // Enable seg7[7:0]
            1'b1: seg_en[1] = 1'b1; // Enable seg7[15:8]
            default: seg_en[1] = 1'b0; // default 0
        endcase
        
    end



endmodule
