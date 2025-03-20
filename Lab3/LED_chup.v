module LED_Controller(
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire pitch,           // 投球
    output reg [15:0] LED       // 16 顆 LED 控制 (前 8 顆 15 - 8, 後 8 顆 7 - 0)
);

    reg [3:0] led_pos;
    reg local_pitch;
    wire clk_1hz, clk_2hz;
    reg clk_select; // 用來切換 1Hz 或 2Hz 更新 LED

    // 產生 1Hz 和 2Hz 時鐘
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

    // **時脈選擇邏輯** (在 clk_1hz 觸發時，改變 clk_select)
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            clk_select <= 0; // 重置時，選擇 1Hz
        else
            clk_select <= ~clk_select; // 交替切換 1Hz / 2Hz
    end

    // **LED 控制邏輯 (只用 clk_1hz 控制)**
    always @(posedge clk_1hz or posedge rst) begin
        if (rst) begin
            LED <= 16'b1111_1111_1111_1111; // 預設全亮
            led_pos <= 15;
            local_pitch <= 0;
        end else if (pitch) begin
            local_pitch <= 1; // 投球觸發
        end else if (local_pitch) begin
            LED = 16'b0; // 清空 LED
            
            // **1Hz 控制前 8 顆，2Hz 控制後 8 顆**
            if (clk_select && led_pos > 7) begin
                LED[led_pos] = 1'b1; // 前 8 顆 LED 以 1Hz 逐個亮起
            end else if (!clk_select && led_pos <= 7) begin
                LED[led_pos] = 1'b1; // 後 8 顆 LED 以 2Hz 逐個亮起
            end

            if (led_pos > 0)
                led_pos <= led_pos - 1;
            else
                local_pitch <= 0; // 停止動畫
        end else begin
            LED <= 16'b0; // **沒有動畫時清除 LED**
        end
    end
    
endmodule

module clkDiv #(
    parameter INPUT_FREQ = 100_000_000, // Input clock frequency (default: 100MHz)
    parameter TARGET_FREQ = 1           // Target output clock frequency (default: 1Hz)
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
