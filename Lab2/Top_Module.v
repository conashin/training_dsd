//`include "lab2.v"
module Top_Module (
    input [7:0] SW,      // 8-bit 控制開關
    input clk,           // 100MHz FPGA 時鐘
    output [15:0] LED    // 16 顆 LED
);
    wire [3:0] LEDState; // LED 狀態 
    // 實例化 LED 控制模組
    LED_Controller led_ctrl (
        .SW(SW),
        .clk(clk),
        .LED(LED),
        .position(LEDState)
    );

endmodule

module LED_Controller (
    input [7:0] SW,       // 8-bit 控制開關
    input clk,            // 100MHz FPGA 時鐘
    output reg [15:0] LED, // 16 顆 LED
    output reg [3:0] position // LED 當前位置 (範圍: 0~15)
);
    // 控制信號
    wire move_mode;       // 0: 移動 1 顆 LED, 1: 移動 2 顆 LED
    wire light_mode;      // 0: 逐漸變暗模式, 1: 逐漸變亮模式
    wire speed;           // 速度選擇 (0: 1Hz, 1: 2Hz)

    reg [3:0] init_pos;
    
    // **內建時鐘分頻**
    reg [31:0] counter;
    reg slow_clk;
    
    // **定義分頻計數器的最大值**
    localparam [31:0] MAX_COUNT_1HZ = 100_000_000;
    localparam [31:0] MAX_COUNT_2HZ = 50_000_000;

    assign speed = SW[1];     // 速度模式 (0: 慢, 1: 快)
    assign move_mode = SW[2]; // 移動模式
    assign light_mode = SW[7]; // 亮滅模式
    
    wire [31:0] max_count;
    assign max_count = (speed) ? MAX_COUNT_2HZ : MAX_COUNT_1HZ;

    initial slow_clk = 0; // **初始化 slow_clk**

    always @(posedge clk) begin
        if (counter >= max_count / 2 - 1) begin
            slow_clk <= ~slow_clk; // 翻轉慢時鐘
            counter  <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    // **LED 控制邏輯**
    always @(posedge slow_clk or posedge SW[0]) begin
        if (SW[0]) begin // Reset
            position <= SW[6:3];  // 設定初始 LED 位置
            init_pos <= SW[6:3];  // 記錄初始位置
            LED <= (light_mode) ? 16'b0000_0000_0000_0000 : 16'b1111_1111_1111_1111;
        end else begin
            // **逐漸變亮**
            if (light_mode) begin
                LED[position] <= 1'b1; // 讓當前 LED 變亮
                if (move_mode) 
                    LED[(position + 1) & 4'hF] <= 1'b1;
            end 
            // **逐漸變暗**
            else begin
                LED[position] <= 1'b0; // 讓當前 LED 變暗
                if (move_mode) 
                    LED[(position + 1) & 4'hF] <= 1'b0;
            end

            // **更新 position**
            position <= (position + (move_mode ? 2 : 1)) & 4'hF;

            // **檢查是否完成一輪變化**
            if (&LED || ~|LED) begin
                LED <= (light_mode) ? 16'b0000_0000_0000_0000 : 16'b1111_1111_1111_1111;
            end
        end
    end
endmodule

