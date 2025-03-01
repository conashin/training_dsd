module seg7_counter (
    // input wire clk,      // FPGA 時脈 (100MHz)
    // input wire reset,    // 重置按鈕
    input wire [3:0] data, // 輸入數字
    output reg [6:0] seg //, // 7 段顯示器 (gfedcba)
    // output reg [3:0] an   // 數碼管選擇
);

    localparam SEG_0 = 7'b1111110; // "0" (a=1, b=1, c=1, d=1, e=1, f=1, g=0)
    localparam SEG_1 = 7'b0110000; // "1" (a=0, b=1, c=1, d=0, e=0, f=0, g=0)
    localparam SEG_2 = 7'b1101101; // "2" (a=1, b=1, c=0, d=1, e=1, f=0, g=1)
    localparam SEG_3 = 7'b1111001; // "3" (a=1, b=1, c=1, d=1, e=0, f=0, g=1)
    localparam SEG_4 = 7'b0110011; // "4" (a=0, b=1, c=1, d=0, e=0, f=1, g=1)
    localparam SEG_5 = 7'b1011011; // "5" (a=1, b=0, c=1, d=1, e=0, f=1, g=1)
    localparam SEG_6 = 7'b1011111; // "6" (a=1, b=0, c=1, d=1, e=1, f=1, g=1)
    localparam SEG_7 = 7'b1110000; // "7" (a=1, b=1, c=1, d=0, e=0, f=0, g=0)
    localparam SEG_8 = 7'b1111111; // "8" (a=1, b=1, c=1, d=1, e=1, f=1, g=1)
    localparam SEG_9 = 7'b1111011; // "9" (a=1, b=1, c=1, d=1, e=0, f=1, g=1)
    localparam SEG_A = 7'b1110111; // "A" (a=1, b=1, c=1, d=0, e=1, f=1, g=1)
    localparam SEG_B = 7'b1111100; // "b" (a=0, b=0, c=1, d=1, e=1, f=1, g=1)
    localparam SEG_C = 7'b0011101; // "C" (a=1, b=0, c=0, d=1, e=1, f=1, g=0)
    localparam SEG_D = 7'b0111110; // "d" (a=0, b=1, c=1, d=1, e=1, f=0, g=1)
    localparam SEG_E = 7'b1011001; // "E" (a=1, b=0, c=0, d=1, e=1, f=1, g=1)
    localparam SEG_F = 7'b1010001; // "F" (a=1, b=0, c=0, d=0, e=1, f=1, g=1)
    localparam SEG_BLANK = 8'b00000000; // All OFF (dp=0, g=0, f=0, e=0, d=0, c=0, b=0, a=0)
    // reg [3:0] counter = 0;      // 計數器 (0-9)
    // reg [26:0] clk_div = 0;     // 降頻計數器 (適用 100MHz FPGA)

    // 降頻計數器 (讓數字每 1 秒變化一次)
    /*
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 0;
            counter <= 0;
        end else begin
            clk_div <= clk_div + 1;
            if (clk_div == 100_000_000) begin // 100MHz -> 1Hz
                clk_div <= 0;
                counter <= (counter == 9) ? 0 : counter + 1;
            end
        end
    end
    */

    // 7 段顯示器字形 (gfedcba)
    always @(*) begin
        case (data)
            4'd0: seg = SEG_0;
            4'd1: seg = SEG_1;
            4'd2: seg = SEG_2;
            4'd3: seg = SEG_3;
            4'd4: seg = SEG_4;
            4'd5: seg = SEG_5;
            4'd6: seg = SEG_6;
            4'd7: seg = SEG_7;
            4'd8: seg = SEG_8;
            4'd9: seg = SEG_9;
            4'd10: seg = SEG_A;
            4'd11: seg = SEG_B;
            4'd12: seg = SEG_C;
            4'd13: seg = SEG_D;
            4'd14: seg = SEG_E;
            4'd15: seg = SEG_F;
            default: seg = SEG_BLANK; // 預設熄滅
        endcase
    end

    /*
    // 選擇數碼管 (顯示於第 1 個數碼管)
    always @(*) begin
        an = 4'b0001; // 只開啟第一個數碼管
    end
    */
endmodule
