`timescale 1ns / 1ps

module VGAExample(
    input clk,             // 外部時脈（100MHz 或 50MHz，依你的板子）
    input rst,             // 重置按鈕
    output hsync, vsync,   // VGA 同步訊號
    output [3:0] vga_r,    // VGA 紅色輸出
    output [3:0] vga_g,    // VGA 綠色輸出
    output [3:0] vga_b     // VGA 藍色輸出
);

wire pclk;                // 25MHz 像素時脈
wire valid;               // 當前像素是否在顯示區
wire [9:0] h_cnt, v_cnt;  // 當前像素的 x, y 座標

// =========================
// Step 1: 產生 25MHz 時脈
// =========================
// 請使用 Vivado 的 Clock Wizard 建立此模組，命名為 dcm_25M
dcm_25M u0 (
    .clk_in1(clk),
    .clk_out1(pclk),
    .reset(rst)
);

// =========================
// Step 2: VGA 時序控制
// =========================
SyncGeneration u1 (
    .pclk(pclk),
    .reset(rst),
    .hSync(hsync),
    .vSync(vsync),
    .dataValid(valid),
    .hDataCnt(h_cnt),
    .vDataCnt(v_cnt)
);

// =========================
// Step 3: 畫紅色方塊
// =========================
reg [3:0] R, G, B;

always @(posedge pclk or posedge rst) begin
    if (rst) begin
        R <= 0; G <= 0; B <= 0;
    end else if (valid) begin
        if ((h_cnt >= 270 && h_cnt < 370) && (v_cnt >= 190 && v_cnt < 290)) begin
            R <= 4'hF;  // 紅色正方形
            G <= 4'h0;
            B <= 4'h0;
        end else begin
            R <= 4'h0; G <= 4'h0; B <= 4'h0; // 黑色背景
        end
    end else begin
        R <= 0; G <= 0; B <= 0;
    end
end

assign vga_r = R;
assign vga_g = G;
assign vga_b = B;

endmodule
