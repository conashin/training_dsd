module seg7_digit_decoder(input [3:0] in, // Convert 4-bit binary to 7-segment display
                          output reg [7:0] seg_out); // p(point)gfedcba, output single 7-segment digits signal

    localparam SEG_0     = 8'b00111111; // "0" (dp=0, g=0, f=1, e=1, d=1, c=1, b=1, a=1)
    localparam SEG_1     = 8'b00000110; // "1" (dp=0, g=0, f=0, e=0, d=0, c=1, b=1, a=0)
    localparam SEG_2     = 8'b01011011; // "2" (dp=0, g=1, f=0, e=1, d=1, c=0, b=1, a=1)
    localparam SEG_3     = 8'b01001111; // "3" (dp=0, g=1, f=0, e=0, d=1, c=1, b=1, a=1)
    localparam SEG_4     = 8'b01100110; // "4" (dp=0, g=1, f=1, e=0, d=0, c=1, b=1, a=0)
    localparam SEG_5     = 8'b01101101; // "5" (dp=0, g=1, f=1, e=0, d=1, c=1, b=0, a=1)
    localparam SEG_6     = 8'b01111101; // "6" (dp=0, g=1, f=1, e=1, d=1, c=1, b=0, a=1)
    localparam SEG_7     = 8'b00000111; // "7" (dp=0, g=0, f=0, e=0, d=0, c=1, b=1, a=1)
    localparam SEG_8     = 8'b01111111; // "8" (dp=0, g=1, f=1, e=1, d=1, c=1, b=1, a=1)
    localparam SEG_9     = 8'b01101111; // "9" (dp=0, g=1, f=1, e=0, d=1, c=1, b=1, a=1)
    localparam SEG_A     = 8'b01110111; // "A" (dp=0, g=1, f=1, e=1, d=0, c=1, b=1, a=1)
    localparam SEG_B     = 8'b01111100; // "b" (dp=0, g=1, f=1, e=1, d=1, c=1, b=0, a=0)
    localparam SEG_C     = 8'b00111001; // "C" (dp=0, g=0, f=1, e=1, d=1, c=0, b=0, a=1)
    localparam SEG_D     = 8'b01011110; // "d" (dp=0, g=1, f=0, e=1, d=1, c=1, b=1, a=0)
    localparam SEG_E     = 8'b01111001; // "E" (dp=0, g=1, f=1, e=1, d=1, c=0, b=0, a=1)
    localparam SEG_F     = 8'b01110001; // "F" (dp=0, g=1, f=1, e=1, d=0, c=0, b=0, a=1)
    localparam SEG_BLANK = 8'b00000000; // All OFF (dp=0, g=0, f=0, e=0, d=0, c=0, b=0, a=0)
    localparam SEG_DASH  = 8'b01000000; // "-" (dp=0, g=1, f=0, e=0, d=0, c=0, b=0, a=0)
    localparam SEG_ERROR = 8'b01111001;  //Err -> E
    localparam SEG_H     = 8'b01110110; // "H" (dp=0, g=1, f=1, e=1, d=0, c=1, b=1, a=0)
    localparam SEG_L     = 8'b00111000; // "L" (dp=0, g=0, f=1, e=1, d=1, c=0, b=0, a=0)

    always @(*) begin
        case (in)
            4'h0: seg_out = ~SEG_0; // 0
            4'h1: seg_out = ~SEG_1; // 1
            4'h2: seg_out = ~SEG_2; // 2
            4'h3: seg_out = ~SEG_3; // 3
            4'h4: seg_out = ~SEG_4; // 4
            4'h5: seg_out = ~SEG_5; // 5
            4'h6: seg_out = ~SEG_6; // 6
            4'h7: seg_out = ~SEG_7; // 7
            4'h8: seg_out = ~SEG_8; // 8
            4'h9: seg_out = ~SEG_9; // 9
            4'hA: seg_out = ~SEG_A; // A
            4'hB: seg_out = ~SEG_B; // b
            4'hC: seg_out = ~SEG_C; // C
            4'hD: seg_out = ~SEG_D; // d
            4'hE: seg_out = ~SEG_E; // E
            4'hF: seg_out = ~SEG_F; // F
            default: seg_out = SEG_BLANK; // default off
        endcase
    end
endmodule

module seg7_display(input [31:0] in, // digits to show
                    input [7:0] seg_en_digit_in, // setup which digit to show
                    output reg [7:0] seg_en_digit, // enable 7-segment display for DN0-1_K1-4; DN1_K4, DN1_K3, DN1_K2, DN1_K1, DN0_K4, DN0_K3, DN0_K2, DN0_K1
                    output reg [7:0] DN0, // 7-segment display for DN0_K1-4, p(point)gfedcba
                    output reg [7:0] DN1); // 7-segment display for DN1_K1-4, p(point)gfedcba
    
    wire [63:0] seg7_dp_out;

    seg7_digit_decoder DN0_K1(.in(in[3:0]), .seg_out(seg7_dp_out[7:0])); // DK0_K1, DK1
    seg7_digit_decoder DN0_K2(.in(in[7:4]), .seg_out(seg7_dp_out[15:8])); // DK0_K2, DK2
    seg7_digit_decoder DN0_K3(.in(in[11:8]), .seg_out(seg7_dp_out[23:16])); // DK0_K3, DK3
    seg7_digit_decoder DN0_K4(.in(in[15:12]), .seg_out(seg7_dp_out[31:24])); // DK0_K4, DK4
    seg7_digit_decoder DN1_K1(.in(in[19:16]), .seg_out(seg7_dp_out[39:32])); // DK1_K1, DK5
    seg7_digit_decoder DN1_K2(.in(in[23:20]), .seg_out(seg7_dp_out[47:40])); // DK1_K2, DK6
    seg7_digit_decoder DN1_K3(.in(in[27:24]), .seg_out(seg7_dp_out[55:48])); // DK1_K3, DK7
    seg7_digit_decoder DN1_K4(.in(in[31:28]), .seg_out(seg7_dp_out[63:56])); // DK1_K4, DK8

    always @(*) begin
        case (seg_en_digit_in)
            8'b11111110: seg_en_digit = 8'b11111110; // DK0_K1
            8'b11111101: seg_en_digit = 8'b11111101; // DK0_K2
            8'b11111011: seg_en_digit = 8'b11111011; // DK0_K3
            8'b11110111: seg_en_digit = 8'b11110111; // DK0_K4
            8'b11101111: seg_en_digit = 8'b11101111; // DK1_K1
            8'b11011111: seg_en_digit = 8'b11011111; // DK1_K2
            8'b10111111: seg_en_digit = 8'b10111111; // DK1_K3
            8'b01111111: seg_en_digit = 8'b01111111; // DK1_K4
            default: seg_en_digit = 8'b11111111; // default off
        endcase
        case (seg_en_digit)
            8'b11111110: DN0 = seg7_dp_out[7:0]; // DK0_K1
            8'b11111101: DN0 = seg7_dp_out[15:8]; // DK0_K2
            8'b11111011: DN0 = seg7_dp_out[23:16]; // DK0_K3
            8'b11110111: DN0 = seg7_dp_out[31:24]; // DK0_K4
            8'b11101111: DN1 = seg7_dp_out[39:32]; // DK1_K1
            8'b11011111: DN1 = seg7_dp_out[47:40]; // DK1_K2
            8'b10111111: DN1 = seg7_dp_out[55:48]; // DK1_K3
            8'b01111111: DN1 = seg7_dp_out[63:56]; // DK1_K4
            default: DN0 = 8'b11111111; DN1 = 8'b11111111; // default off
        endcase
    end
endmodule