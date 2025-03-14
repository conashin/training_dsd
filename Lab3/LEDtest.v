module LED_Controller(
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire [7:0] speed,     // 速度參數 120~160 (影響時鐘選擇)
    input wire [1:0] mode,      // 模式選擇
    input clk_1hz,              // 1Hz 時鐘
    input clk_2hz,              // 2Hz 時鐘
    output reg [15:0] LED       // 16 顆 LED 控制(前8顆 15 - 8,後8顆 7 - 0 )
);
    wire clk_div;


    // 時鐘選擇器：speed >= 140 時使用 2Hz，否則使用 1Hz
    assign clk_div = (speed >= 140) ? clk_2hz : clk_1hz;

    reg [3:0] led_pos; // 當前 LED 位置 (0 ~ 15)

    always @(posedge clk_1hz or posedge clk_2hz or posedge rst) begin
        if (rst) begin
            LED <= 16'b0;
            led_pos <= 15;
        end else begin
            LED = 16'b0; // 確保每次進入 always block 時 LED 陣列被清除
            
            case (mode)
                2'b01: begin
                    if (clk_div) LED[led_pos] = 1'b1; // 模式 1：快速   
                end

                2'b10: begin // 模式 2：滑動
                    if (clk_div) begin
                        if (led_pos > 7)
                            LED[led_pos] = 1'b1; // 前 8 顆逐個亮
                        else if (led_pos % 2 == 1)// 後 8 顆交錯亮
                            LED[led_pos - 1] = 1'b1;
                        else
                            LED[led_pos + 1] = 1'b1;
                    end
                end
                
                2'b11: begin // **模式 3：前 8 顆 1Hz，後 8 顆 2Hz**
                    if (led_pos >= 8 && clk_1hz) begin
                        LED[led_pos] = 1'b1; // **前 8 顆以 1Hz 閃爍**
                    end
                    if (led_pos < 8 && clk_2hz) begin
                        LED[led_pos] = 1'b1;  // **後 8 顆以 2Hz 閃爍**
                    end
                end
                
                default: LED = 16'b0;
            endcase
            
            if (led_pos > 0)//不須循環
                led_pos = led_pos - 1; // 向左移動

        end
    end
endmodule