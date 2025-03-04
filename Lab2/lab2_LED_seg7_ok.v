module Top_Module (
    input [7:0] SW,      // 8-bit 控制開關 
    input clk,           // 100MHz FPGA 時鐘
    output [15:0] LED,   // 16 顆 LED
    output reg [6:0] seg, // 7 段顯示器輸出
    output reg [3:0] an   // 控制哪個顯示器亮起
);
    wire slow_clk;       // 慢時鐘 (LED 控制)
    wire fast_clk;       // 快時鐘 (顯示切換)
    wire [3:0] LEDState; // LED 當前位置
    wire [3:0] init_pos; // LED 初始位置
    reg toggle_display;  // 切換顯示模式

    // **時鐘分頻模組**
    Clock_Divider clk_div (
        .clk(clk),
        .speed(SW[1]),
        .slow_clk(slow_clk)
    );

    Clock_Divider_fast fast_clk_div (
        .clk(clk),
        .fast_clk(fast_clk) // 產生較快時鐘
    );

    // **LED 控制模組**
    LED_Controller led_ctrl (
        .SW(SW),
        .clk(slow_clk),  
        .LED(LED),
        .position(LEDState),
        .init_pos(init_pos)
    );

    // **7 段顯示器解碼器**
    wire [6:0] seg1, seg2;
    SevenSegDecoder1 seg_dec1(.num(init_pos), .seg(seg1));
    SevenSegDecoder2 seg_dec2(.num(LEDState), .seg(seg2));

    // **顯示切換邏輯**
    always @(posedge fast_clk) begin
        toggle_display <= ~toggle_display;  // 交替顯示
    end

    always @(*) begin
        if (toggle_display) begin
            seg = seg1; // 顯示初始位置
            an = 4'b0010; // 亮起第一個 7 段顯示器
        end else begin
            seg = seg2; // 顯示當前 LED 位置
            if(SW[0]) begin 
             an = 4'b0000;
            end
            else begin 
             an = 4'b0001;
            end
        end
    end

endmodule

module LED_Controller (
    input [7:0] SW,        
    input clk,            
    output reg [15:0] LED, 
    output reg [3:0] position,  
    output reg [3:0] init_pos
);
    wire move_mode;       
    wire light_mode;      

    assign move_mode = SW[2]; 
    assign light_mode = SW[7]; 

    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin 
            position <= SW[6:3];  
            init_pos <= SW[6:3];  
            LED <= (light_mode) ? 16'b0000_0000_0000_0000 : 16'b1111_1111_1111_1111;
        end else begin
            if (light_mode) begin
                LED[position] <= 1'b1;
                if (move_mode) 
                    LED[(position + 1) & 4'hF] <= 1'b1;
            end else begin
                LED[position] <= 1'b0;
                if (move_mode) 
                    LED[(position + 1) & 4'hF] <= 1'b0;
            end

            position <= (position + (move_mode ? 2 : 1)) & 4'hF;

            if (&LED || ~|LED) begin
                LED = (light_mode) ? 16'b0000_0000_0000_0000 : 16'b1111_1111_1111_1111;
                LED[init_pos] = light_mode ? 1'b1 : 1'b0;
                position = init_pos;
            end
        end
    end
endmodule

module Clock_Divider (
    input clk,            // 100MHz FPGA 時鐘
    input speed,          // 速度選擇 (0: 1Hz, 1: 5Hz)
    output reg slow_clk   // 慢時鐘輸出
);
    reg [31:0] counter;
    wire [31:0] max_count;

    localparam [31:0] MAX_COUNT_1HZ = 100_000_000;
    localparam [31:0] MAX_COUNT_5HZ = 20_000_000;

    assign max_count = (speed) ? MAX_COUNT_5HZ : MAX_COUNT_1HZ;

    initial slow_clk = 0;

    always @(posedge clk) begin
        if (counter >= max_count / 2 - 1) begin
            slow_clk <= ~slow_clk;
            counter  <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
module Clock_Divider_fast (
    input clk,           
    output reg fast_clk  
);
    reg [23:0] counter;  

    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter >= 100_000) begin  // 調整以控制顯示速度
            fast_clk <= ~fast_clk;
            counter <= 0;
        end
    end
endmodule

module SevenSegDecoder1(
    input  [3:0] num,     
    output reg [6:0] seg  
);
    always @(*) begin
        case (num)
            4'd0:  seg = 7'b1111110; // 0
            4'd1:  seg = 7'b0110000; // 1
            4'd2:  seg = 7'b1101101; // 2
            4'd3:  seg = 7'b1111001; // 3
            4'd4:  seg = 7'b0110011; // 4
            4'd5:  seg = 7'b1011011; // 5
            4'd6:  seg = 7'b1011111; // 6
            4'd7:  seg = 7'b1110010; // 7
            4'd8:  seg = 7'b1111111; // 8
            4'd9:  seg = 7'b1111011; // 9
            4'ha:  seg = 7'b1110111; // A
            4'hb:  seg = 7'b0011111; // b
            4'hc:  seg = 7'b1001110; // C
            4'hd:  seg = 7'b0111101; // d
            4'he:  seg = 7'b1001111; // E
            4'hf:  seg = 7'b1000111; // F
            default: seg = 7'b0000000; // 關閉
        endcase
    end
endmodule

module SevenSegDecoder2(
    input  [3:0] num,     
    output reg [6:0] seg  
);
    always @(*) begin
        case (num-1)
            4'd0:  seg = 7'b1111110; // 0
            4'd1:  seg = 7'b0110000; // 1
            4'd2:  seg = 7'b1101101; // 2
            4'd3:  seg = 7'b1111001; // 3
            4'd4:  seg = 7'b0110011; // 4
            4'd5:  seg = 7'b1011011; // 5
            4'd6:  seg = 7'b1011111; // 6
            4'd7:  seg = 7'b1110010; // 7
            4'd8:  seg = 7'b1111111; // 8
            4'd9:  seg = 7'b1111011; // 9
            4'ha:  seg = 7'b1110111; // A
            4'hb:  seg = 7'b0011111; // b
            4'hc:  seg = 7'b1001110; // C
            4'hd:  seg = 7'b0111101; // d
            4'he:  seg = 7'b1001111; // E
            default: seg = 7'b1000111; // F
        endcase
    end
endmodule
