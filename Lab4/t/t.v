module vga_game (
    input clk,
    input rst,
    output hsync,
    output vsync,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b
);

    // VGA timing 640x480 @ 60Hz
    reg [9:0] h_cnt = 0;
    reg [9:0] v_cnt = 0;

    wire h_active = (h_cnt < 640);
    wire v_active = (v_cnt < 480);
    wire video_active = h_active && v_active;

    // VGA sync timing
    assign hsync = ~(h_cnt >= 656 && h_cnt < 752);
    assign vsync = ~(v_cnt >= 490 && v_cnt < 492);

    // clock 25 MHz generation from 50 MHz or 100 MHz 需外部提供
    always @(posedge clk or posedge rst) begin
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

    // 畫面內容定義
    wire [9:0] x = h_cnt;
    wire [9:0] y = v_cnt;

    // 預設背景顏色為黑
    reg [3:0] R = 0, G = 0, B = 0;

    always @(*) begin
        if (!video_active) begin
            R = 0; G = 0; B = 0;
        end else begin
            // 畫格線
            if ((x % 80 < 5) || (y % 80 < 5)) begin
                R = 4'hF; G = 4'hF; B = 4'hF; // 白色格線
            end
            // 烏龜 (0,0) ~ (1,1)
            else if (x >= 0   && x < 160 && y >= 0   && y < 160) begin
                R = 4'h0; G = 4'hF; B = 4'h0; // 綠色
            end
            // 鎚子1 (3,1)
            else if (x >= 240 && x < 320 && y >= 80  && y < 160) begin
                R = 4'h8; G = 4'h8; B = 4'h8; // 灰色
            end
            // 鎚子2 (6,1)
            else if (x >= 480 && x < 560 && y >= 80  && y < 160) begin
                R = 4'h8; G = 4'h8; B = 4'h8;
            end
            // 香菇 (2,4)
            else if (x >= 160 && x < 240 && y >= 320 && y < 400) begin
                R = 4'hF; G = 4'h0; B = 4'h0; // 紅色
            end
            // eMario (0,4)
            else if (x >= 0   && x < 80  && y >= 320 && y < 400) begin
                R = 4'hF; G = 4'h8; B = 4'h0; // 橘色
            end
            // 出口門 (3,0)
            else if (x >= 240 && x < 320 && y >= 0   && y < 80) begin
                R = 4'h0; G = 4'h0; B = 4'hF; // 藍色
            end
            // 金幣（任意放）
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
