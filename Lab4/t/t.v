module vga_game (
    input clk,           // 100MHz 時脈輸入
    input rst,           // 重置信號
    output hsync,        // VGA 水平同步
    output vsync,        // VGA 垂直同步
    output [3:0] vga_r,  // VGA 紅
    output [3:0] vga_g,  // VGA 綠
    output [3:0] vga_b   // VGA 藍
);

    // === 25 MHz 時脈產生器 ===
    reg [1:0] clk_div = 0;
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
    end
    wire clk_25MHz = clk_div[1];

    // === VGA Timing: 640x480 @ 60Hz ===
    reg [9:0] h_cnt = 0;
    reg [9:0] v_cnt = 0;

    wire h_active = (h_cnt < 640);
    wire v_active = (v_cnt < 480);
    wire video_active = h_active && v_active;

    // VGA 同步訊號（負邏輯）
    assign hsync = ~(h_cnt >= 656 && h_cnt < 752);  // 96 時脈
    assign vsync = ~(v_cnt >= 490 && v_cnt < 492);  // 2 行

    // 掃描計數器
    always @(posedge clk_25MHz or posedge rst) begin
        if (rst) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == 799) begin
                h_cnt <= 0;
                if (v_cnt == 524)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    // 畫面座標
    wire [9:0] x = h_cnt;
    wire [9:0] y = v_cnt;

    // 顯示顏色
    reg [3:0] R, G, B;

    always @(*) begin
        if (!video_active) begin
            R = 0; G = 0; B = 0;
        end else begin
            // 畫格線
            if ((x % 80 < 5) || (y % 80 < 5)) begin
                R = 4'hF; G = 4'hF; B = 4'hF; // 白色格線
            end
            // 烏龜 (0,0) ~ (1,1)
            else if (x < 160 && y < 160) begin
                R = 4'h0; G = 4'hF; B = 4'h0; // 綠色
            end
            // 鎚子1 (3,1)
            else if (x >= 240 && x < 320 && y >= 80 && y < 160) begin
                R = 4'h8; G = 4'h8; B = 4'h8; // 灰色
            end
            // 鎚子2 (6,1)
            else if (x >= 480 && x < 560 && y >= 80 && y < 160) begin
                R = 4'h8; G = 4'h8; B = 4'h8;
            end
            // 香菇 (2,4)
            else if (x >= 160 && x < 240 && y >= 320 && y < 400) begin
                R = 4'hF; G = 4'h0; B = 4'h0; // 紅色
            end
            // eMario (0,4)
            else if (x < 80 && y >= 320 && y < 400) begin
                R = 4'hF; G = 4'h8; B = 4'h0; // 橘色
            end
            // 出口門 (3,0)
            else if (x >= 240 && x < 320 && y < 80) begin
                R = 4'h0; G = 4'h0; B = 4'hF; // 藍色
            end
            // 金幣
            else if (x >= 560 && x < 640 && y >= 400 && y < 480) begin
                R = 4'hF; G = 4'hF; B = 4'h0; // 黃色
            end
            // 其他為背景
            else begin
                R = 4'h0; G = 4'h0; B = 4'h0;
            end
        end
    end

    assign vga_r = R;
    assign vga_g = G;
    assign vga_b = B;

endmodule
