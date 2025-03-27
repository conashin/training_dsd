module ps2_keyboard_led (
    input wire clk,          // 系統時鐘 100MHz
    input wire ps2_clk,      // PS2 Clock 腳位 K5
    input wire ps2_data,     // PS2 Data  腳位 L4
    output wire [7:0] led    // LED 顯示鍵盤掃描碼
);
    reg [7:0] buffer = 8'd0;
    reg [3:0] count = 0;
    reg ps2_clk_prev = 1'b1;
    reg [7:0] keycode = 8'd0;

    assign led = keycode;

    always @(posedge clk) begin
        ps2_clk_prev <= ps2_clk;

        if (ps2_clk_prev == 1'b1 && ps2_clk == 1'b0) begin  // 偵測 PS2 clock 負緣
            case (count)
                1: buffer[0] <= ps2_data;
                2: buffer[1] <= ps2_data;
                3: buffer[2] <= ps2_data;
                4: buffer[3] <= ps2_data;
                5: buffer[4] <= ps2_data;
                6: buffer[5] <= ps2_data;
                7: buffer[6] <= ps2_data;
                8: buffer[7] <= ps2_data;
                10: keycode <= buffer;  // 完整一筆掃描碼收到
            endcase

            if (count < 10)
                count <= count + 1;
            else
                count <= 0;
        end
    end
endmodule
