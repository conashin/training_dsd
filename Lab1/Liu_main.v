`include "seg7.v"
    
module Lab1_top (
    input  [2:0] X,
    input  [2:0] Y,
    input  [1:0] sel, // sel[1] LSB
    input rst,
    output reg [7:0] out,
    output [15:0] seg7, // Two 7-segment displays seg7[15:8] pgfedcba for DK1, seg7[7:0] pgfedcba for DK0
    output reg [7:0] seg_en // Select which 7-segment display to enable, 8 seg7 in Total, only use seg_en[1] and seg_en[0] for DK1 DK0
    );
    
    wire [3:0] numx, numy;
    wire [7:0] dummy;
    assign numx = X + 3'b010; // X + 2
    assign numy = Y << 1; // 2 * Y
    
    //seg7_decoder seg7_0(.in(numx), .seg_out(seg7[7:0])); // X display on DK0
    //seg7_decoder seg7_1(.in(numy), .seg_out(seg7[15:8])); // Y display on DK1
    seg7_display seg7_0(.in(numx), .seg_out(seg7[7:0]), .seg_en_digit_in(seg_en[0]), .DN0(seg7[7:0]), .DN1(seg7[15:8]));
    seg7_display seg7_1(.in(numy), .seg_out(seg7[15:8]), .seg_en_digit_in(seg_en[1]), .DN0(seg7[7:0]), .DN1(seg7[15:8]));
    
    always @(*) begin
        if (rst) begin
            seg_en <= 8'b11111111;
            end else begin
            case (sel)
                2'b00: out   = (X << 3) + Y;   // binary representation of 8X + Y
                2'b01: out   = (Y << 4) + X;   // binary representation of 16Y + X
                2'b10: out   = X << Y;         // Logic shift left X by Y bits
                2'b11: out   = Y >> X;         // Logic shift right Y by X bits
                default: out = 8'b00000000;  // default 0
            endcase
            
        end
    end
    
endmodule
