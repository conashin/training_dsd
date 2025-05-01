module death_led (
    input clk,             // 建議使用 100MHz 時脈
    input dead,            // eMario 死亡旗標
    output reg [15:0] led  // LED 輸出
);

    reg [25:0] counter = 0;
    reg pattern = 0; // 用來切換兩種圖案

    always @(posedge clk) begin
        if (dead) begin
            if (counter >= 26'd50_000_000) begin // 每 0.5 秒切換一次
                counter <= 0;
                pattern <= ~pattern;
            end else begin
                counter <= counter + 1;
            end
        end else begin
            counter <= 0;
            pattern <= 0;
        end
    end

    always @(*) begin
        if (dead)
            led = pattern ? 16'b0101010101010101 : 16'b1010101010101010;
        else
            led = 16'b0;
    end
endmodule
