module Top_Module (
    input [7:0] SW,      // 8-bit 控制開關
    input clk,           // 100MHz FPGA 時鐘
    output [15:0] LED    // 16 顆 LED
);
    wire slow_clk;       // 分頻後的時鐘


    wire [3:0] DK1, DK2, DK3, DK4; // 4-bit 7-segment display

    assign DK1 = SW[6:3];
    
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
    output reg [15:0] LED, // 16 顆 LED
    output reg [3:0] position // LED 當前位置 (範圍: 0~15)
);
    // reg [3:0] position;   // LED 當前位置 (範圍: 0~15)
    wire move_mode;       // 0: 移動 1 顆 LED, 1: 移動 2 顆 LED
    wire light_mode;      // 0: 亮燈模式, 1: 熄滅模式

    assign move_mode  = SW[2];     // 移動模式
    assign light_mode = SW[7];     // 亮滅模式

    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin // Reset
            // *重置 LED 狀態*
            LED = (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
            position = SW[6:3];  // 設置初始 LED 位置
            LED[position] = (light_mode) ? 1'b0 : 1'b1;
        end else begin
            // *累積 LED 亮燈狀態*
            LED[position] <= (light_mode) ? 1'b0 : 1'b1;

            // **更新 position**
            position <= (position + (move_mode ? 2 : 1)) & 4'hF;

            // **當 position 走完 16 個 LED，重置 LED**
            if (position == SW[6:3]) begin
                LED = (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
                LED[position] = (light_mode) ? 1'b0 : 1'b1;
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

    assign max_count = (speed) ? 50_000_000 : 100_000_000;

    always @(posedge clk) begin
        if (counter == max_count / 2 - 1) begin
            slow_clk <= ~slow_clk;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
