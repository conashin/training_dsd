module Top_Module (
    input [7:0] SW,      // 8-bit 控制開關
    input clk,           // 100MHz FPGA 時鐘
    output [15:0] LED    // 16 顆 LED
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
    wire move_mode;       // 0: 移動 1 顆 LED, 1: 移動 2 顆 LED
    wire light_mode;      // 0: 亮燈模式, 1: 熄滅模式

    assign move_mode  = SW[2];     // 決定移動模式
    assign light_mode = SW[7];     // 亮滅模式

    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin // Reset
            LED <= (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
            position <= SW[6:3];
        end else begin
            // 讓 LED 依據當前位置持續點亮
            LED = (light_mode) ? 16'b1111_1111_1111_1111 : 16'b0000_0000_0000_0000;
            for (integer i = 0; i <= position; i = i + 1) begin
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
