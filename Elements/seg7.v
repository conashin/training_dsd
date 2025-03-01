module seg7_digit_decoder(input [4:0] in, // Convert 5-bit binary to 7-segment display
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
        case (in) // Convert to common cathode 7-segment display
            5'h0: seg_out = SEG_0; // 0
            5'h1: seg_out = SEG_1; // 1
            5'h2: seg_out = SEG_2; // 2
            5'h3: seg_out = SEG_3; // 3
            5'h4: seg_out = SEG_4; // 4
            5'h5: seg_out = SEG_5; // 5
            5'h6: seg_out = SEG_6; // 6
            5'h7: seg_out = SEG_7; // 7
            5'h8: seg_out = SEG_8; // 8
            5'h9: seg_out = SEG_9; // 9
            5'hA: seg_out = SEG_A; // A
            5'hB: seg_out = SEG_B; // b
            5'hC: seg_out = SEG_C; // C
            5'hD: seg_out = SEG_D; // d
            5'hE: seg_out = SEG_E; // E
            5'hF: seg_out = SEG_F; // F
            5'h10: seg_out = SEG_BLANK; // Blank
            5'h11: seg_out = SEG_DASH; // Dash
            5'h12: seg_out = SEG_ERROR; // Error
            5'h13: seg_out = SEG_H; // H
            5'h14: seg_out = SEG_L; // L
            default: seg_out = SEG_BLANK; // default off
        endcase
    end
endmodule

module seg7_display(input clk, 
                    input [39:0] in, // digits to show (hex with 1-bit extended)
                    output reg [7:0] seg_en_digit, // enable 7-segment display for DN0-1_K1-4; DN1_K4, DN1_K3, DN1_K2, DN1_K1, DN0_K4, DN0_K3, DN0_K2, DN0_K1
                    output reg [7:0] DN0, // 7-segment display for DN0_K1-4, p(point)gfedcba
                    output reg [7:0] DN1); // 7-segment display for DN1_K1-4, p(point)gfedcba
    
    wire [63:0] seg7_dp_out;

    seg7_digit_decoder DN0_K1(.in(in[4:0]), .seg_out(seg7_dp_out[7:0])); // DN0_K1, DK1
    seg7_digit_decoder DN0_K2(.in(in[9:5]), .seg_out(seg7_dp_out[15:8])); // DN0_K2, DK2
    seg7_digit_decoder DN0_K3(.in(in[14:10]), .seg_out(seg7_dp_out[23:16])); // DN0_K3, DK3
    seg7_digit_decoder DN0_K4(.in(in[19:15]), .seg_out(seg7_dp_out[31:24])); // DN0_K4, DK4
    seg7_digit_decoder DN1_K1(.in(in[24:20]), .seg_out(seg7_dp_out[39:32])); // DN1_K1, DK5
    seg7_digit_decoder DN1_K2(.in(in[29:25]), .seg_out(seg7_dp_out[47:40])); // DN1_K2, DK6
    seg7_digit_decoder DN1_K3(.in(in[34:30]), .seg_out(seg7_dp_out[55:48])); // DN1_K3, DK7
    seg7_digit_decoder DN1_K4(.in(in[39:35]), .seg_out(seg7_dp_out[63:56])); // DN1_K4, DK8

    reg [2:0] digit_select; // 3-bit counter for 8 digits

    always @(posedge clk) begin
        // Increment the counter (cycles 0-7)
        digit_select <= digit_select + 1;

        // Select the active digit and output the data
        case (digit_select)
            3'b000: begin // DK0_K1
                seg_en_digit <= 8'b11111110;
                DN0 <= seg7_dp_out[7:0];
                DN1 <= 8'b11111111; // Turn off other segments
            end
            3'b001: begin // DK0_K2
                seg_en_digit <= 8'b11111101;
                DN0 <= seg7_dp_out[15:8];
                DN1 <= 8'b11111111;
            end
            3'b010: begin // DK0_K3
                seg_en_digit <= 8'b11111011;
                DN0 <= seg7_dp_out[23:16];
                DN1 <= 8'b11111111;
            end
            3'b011: begin // DK0_K4
                seg_en_digit <= 8'b11110111;
                DN0 <= seg7_dp_out[31:24];
                DN1 <= 8'b11111111;
            end
            3'b100: begin // DK1_K1
                seg_en_digit <= 8'b11101111;
                DN1 <= seg7_dp_out[39:32];
                DN0 <= 8'b11111111;
            end
            3'b101: begin // DK1_K2
                seg_en_digit <= 8'b11011111;
                DN1 <= seg7_dp_out[47:40];
                DN0 <= 8'b11111111;
            end
            3'b110: begin // DK1_K3
                seg_en_digit <= 8'b10111111;
                DN1 <= seg7_dp_out[55:48];
                DN0 <= 8'b11111111;
            end
            3'b111: begin // DK1_K4
                seg_en_digit <= 8'b01111111;
                DN1 <= seg7_dp_out[63:56];
                DN0 <= 8'b11111111;
            end
        endcase
    end
endmodule