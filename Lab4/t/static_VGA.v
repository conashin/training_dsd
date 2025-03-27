module vga_game (
    input clk,           // 100MHz 時脈輸入
    input rst,           // 重置信號
    output hsync,        // VGA 水平同步
    output vsync,        // VGA 垂直同步
    output [3:0] vga_r,  // VGA 紅
    output [3:0] vga_g,  // VGA 綠
    output [3:0] vga_b   // VGA 藍
);

    // === Clock divider: 100MHz -> ~25MHz ===
    reg [1:0] clk_div = 0;
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
    end
    wire clk_25mhz = clk_div[1];

    // === VGA timing constants ===
    localparam H_ACTIVE = 640;
    localparam H_FRONT  = 16;
    localparam H_SYNC   = 96;
    localparam H_BACK   = 48;
    localparam H_TOTAL  = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;

    localparam V_ACTIVE = 480;
    localparam V_FRONT  = 10;
    localparam V_SYNC   = 2;
    localparam V_BACK   = 33;
    localparam V_TOTAL  = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

    // === Timing counters ===
    reg [9:0] h_cnt = 0;
    reg [9:0] v_cnt = 0;

    wire video_active = (h_cnt < H_ACTIVE) && (v_cnt < V_ACTIVE);
    wire [9:0] x = h_cnt;
    wire [9:0] y = v_cnt;

    // === Sync generator ===
    always @(posedge clk_25mhz or posedge rst) begin
        if (rst) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL - 1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    assign hsync = ~(h_cnt >= (H_ACTIVE + H_FRONT) &&
                     h_cnt <  (H_ACTIVE + H_FRONT + H_SYNC));
    assign vsync = ~(v_cnt >= (V_ACTIVE + V_FRONT) &&
                     v_cnt <  (V_ACTIVE + V_FRONT + V_SYNC));

    // === Pixel color output ===
    reg [3:0] R, G, B;

    always @(*) begin
        if (!video_active) begin
            R = 0; G = 0; B = 0;
        end else begin
            if ((x % 80 < 5) || (y % 80 < 5)) begin
                R = 4'hF; G = 4'hF; B = 4'hF; // 格線
            end
            else if (x < 160 && y < 160) begin
                R = 4'h0; G = 4'hF; B = 4'h0; // 烏龜
            end
            else if (x >= 240 && x < 320 && y >= 80 && y < 160) begin
                R = 4'h8; G = 4'h8; B = 4'h8; // 鎚子1
            end
            else if (x >= 480 && x < 560 && y >= 80 && y < 160) begin
                R = 4'h8; G = 4'h8; B = 4'h8; // 鎚子2
            end
            else if (x >= 160 && x < 240 && y >= 320 && y < 400) begin
                R = 4'hF; G = 4'h0; B = 4'h0; // 香菇
            end
            else if (x < 80 && y >= 320 && y < 400) begin
                R = 4'hF; G = 4'h8; B = 4'h0; // Mario
            end
            else if (x >= 240 && x < 320 && y < 80) begin
                R = 4'h0; G = 4'h0; B = 4'hF; // 出口門
            end
            else if (x >= 560 && x < 640 && y >= 400 && y < 480) begin
                R = 4'hF; G = 4'hF; B = 4'h0; // 金幣
            end
            else begin
                R = 4'h0; G = 4'h0; B = 4'h0; // 背景
            end
        end
    end

    assign vga_r = R;
    assign vga_g = G;
    assign vga_b = B;

endmodule
