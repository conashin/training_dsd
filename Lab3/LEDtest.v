module LED_Controller(
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire pitch,           // 投球按鈕
    input wire [3:0] speed,     // 速度參數 120~160 以代碼表示 (影響時鐘選擇)
    input wire [1:0] mode,      // 模式選擇
    input clk_1hz,              // 1Hz 時鐘
    input clk_2hz,              // 2Hz 時鐘
    output reg [15:0] LED       // 16 顆 LED 控制
);

    wire clk_div;
    assign clk_div = (speed >= 4) ? clk_2hz : clk_1hz;

    reg [3:0] led_pos; // 當前 LED 位置
    reg [1:0] local_mode;
    reg local_pitch;

    // 監測 pitch 按鈕，讓它只在按下時啟動 LED 控制
    always @(posedge pitch or posedge rst) begin
        if (rst) begin
            local_pitch <= 0;
        end else begin
            local_pitch <= 1;  // 按下 pitch 後啟動 LED 控制
        end
    end

    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            LED <= 16'b0;
            led_pos <= 15;
            local_mode <= mode;
            local_pitch <= 0;
        end 
        else if (local_pitch) begin
            LED = 16'b0; // 清除 LED 陣列
            
            case (local_mode)
                2'b01: begin // 模式 1：快速
                    LED[led_pos] = 1'b1;
                end

                2'b10: begin // 模式 2：滑動
                    if (led_pos > 7)
                        LED[led_pos] = 1'b1; // 前 8 顆逐個亮
                    else if (led_pos % 2 == 1) // 後 8 顆交錯亮
                        LED[led_pos - 1] = 1'b1;
                    else
                        LED[led_pos + 1] = 1'b1;
                end

                2'b11: begin
                    // 這裡不做任何事
                end

                default: LED = 16'b0;
            endcase

            if (led_pos > 0) // 不須循環
                led_pos = led_pos - 1; // 向左移動
        end
    end

    // 模式 3：前 8 顆 1Hz 輪流一個亮一個滅，後 8 顆 2Hz 輪流一個亮一個滅
    always @(posedge clk_1hz) begin
        if (rst == 0 && local_mode == 2'b11 && local_pitch && led_pos > 7) begin
            LED = 16'b0;
            LED[led_pos] = 1'b1; 

            if (led_pos > 0)
                led_pos = led_pos - 1; // 向左移動
        end
    end 

    always @(posedge clk_2hz) begin
        if (rst == 0 && local_mode == 2'b11 && local_pitch && led_pos <= 7) begin
            LED = 16'b0;
            LED[led_pos] = 1'b1; 

            if (led_pos > 0)
                led_pos = led_pos - 1; // 向左移動
        end
    end
endmodule
