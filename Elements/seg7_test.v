
module seg7_display (
    input clk,                  // 系統時脈（100MHz）
    input rst,                  // 同步 reset（高有效）
    input [9:0] score,          // 外部輸入分數（0~999）
    output reg [2:0] Enable,    // 3 位顯示器
    output reg [7:0] SevenSeg
);

    reg [25:0] clkdiv;
    reg [1:0] scan_sel;

    // 時脈除頻器
    always @(posedge clk) begin
        if (rst)
            clkdiv <= 0;
        else
            clkdiv <= clkdiv + 1;
    end

    // 掃描選擇器（快速掃描）
    always @(posedge clkdiv[10]) begin
        if (rst)
            scan_sel <= 0;
        else
            scan_sel <= (scan_sel == 2'd2) ? 0 : scan_sel + 1;
    end

    // 數字拆解
    reg [3:0] digits[2:0];
    always @(*) begin
        digits[2] = score / 100;
        digits[1] = (score / 10) % 10;
        digits[0] = score % 10;
    end

    // 七段譯碼器（gfedcba.dp）
    function [7:0] seg_encode;
        input [3:0] digit;
        case (digit)
            4'd0: seg_encode = 8'b00111111;
            4'd1: seg_encode = 8'b00000110;
            4'd2: seg_encode = 8'b01011011;
            4'd3: seg_encode = 8'b01001111;
            4'd4: seg_encode = 8'b01100110;
            4'd5: seg_encode = 8'b01101101;
            4'd6: seg_encode = 8'b01111101;
            4'd7: seg_encode = 8'b00000111;
            4'd8: seg_encode = 8'b01111111;
            4'd9: seg_encode = 8'b01101111;
            default: seg_encode = 8'b00000000;
        endcase
    endfunction

    // 顯示輸出
    always @(*) begin
        if (rst) begin
            SevenSeg = seg_encode(4'd0);
            Enable = 3'b001;
        end else begin
            SevenSeg = seg_encode(digits[scan_sel]);
            Enable = 3'b000;
            Enable[scan_sel] = 1'b1;
        end
    end

endmodule
