module Top_Module (
    input [7:0] SW,      // 8-bit 控制開關
    input clk,           // 100MHz FPGA 時鐘
    output [15:0] LED,    // 16 顆 LED
    output [6:0] seg7_DN0    // 7-segment display 6to0 are gfedcba
);
    wire slow_clk, clk_1khz;       // 分頻後的時鐘
    // wire [3:0] LEDState;       // LED 狀態 (Direct to DK2)


    wire [3:0] DK1, DK2, DK3, DK4; // 4-bit 7-segment display
    assign DK1 = SW[6:3];   
    assign DK3 = 4'b0000;
    assign DK4 = 4'b0000;

    // 實例化時鐘分頻模組
    clock_divider clk_div (
        .clk(clk),
        .speed(SW[1]),
        .slow_clk(slow_clk)
    );
    
    // 1kHz Clock for 7-segment display
    div_1khz div_1khz (
        .clk_in(clk),
        .rst_n(~SW[0]),
        .clk_out(clk_1khz)
    );

    // 7-segment display
    seg7 seg7 (
        .clk_1khz(clk_1khz),
        .DK1(DK1),
        .DK2(DK2),
        .DK3(DK3),
        .DK4(DK4),
        .seg(seg7_DN0),
        .an()
    );

    // 實例化 LED 控制模組
    LED_Controller led_ctrl (
        .SW(SW),
        .clk(slow_clk),
        .LED(LED),
        .position(DK2)
    );

endmodule

module LED_Controller (
    input [7:0] SW,        // 8-bit 控制開關
    input clk,            // 來自 clock_divider 的慢時鐘
    output reg [15:0] LED, // 16 顆 LED
    output reg [3:0] position // LED 當前位置 (範圍: 0~15)
);

    wire move_mode;      // 0: 移動 1 顆 LED, 1: 移動 2 顆 LED
    wire light_mode;     // 0: 亮燈模式, 1: 熄滅模式

    assign move_mode  = SW[2];    // 移動模式
    assign light_mode = SW[7];    // 亮滅模式

    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin // Reset
            // *重置 LED 狀態*
            LED      = (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
            position = 4'b0000;  // 設置初始 LED 位置為 0
            LED[0]   = (light_mode) ? 1'b0 : 1'b1; // 只設置第一個 LED
        end else begin
            // *更新 LED 亮燈狀態*
            LED[position] <= (light_mode) ? 1'b0 : 1'b1;

            // **更新 position**
            position <= (position + (move_mode ? 2 : 1)) & 4'hF;

            // **當 position 變為 0，表示走完一圈，重置 LED**
            if (position == 4'b0000) begin
                LED = (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
                 LED[0]   = (light_mode) ? 1'b0 : 1'b1;// 只設置第一個 LED
            end
        end
    end
endmodule

module clock_divider (
    input clk,            // 100MHz FPGA 時鐘
    input speed,          // 速度選擇 (0: 1Hz, 1: 2Hz)
    output reg slow_clk   // 輸出慢時鐘
);
    reg [31:0] counter;
    wire [31:0] max_count;

    localparam [31:0] MAX_COUNT_1HZ  = 100_000_000;
    localparam [31:0] MAX_COUNT_2HZ = 50_000_000;
    assign max_count = (speed) ? MAX_COUNT_2HZ : MAX_COUNT_1HZ;

    always @(posedge clk) begin
        if (counter == max_count / 2 - 1) begin
            slow_clk <= ~slow_clk;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

module div_1khz(
            input clk_in,
            input rst_n,
            output reg clk_out = 0
); // 1kHz降解訊號From elements
    
    parameter dividerCounter = 100000; // 100000000 / 1000 = 100000
    reg[16:0] Counter;
    
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            Counter <= 0;
            end else begin
            if (Counter == (dividerCounter - 1)) begin
                Counter <= 0;
                end else begin
                Counter <= Counter + 1;
            end
        end
    end
    
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            clk_out <= 1'b0;
            end else begin
            if (Counter < (dividerCounter / 2)) begin
                clk_out <= 1'b0;
            end
            else begin
                clk_out <= 1'b1;
            end
        end
    end
endmodule

module seg7_digit_decoder (input [3:0] in, // Convert 5-bit binary to 7-segment display
                          output reg [6:0] seg_out
); // gfedcba, output single 7-segment digits signal

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
    localparam SEG_A     = 7'b1110111; // "A" (g=1, f=1, e=1, d=0, c=1, b=1, a=1)
    localparam SEG_B     = 7'b1111100; // "b" (g=1, f=1, e=1, d=1, c=1, b=0, a=0)
    localparam SEG_C     = 7'b0111001; // "C" (g=0, f=1, e=1, d=1, c=0, b=0, a=1)
    localparam SEG_D     = 7'b1011110; // "d" (g=1, f=0, e=1, d=1, c=1, b=1, a=0)
    localparam SEG_E     = 7'b1111001; // "E" (g=1, f=1, e=1, d=1, c=0, b=0, a=1)
    localparam SEG_F     = 7'b1110001; // "F" (g=1, f=1, e=1, d=0, c=0, b=0, a=1)
    localparam SEG_BLANK = 7'b0000000; // All OFF (g=0, f=0, e=0, d=0, c=0, b=0, a=0)
    localparam SEG_DASH  = 7'b1000000; // "-" (g=1, f=0, e=0, d=0, c=0, b=0, a=0)
    localparam SEG_ERROR = 7'b1111001;  //Err -> E
    localparam SEG_H     = 7'b1110110; // "H" (g=1, f=1, e=1, d=0, c=1, b=1, a=0)
    localparam SEG_L     = 7'b0111000; // "L" (g=0, f=1, e=1, d=1, c=0, b=0, a=0)

    always @(*) begin
        case (in) // Convert to common cathode 7-segment display
            4'h0: seg_out = SEG_0; // 0
            4'h1: seg_out = SEG_1; // 1
            4'h2: seg_out = SEG_2; // 2
            4'h3: seg_out = SEG_3; // 3
            4'h4: seg_out = SEG_4; // 4
            4'h5: seg_out = SEG_5; // 5
            4'h6: seg_out = SEG_6; // 6
            4'h7: seg_out = SEG_7; // 7
            4'h8: seg_out = SEG_8; // 8
            4'h9: seg_out = SEG_9; // 9
            4'hA: seg_out = SEG_A; // A
            4'hB: seg_out = SEG_B; // b
            4'hC: seg_out = SEG_C; // C
            4'hD: seg_out = SEG_D; // d
            4'hE: seg_out = SEG_E; // E
            4'hF: seg_out = SEG_F; // F
            default: seg_out = SEG_BLANK; // default off
        endcase
    end
endmodule

module seg7 (input clk_1khz, // 輸入降解訊號
            input [3:0] DK1,
            input [3:0] DK2,
            input [3:0] DK3,
            input [3:0] DK4,
            output reg [6:0] seg, // 7-segment display
            output reg [3:0] an
); 

    reg [1:0] refresh_counter; // 用來控制顯示Digit
    
    wire [6:0] seg_DK1, seg_DK2, seg_DK3, seg_DK4;

    always @(posedge clk_1khz) begin
        refresh_counter <= refresh_counter + 1;
    end

    seg7_digit_decoder decoder1 (
        .in(DK1),
        .seg_out(seg_DK1)
    );

    seg7_digit_decoder decoder2 (
        .in(DK2),
        .seg_out(seg_DK2)
    );

    /*seg7_digit_decoder decoder3 (
        .in(DK3),
        .seg_out(seg_DK3)
    );*/

    /*seg7_digit_decoder decoder4 (
        .in(DK4),
        .seg_out(seg_DK4)
    );*/

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
            /* 2'b10: begin    
                seg = 7'b0000000;
                an = 4'b0010; // 啟用DN0_K3
                seg = seg_DK3;
            end
            2'b11: begin
                seg = 7'b0000000;
                an = 4'b0001; // 啟用DN0_K4(左側4位最右)
                seg = seg_DK4;
            end */
        endcase
    end
endmodule

