module Lab1_top ( 
    input clk,
    input  [2:0] X,        
    input  [2:0] Y,        
    input  [1:0] sel,      
    output reg [7:0] LED,  
    output reg [6:0] seg, // 共享 7 段顯示器輸出
    output reg [3:0] an   // 控制哪個顯示器亮起
);

    reg [7:0] result;
    reg [3:0] ones, tens, hundreds;
    reg [15:0] clk_divider; // 用於降低刷新頻率
    reg [1:0] refresh_counter; // 用於多工切換 (0~2)
    
    wire [6:0] seg_hundreds, seg_tens, seg_ones; // 7 段顯示解碼輸出

    // 計算結果
    always @(*) begin
        case (sel)
            2'b00: result = (X << 3) + Y;   // 8X + Y
            2'b01: result = (Y << 4) + X;   // 16Y + X
            2'b10: result = X << Y;         
            2'b11: result = Y >> X;         
            default: result = 8'b00000000;
        endcase
        LED = result; 
        
        // 計算百位、十位、個位
        hundreds = result / 100;
        tens = (result % 100) / 10;
        ones = result % 10;
    end

    // 7 段顯示解碼
    SevenSegDecoder decoder_hundreds (.num(hundreds), .seg(seg_hundreds));
    SevenSegDecoder decoder_tens (.num(tens), .seg(seg_tens));
    SevenSegDecoder decoder_ones (.num(ones), .seg(seg_ones));

    // **時鐘分頻器: 降低掃描速度**
    always @(posedge clk) begin
        clk_divider <= clk_divider + 1;
    end

    // **刷新計數器: 降低顯示更新頻率**
    always @(posedge clk_divider[15]) begin // 50MHz / 2^15 ? 1.5kHz (約 0.7ms)
        refresh_counter <= refresh_counter + 1;
    end

    // **透過多工控制 seg 和 an，並在切換前先熄滅**
    always @(*) begin
        case (refresh_counter)
            2'b00: begin
                seg = 7'b0000000; // 先熄滅，避免殘影
                an = 4'b0100; // 啟用百位數顯示
                seg = seg_hundreds;
            end
            2'b01: begin
                seg = 7'b0000000;
                an = 4'b0010; // 啟用十位數顯示
                seg = seg_tens;
            end
            2'b10: begin
                seg = 7'b0000000;
                an = 4'b0001; // 啟用個位數顯示
                seg = seg_ones;
            end
            default: begin
                an = 4'b0000; // 預設關閉所有顯示器
                seg = 7'b0000000;
            end
        endcase
    end

endmodule

// **7 段顯示解碼模組 (共陰極版本)**
module SevenSegDecoder(
    input  [3:0] num,     
    output reg [6:0] seg  
);
    always @(*) begin
        case (num)
            4'd0: seg = 7'b1111110; // 0
            4'd1: seg = 7'b0110000; // 1
            4'd2: seg = 7'b1101101; // 2
            4'd3: seg = 7'b1111001; // 3
            4'd4: seg = 7'b0110011; // 4
            4'd5: seg = 7'b1011011; // 5
            4'd6: seg = 7'b1011111; // 6
            4'd7: seg = 7'b1110010; // 7
            4'd8: seg = 7'b1111111; // 8
            4'd9: seg = 7'b1111011; // 9
            default: seg = 7'b0000000; // 預設熄滅
        endcase
    end
endmodule
