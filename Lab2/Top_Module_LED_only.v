// `Top_Module.v` - 主模組，負責連接 `Clock_Divider` 和 `LED_Controller`
module Top_Module (
    input [7:0] SW,      // 8-bit 控制開關
    input clk,           // 100MHz FPGA 時鐘
    output [15:0] LED    // 16 顆 LED
);
    wire slow_clk;       // 慢時鐘
    wire [3:0] LEDState; // LED 狀態 

    // **時鐘分頻模組**
    Clock_Divider clk_div (
        .clk(clk),
        .speed(SW[1]),
        .slow_clk(slow_clk)
    );

    // **LED 控制模組**
    LED_Controller led_ctrl (
        .SW(SW),
        .clk(slow_clk),  // 使用 slow_clk
        .LED(LED),
        .position(LEDState)
    );

endmodule

// `LED_Controller.v` - 負責 LED 狀態更新
module LED_Controller (
    input [7:0] SW,       // 8-bit 控制開關
    input clk,            // **接收 `slow_clk` 而非 `clk`**
    output reg [15:0] LED, // 16 顆 LED
    output reg [3:0] position // LED 當前位置 (範圍: 0~15)
);
    // 控制信號
    wire move_mode;       // 0: 移動 1 顆 LED, 1: 移動 2 顆 LED
    wire light_mode;      // 0: 逐漸變暗模式, 1: 逐漸變亮模式

    reg [3:0] init_pos;

    assign move_mode = SW[2]; // 移動模式
    assign light_mode = SW[7]; // 亮滅模式

    // **LED 控制邏輯**
    always @(posedge clk or posedge SW[0]) begin
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
                LED = (light_mode) ? 16'b0000_0000_0000_0000 : 16'b1111_1111_1111_1111;
                LED[init_pos] = light_mode ? 1'b1 : 1'b0;
                position = init_pos;
            end
        end
    end
endmodule

// `Clock_Divider.v` - 時鐘分頻模組，根據 `speed` 控制時鐘速率
module Clock_Divider (
    input clk,            // 100MHz FPGA 時鐘
    input speed,          // 速度選擇 (0: 1Hz, 1: 2Hz)
    output reg slow_clk   // 慢時鐘輸出
);
    reg [31:0] counter;   // 分頻計數器
    wire [31:0] max_count;

    // **定義不同速度的計數值**
    localparam [31:0] MAX_COUNT_1HZ = 100_000_000;
    localparam [31:0] MAX_COUNT_2HZ = 50_000_000;

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
endmodule
