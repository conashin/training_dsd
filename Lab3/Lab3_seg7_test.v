module seg7 (input clk_1khz, // 輸入降解訊號
            input [3:0] DK1,
            input [3:0] DK2,
            input [3:0] DK3,
            input [3:0] DK4,
            output reg [6:0] seg, // gfedcba, output single 7-segment digits signal
            output reg [3:0] an
); 

    reg [1:0] refresh_counter; // 用來控制顯示Digit
    
    wire [6:0] seg_DK1, seg_DK2, seg_DK3, seg_DK4;

    always @(posedge clk_1khz) begin
        refresh_counter <= refresh_counter + 1;
    end

    seg7_digit_decoder decoder1 (
        .in(DK1),
        .seg_out(seg_DK1)
    );

    seg7_digit_decoder decoder2 (
        .in(DK2),
        .seg_out(seg_DK2)
    );

    seg7_digit_decoder decoder3 (
        .in(DK3),
        .seg_out(seg_DK3)
    );

    seg7_digit_decoder decoder4 (
        .in(DK4),
        .seg_out(seg_DK4)
    );

    always @(*) begin
        seg = 7'b0000000; // 預設關閉所有顯示器
        case (refresh_counter)
            2'b00: begin
                seg = 7'b0000000; // 先熄滅，避免殘影
                an = 4'b1000; // 啟用DN0_K1(最左)
                seg = seg_DK1;
            end
            2'b01: begin
                seg = 7'b0000000;
                an = 4'b0100; // 啟用DN0_K2
                seg = seg_DK2;
            end
            2'b10: begin    
                seg = 7'b0000000;
                an = 4'b0010; // 啟用DN0_K3
                seg = seg_DK3;
            end
            2'b11: begin
                seg = 7'b0000000;
                an = 4'b0001; // 啟用DN0_K4(左側4位最右)
                seg = seg_DK4;
            end
        endcase
    end
endmodule
