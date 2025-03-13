
// LED 控制模組
module LED_Controller(
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire [7:0] speed,     // 速度參數 120~160
    input wire [1:0] mode,      // 模式選擇
    output reg [15:0] LED       // 16 顆 LED 控制
);
    reg [1:0] comm_signal;  // 控制 ClockDivider 的信號
    wire clk_div;

    // ClockDivider 實例化 (只應該有一個)
    ClockDivider clk_div_inst (
        .clk(clk),
        .rst(rst),
        .speed(speed),
        .comm(comm_signal),
        .clk_div(clk_div)
    );

    reg [3:0] led_pos; // 當前 LED 位置 (0 ~ 15)

    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            LED <= 16'b0;
            led_pos <= 15;
            comm_signal <= 2'b00; // 預設使用 speed 控制時脈
        end else begin
             //LED = 16'b0; // 清除 LED

            case (mode)
                2'b01: LED[led_pos] = 1'b1; // Mode 1: Fast 
              
                2'b10: begin // Mode 2: Slide
                    if (led_pos > 7)
                        LED[led_pos] = 1'b1; // 前 8 顆亮
                    else if (led_pos % 2 == 1)
                        LED[led_pos - 1] = 1'b1;
                    else
                        LED[led_pos + 1] = 1'b1;
                end
              
                2'b11: begin // Mode 3: Change
                  	LED[led_pos] = 1'b1;
                  comm_signal = (led_pos < 8) ? 2'b10 : 2'b01;
                end  
              
                default: begin
                    LED = 16'b0;
                    comm_signal = 2'b00; // 恢復 speed 控制時脈
                end
              
            endcase
            
            if (led_pos > 0)
                led_pos = led_pos - 1; // 向左移動
        end
    end

endmodule

module ClockDivider(
    input wire clk,          // 100MHz 時鐘
    input wire rst,          // 重置按鈕
    input wire [7:0] speed,  // 速度參數 120~160
    input wire [1:0] comm,   // 0 -> 依照 speed, 1 -> 強制 1Hz, 2 -> 強制 2Hz
    output reg slow_clk      // 輸出分頻時鐘
);
    reg [31:0] counter;
    reg [31:0] max_count;

    localparam [31:0] MAX_COUNT_1HZ = 100_000_000;
    localparam [31:0] MAX_COUNT_2HZ = 50_000_000;

    initial slow_clk = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            slow_clk <= 0;
        end else begin
            if (counter >= max_count / 2 - 1) begin
                slow_clk <= ~slow_clk;
                counter  <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            max_count <= MAX_COUNT_1HZ;  // 預設 1Hz
        else begin
            case (comm)
                2'b01: max_count <= MAX_COUNT_1HZ;
                2'b10: max_count <= MAX_COUNT_2HZ;
                default: max_count <= (speed >= 140) ? MAX_COUNT_2HZ : MAX_COUNT_1HZ;
            endcase
        end
    end

endmodule


