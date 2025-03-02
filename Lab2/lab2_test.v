module Top_Module (
    input [7:0] SW,      // 8-bit 控制開關
    input clk,           // 100MHz FPGA 時鐘
    output [15:0] LED,    // 16 顆 LED
    output [6:0] seg7_DN0    // 7-segment display
);
    wire slow_clk;       // 分頻後的時鐘

    // 實例化時鐘分頻模組
    clock_divider clk_div (
        .clk(clk),
        .speed(SW[1]),
        .slow_clk(slow_clk)
    );

    // 實例化 LED 控制模組
    LED_Controller led_ctrl (
        .SW(SW),
        .clk(slow_clk),
        .LED(LED)
    );

endmodule

module LED_Controller (
    input [7:0] SW,       // 8-bit 控制開關
    input clk,            // 來自 clock_divider 的慢時鐘
    output reg [15:0] LED // 16 顆 LED
);
    reg [3:0] position;   // LED 當前位置
  reg [3:0] init_pos;
    wire move_mode;       // 0: 移動 1 顆 LED, 1: 移動 2 顆 LED
    wire light_mode;      // 0: 亮燈模式, 1: 熄滅模式

    assign move_mode  = SW[2];     // 決定移動模式
    assign light_mode = SW[7];     // 亮滅模式

    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin // Reset
            LED <= (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
            init_pos <= SW[6:3];
          	position <= SW[6:3];
        end else begin
            // 讓 LED 依據當前位置持續點亮
            LED = (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
            for (integer i = init_pos; i <= position; i = i + 1) begin
                LED[i] = (light_mode) ? 0 : 1;
                position <= (position + (move_mode ? 2 : 1)) % 16;
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

    // 決定分頻計數範圍
    assign max_count = (speed) ? 50_000_000 : 100_000_000;

    always @(posedge clk) begin
        if (counter >= max_count / 2) begin
            counter <= 0;
            slow_clk <= ~slow_clk; // 切換慢時鐘
        end else begin
            counter <= counter + 1;
        end
    end
endmodule


module div_1khz (input clk_in,
                input rst_n,
                output reg clk_out = 0
); // 1khz Clock for Seg7
    
    parameter dividerCounter = 100000; // 100000000 / 1000 = 100000
    reg[1:0] Counter;
    
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

module seg7_digit_decoder (input [4:0] in, // Convert 5-bit binary to 7-segment display
                          output reg [7:0] seg_out
); // p(point)gfedcba, output single 7-segment digits signal

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

module seg7 (input clk_1khz, // 輸入降解訊號
            input [3:0] DK1,
            input [3:0] DK2,
            input [3:0] DK3,
            input [3:0] DK4,
            output reg [6:0] seg, // 7-segment display
            output reg [3:0] an
); 

    reg [1:0] refresh_counter; // 用來控制顯示Digit

    always @(posedge clk_1khz) begin
        refresh_counter <= refresh_counter + 1;
    end

    always @(*) begin
        case (refresh_counter)
            2'b00: begin
                seg = 7'b0000000; // 先熄滅，避免殘影
                an = 4'b1000; // 啟用DN0_K1(最左)
                seg = DK1;
            end
            2'b01: begin
                seg = 7'b0000000;
                an = 4'b0100; // 啟用DN0_K2
                seg = DK2;
            end
            2'b10: begin    
                seg = 7'b0000000;
                an = 4'b0010; // 啟用DN0_K3
                seg = DK3;
            end
            2'b11: begin
                seg = 7'b0000000;
                an = 4'b0001; // 啟用DN0_K4(左側4位最右)
                seg = DK4;
            end
            default: begin
                an = 4'b0000; // 預設關閉所有顯示器
                seg = 7'b0000000;
            end
        endcase
    end
endmodule

