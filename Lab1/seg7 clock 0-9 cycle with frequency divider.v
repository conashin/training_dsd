module seg7_counter (
    input wire clk,      // FPGA 時脈 (100MHz)
    input wire reset,    // 重置按鈕
    output reg [6:0] seg, // 7 段顯示器 (gfedcba)
    output reg [3:0] an   // 數碼管選擇
);

    reg [3:0] counter = 0;      // 計數器 (0-9)
    reg [26:0] clk_div = 0;     // 降頻計數器 (適用 100MHz FPGA)

    // 降頻計數器 (讓數字每 1 秒變化一次)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 0;
            counter <= 0;
        end else begin
            clk_div <= clk_div + 1;
            if (clk_div == 100_000_000) begin // 100MHz -> 1Hz
                clk_div <= 0;
                counter <= (counter == 9) ? 0 : counter + 1;
            end
        end
    end

    // 7 段顯示器字形 (gfedcba)
    always @(*) begin
        case (counter)
            4'd0: seg = 7'b1111110;
            4'd1: seg = 7'b0110000;
            4'd2: seg = 7'b1101101;
            4'd3: seg = 7'b1111001;
            4'd4: seg = 7'b0110011;
            4'd5: seg = 7'b1011011;
            4'd6: seg = 7'b1011111;
            4'd7: seg = 7'b1110010;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1111011;
            default: seg = 7'b0000000; // 預設熄滅
        endcase
    end

    // 選擇數碼管 (顯示於第 1 個數碼管)
    always @(*) begin
        an = 4'b0001; // 只開啟第一個數碼管
    end

endmodule
