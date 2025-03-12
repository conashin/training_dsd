module ps2HexforLab3seg7(input [15:0] ps2Data,
                         output reg [6:0] DK1,
                         output reg [6:0] DK2,
                         output reg [6:0] DK3,
                         output reg [6:0] DK4); // gfedcba, output single 7-segment digits signal
    
    always @(*) begin
        case (ps2Data)
            16'h2b: begin // Fast
                DK1 = 7'b1110001;
                DK2 = 7'b1110111;
                DK3 = 7'b1101101;
                DK4 = 7'b1111000;
            end
            16'h21: begin// ChUP
                DK1 = 7'b0111001;
                DK2 = 7'b1110100;
                DK3 = 7'b0111110;
                DK4 = 7'b1110011;
            end
            16'h1b: begin // SLID
                DK1 = 7'b1101101;
                DK2 = 7'b0111000;
                DK3 = 7'b0000110;
                DK4 = 7'b1011110;
            end
        endcase
    end
endmodule

module speedDisplayforLab3seg7(
    input [3:0] speedCode,
    output reg [6:0] DK1,
    output reg [6:0] DK2,
    output reg [6:0] DK3,
    output reg [6:0] DK4
);

    localparam SEG_0     = 7'b0111111; // "0" (g=1, f=1, e=1, d=1, c=1, b=1, a=1)
    localparam SEG_1     = 7'b0000110; // "1" (g=0, f=0, e=0, d=0, c=1, b=1, a=0)
    localparam SEG_2     = 7'b1011011; // "2" (g=1, f=0, e=1, d=1, c=0, b=1, a=1)
    localparam SEG_3     = 7'b1001111; // "3" (g=1, f=0, e=0, d=1, c=1, b=1, a=1)
    localparam SEG_4     = 7'b1100110; // "4" (g=1, f=1, e=0, d=0, c=1, b=1, a=0)
    localparam SEG_5     = 7'b1101101; // "5" (g=1, f=1, e=0, d=1, c=1, b=0, a=1)
    localparam SEG_6     = 7'b1111101; // "6" (g=1, f=1, e=1, d=1, c=1, b=0, a=1)
    localparam SEG_7     = 7'b0000111; // "7" (g=0, f=0, e=0, d=0, c=1, b=1, a=1)
    localparam SEG_8     = 7'b1111111; // "8" (g=1, f=1, e=1, d=1, c=1, b=1, a=1)
    localparam SEG_9     = 7'b1101111; // "9" (g=1, f=1, e=0, d=1, c=1, b=1, a=1)
    localparam SEG_BLANK = 7'b0000000; // All OFF (g=0, f=0, e=0, d=0, c=0, b=0, a=0)

    always @(*) begin
        case (speedCode)
            4'b0: begin // 0120
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_2;
                DK4 = SEG_0;
            end
            4'h1: begin// 0125
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_2;
                DK4 = SEG_5;
            end
            4'h2: begin // 0130
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_3;
                DK4 = SEG_0;
            end
            4'h3: begin// 0135
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_3;
                DK4 = SEG_5;
            end
            4'h4: begin // 0140
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_4;
                DK4 = SEG_0;
            end
            4'h5: begin// 0145
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_4;
                DK4 = SEG_5;
            end
            4'h6: begin // 0150
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_5;
                DK4 = SEG_0;
            end
            4'h7: begin// 0155
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_5;
                DK4 = SEG_5;
            end
            4'h8: begin // 0160
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_6;
                DK4 = SEG_0;
            end  
        endcase
    end
endmodule