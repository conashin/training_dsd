// 訊號處理區塊
module seg7 (
    input clk_1khz, // 輸入降解訊號
    input [6:0] seg_DK1,
    input [6:0] seg_DK2,
    input [6:0] seg_DK3,
    input [6:0] seg_DK4,
    output reg [6:0] seg, // gfedcba, output single 7-segment digits signal
    output reg [3:0] an
); 

    reg [1:0] refresh_counter; // 用來控制顯示Digit
    
    always @(posedge clk_1khz) begin
        refresh_counter <= refresh_counter + 1;
    end

    /* wire [6:0] seg_DK1, seg_DK2, seg_DK3, seg_DK4;
    seg7_digit_decoder decoder1 (
        .in(DK1),
        .seg_out(seg_DK1)
    );

    seg7_digit_decoder decoder2 (
        .in(DK2),
        .seg_out(seg_DK2)
    );

    seg7_digit_decoder decoder3 (
        .in(DK3),
        .seg_out(seg_DK3)
    );

    seg7_digit_decoder decoder4 (
        .in(DK4),
        .seg_out(seg_DK4)
    );
    */


    always @(*) begin
        seg = 7'b0000000; // 預設關閉所有顯示器
        case (refresh_counter)
            2'b00: begin
                seg = 7'b0000000; // 先熄滅，避免殘影
                an = 4'b1000; // 啟用DN0_K1(最左)
                seg = seg_DK1;
            end
            2'b01: begin
                seg = 7'b0000000;
                an = 4'b0100; // 啟用DN0_K2
                seg = seg_DK2;
            end
            2'b10: begin    
                seg = 7'b0000000;
                an = 4'b0010; // 啟用DN0_K3
                seg = seg_DK3;
            end
            2'b11: begin
                seg = 7'b0000000;
                an = 4'b0001; // 啟用DN0_K4(左側4位最右)
                seg = seg_DK4;
            end
        endcase
    end
endmodule

// 訊號解碼區塊
module modeDisplayForLab3seg7( // 鍵盤訊號轉譯為7-segment顯示訊號
    input [1:0] mode,
    output reg [6:0] DK1,
    output reg [6:0] DK2,
    output reg [6:0] DK3,
    output reg [6:0] DK4
); // gfedcba, output single 7-segment digits signal
    
    always @(*) begin
        case (mode)
            2'b01: begin // Fast
                DK1 = 7'b1110001;
                DK2 = 7'b1110111;
                DK3 = 7'b1101101;
                DK4 = 7'b1111000;
            end
            2'b10: begin // SLID
                DK1 = 7'b1101101;
                DK2 = 7'b0111000;
                DK3 = 7'b0000110;
                DK4 = 7'b1011110;
            end
            2'b11: begin// ChUP
                DK1 = 7'b0111001;
                DK2 = 7'b1110100;
                DK3 = 7'b0111110;
                DK4 = 7'b1110011;
            end
        endcase
    end
endmodule

module speedDisplayforLab3seg7( // 速度訊號轉譯為7-segment顯示訊號
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