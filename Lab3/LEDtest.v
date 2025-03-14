module LED_Controller(
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire [7:0] speed,     // 速度參數 120~160 (影響時鐘選擇)
    input wire [1:0] mode,      // 模式選擇
    output reg [15:0] LED       // 16 顆 LED 控制
);
    wire clk_1hz, clk_2hz;
    wire clk_div;

    // 產生 1Hz 時鐘
    clkDiv #(
        .INPUT_FREQ(100_000_000),
        .TARGET_FREQ(1)
    ) clk_1hz_inst (
        .clk_in(clk),
        .rst_n(~rst),
        .clk_out(clk_1hz)
    );

    // 產生 2Hz 時鐘
    clkDiv #(
        .INPUT_FREQ(100_000_000),
        .TARGET_FREQ(2)
    ) clk_2hz_inst (
        .clk_in(clk),
        .rst_n(~rst),
        .clk_out(clk_2hz)
    );

    // 時鐘選擇器：speed >= 140 時使用 2Hz，否則使用 1Hz
    assign clk_div = (speed >= 140) ? clk_2hz : clk_1hz;

    reg [3:0] led_pos; // 當前 LED 位置 (0 ~ 15)

    always @(posedge clk_1hz or posedge clk_2hz or posedge rst) begin
        if (rst) begin
            LED <= 16'b0;
            led_pos <= 15;
        end else begin
            LED = 16'b0; // **確保每次進入 always block 時 LED 陣列被清除**
            
            case (mode)
                2'b01: begin
                    if (clk_div) LED[led_pos] = 1'b1; // 模式 1：快閃
                end

                2'b10: begin // 模式 2：滑動
                    if (clk_div) begin
                        if (led_pos > 7)
                            LED[led_pos] = 1'b1; // 前 8 顆亮
                        else if (led_pos % 2 == 1)
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

module clkDiv #(
    parameter INPUT_FREQ = 100_000_000, // Input clock frequency (default: 100MHz)
    parameter TARGET_FREQ = 1              // Target output clock frequency (default: 1Hz)
) (
    input clk_in,
    input rst_n,
    output reg clk_out = 0
);

    // Calculate the divider value.  We divide by 2 * target hz because we toggle
    // clk_out, effectively creating a 50% duty cycle.
    localparam divParm = INPUT_FREQ / (2 * TARGET_FREQ);

    // Determine the required counter width (number of bits)
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
