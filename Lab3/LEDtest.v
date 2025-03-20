module LED_Controller (
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire pitch,           // 投球
    input wire [1:0] mode,      // 模式選擇: 00 -> 關閉, 01 -> FAST, 10 -> SLIDE
    input wire [3:0] speedCode, // Speed Code (決定時鐘)
    output reg [15:0] LED       // 16 顆 LED 控制
);

    wire clk_1hz, clk_2hz, clk_selected;
    wire [15:0] LED_fast, LED_slide;
    reg enable_fast, enable_slide;

    // 產生 1Hz 與 2Hz 時鐘
    clkDiv #(.INPUT_FREQ(100_000_000), .TARGET_FREQ(1)) div1Hz (
        .clk_in(clk),
        .rst_n(~rst),
        .clk_out(clk_1hz)
    );

    clkDiv #(.INPUT_FREQ(100_000_000), .TARGET_FREQ(2)) div2Hz (
        .clk_in(clk),
        .rst_n(~rst),
        .clk_out(clk_2hz)
    );

    // 時鐘選擇器: speedCode >= 4 時使用 2Hz，否則 1Hz
    assign clk_selected = (speedCode >= 4) ? clk_2hz : clk_1hz;

    // FAST 模式
    LED_FAST fast_inst (
        .clk(clk_selected),
        .rst(rst),
        .pitch(pitch),
        .LED(LED_fast)
    );

    // SLIDE 模式
    LED_SLIDE slide_inst (
        .clk(clk_selected),
        .rst(rst),
        .pitch(pitch),
        .LED(LED_slide)
    );

    always @(*) begin
        case (mode)
            2'b01: begin
                enable_fast = 1;
                enable_slide = 0;
            end
            2'b10: begin
                enable_fast = 0;
                enable_slide = 1;
            end
            default: begin
                enable_fast = 0;
                enable_slide = 0;
            end
        endcase
    end

    always @(*) begin
        if (enable_fast)
            LED = LED_fast;
        else if (enable_slide)
            LED = LED_slide;
        else
            LED = 16'b0; // 預設關閉 LED
    end
endmodule


module LED_FAST (
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire pitch,           // 投球
    output reg [15:0] LED       // 16 顆 LED 控制
);
    reg [3:0] led_pos;
    reg local_pitch;
    wire clk_div;

    // 產生 1Hz 時鐘
    clkDiv #(
        .INPUT_FREQ(100_000_000),  
        .TARGET_FREQ(1)            
    ) div1Hz (
        .clk_in(clk),
        .rst_n(~rst),  
        .clk_out(clk_div)
    );

    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            LED <= 16'b1111_1111_1111_1111;
            led_pos <= 15;
            local_pitch <= 0;
        end else if (pitch) begin
            local_pitch <= 1; // 投球觸發
        end else if (local_pitch) begin
            LED = 16'b0;
            LED[led_pos] = 1'b1;

            if (led_pos > 0)
                led_pos <= led_pos - 1;
            else            
                local_pitch <= 0; // 停止動畫
        end else
            LED = 16'b0;
    end
endmodule


module LED_SLIDE (
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire pitch,           // 投球
    output reg [15:0] LED       // 16 顆 LED 控制
);

    reg [3:0] led_pos;
    reg local_pitch;
    wire clk_div;

    // 產生 1Hz 時鐘
    clkDiv #(
        .INPUT_FREQ(100_000_000),  
        .TARGET_FREQ(1)            
    ) div1Hz (
        .clk_in(clk),
        .rst_n(~rst),  
        .clk_out(clk_div)
    );

    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            LED <= 16'b1111_1111_1111_1111;
            led_pos <= 15;
            local_pitch <= 0;
        end else if (pitch) begin
            local_pitch <= 1; // 投球觸發
        end else if (local_pitch) begin
            LED = 16'b0;
            
            if (led_pos > 7)
                LED[led_pos] = 1'b1; // 前 8 顆逐個亮
            else if (led_pos % 2 == 1) // 後 8 顆交錯亮
                LED[led_pos - 1] = 1'b1;
            else
                LED[led_pos + 1] = 1'b1;
                
            if (led_pos > 0)
                led_pos <= led_pos - 1;
            else            
                local_pitch <= 0; // 停止動畫
        end else
            LED = 16'b0;
    end
endmodule


module clkDiv #(
    parameter INPUT_FREQ = 100_000_000, // Input clock frequency (default: 100MHz)
    parameter TARGET_FREQ = 1              // Target output clock frequency (default: 1Hz)
) (
    input clk_in,
    input rst_n,
    output reg clk_out = 0
);

    localparam divParm = INPUT_FREQ / (2 * TARGET_FREQ);
    localparam COUNTER_WIDTH = $clog2(divParm);
    reg [COUNTER_WIDTH-1:0] counter = 0;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == divParm - 1) begin
                counter <= 0;
                clk_out <= ~clk_out; // Toggle clk_out
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
