module LED_Controller (
    input [7:0] SW,       // 8-bit 控制開關
    input clk,            // 來自 clock_divider 的慢時鐘
    output reg [15:0] LED, // 16 顆 LED
    output reg [3:0] position // LED 當前位置 (範圍: 0~15)
);
    wire move_mode;       // 0: 移動 1 顆 LED, 1: 移動 2 顆 LED
    wire light_mode;      // 0: 逐漸變暗模式, 1: 逐漸變亮模式
    reg [3:0] init_pos;
  
    assign move_mode  = SW[2];     // 移動模式
    assign light_mode = SW[7];     // 亮滅模式

    always @(posedge clk or posedge SW[0]) begin
                        
        if (SW[0]) begin // Reset
            position = SW[6:3];  // 設置初始 LED 位置
            init_pos = SW[6:3];
            LED = (light_mode) ? 16'b0000_0000_0000_0000 : 16'b1111_1111_1111_1111;
            LED[position] = (light_mode) ? 1'b1 : 1'b0; // 設定初始 LED
        end else begin
            // **逐漸變亮**
            if (light_mode) begin
                LED[position] <= 1'b1; // 讓當前 LED 變亮
                if (move_mode) 
                    LED[(position+1) & 4'hF] <= 1'b1;
            end 
            // **逐漸變暗**
            else begin
                LED[position] <= 1'b0; // 讓當前 LED 變暗
                if (move_mode) 
                    LED[(position+1) & 4'hF] <= 1'b0; // 确保索引不超界
            end

            // 更新 position
            position <= (position + (move_mode ? 2 : 1)) & 4'hF;

            if(LED==16'b1111_1111_1111_1111||LED==16'b0000_0000_0000_0000) begin
                // **檢查是否完成一輪變化**
                LED = (light_mode) ? 16'b0000_0000_0000_0000 : 16'b1111_1111_1111_1111;
                LED[init_pos] = (light_mode) ? 1'b1 : 1'b0; // 設定初始 LED
              end
           
        end
    end
endmodule
