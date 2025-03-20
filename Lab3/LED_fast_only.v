module LED_Controller(
    input wire clk,             // 100MHz 時鐘
    input wire rst,             // 重置按鈕
    input wire pitch,           // 投球
    output reg [15:0] LED       // 16 顆 LED 控制 (前 8 顆 15 - 8, 後 8 顆 7 - 0)
);

    reg [3:0] led_pos;
    reg local_pitch;
    wire clk_div;

    // 實例化 1Hz 時鐘
    clkDiv #(
        .INPUT_FREQ(100_000_000),  // 100MHz 輸入時鐘
        .TARGET_FREQ(1)            // 1Hz 輸出時鐘
    ) div1Hz (
        .clk_in(clk),
        .rst_n(~rst),  // 取反 rst，使其符合 active-low reset
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
            else begin            
                local_pitch <= 0; // 停止動畫
            end
        end
        else
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


// Usage
/*
     clkDiv #(
        .CLK_IN_HZ(100_000_000), // Or use clk, and get the frequency from the constraint file.
        .TARGET_HZ(1)
    ) div1Hz ( // 實例化1Hz clock divider
        .clk_in(clk),
        .rst_n(rst),
        .clk_out(Clk1Hz) // Output is Clk1Hz
    );
*/
