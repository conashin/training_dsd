// Speed Displaying had been tested on FPGA
module topModule(
    input clk,          // FPGA 100MHz Clock
    input rstN,         // FPGA Reset Button
    input buttonUp,     // Up Button
    input buttonDown,   // Down Button
    input ps2Clk,       // PS2 Clock
    input ps2Data,      // PS2 Data

    output [15:0] LED,  // 16 LEDs
    output [6:0] DN0,   // Left 4-digits 7-segment display
    output [6:0] DN1,   // Right 4-digits 7-segment display
    output [3:0] an0,   // Left 7-segment display enable
    output [3:0] an1    // Right 7-segment display enable
);

    // 集線區
    wire rst;
    wire error, ascii_valid;            // PS2 Keyboard
    wire Clk1kHz;                       // 1kHz Clock
    wire Clk4Hz;                        // 1Hz Clock
    wire [7:0] asciiOut;                // PS2 ASCII Data Out
    wire [3:0] speedCode;               // Speed Code
    wire debouncedUp, debouncedDown;    // Debounced Up Down Button
    wire [6:0] DK1, DK2, DK3, DK4;      // DN0 7-segment display signal
    wire [6:0] DK5, DK6, DK7, DK8;      // DN1 7-segment display signal

    assign rst = ~rstN;

    // 模組區
    clkDiv #(
        .TARGET_FREQ(1000) // 1kHz
    )
        div1kHz (
        .clk_in(clk),
        .rst_n(rstN),
        .clk_out(Clk1kHz)
    );
    
    clkDiv #(
        .TARGET_FREQ(4) // 4Hz
    )
        div4Hz (
        .clk_in(clk),
        .rst_n(rstN),
        .clk_out(Clk4Hz)
    );

    ps2_keyboard ps2Keyboard (
        .ps2clk(ps2Clk),
        .ps2data(ps2Data),
        .reset(rst),
        .ascii_out(asciiOut),
        .ascii_valid(),
        .error()
    );

    keyDebouncing keyDebounceUp (
        .clk(clk),
        .rst(rst),
        .keyIn(buttonUp),
        .keyOut(debouncedUp)
    );

    keyDebouncing keyDebounceDown (
        .clk(clk),
        .rst(rst),
        .keyIn(buttonDown),
        .keyOut(debouncedDown)
    );

    speedControl speedCtrl (
        .up(debouncedUp),
        .down(debouncedDown),
        .rst(rst),
        .speedCode(speedCode),
        .clk(Clk4Hz)
    );

    ps2HexDisplayforLab3seg7 ps2HexDisplay (
        .ps2Data(asciiOut),
        .DK1(DK1),
        .DK2(DK2),
        .DK3(DK3),
        .DK4(DK4)
    );

    speedDisplayforLab3seg7 speedDisplay (
        .speedCode(speedCode),
        .DK1(DK5),
        .DK2(DK6),
        .DK3(DK7),
        .DK4(DK8)
    );

    seg7 segDisplayLeft (
        .clk_1khz(Clk1kHz),
        .seg_DK1(DK1),
        .seg_DK2(DK2),
        .seg_DK3(DK3),
        .seg_DK4(DK4),
        .seg(DN0),
        .an(an0)
    );

    seg7 segDisplayRight (
        .clk_1khz(Clk1kHz),
        .seg_DK1(DK5),
        .seg_DK2(DK6),
        .seg_DK3(DK7),
        .seg_DK4(DK8),
        .seg(DN1),
        .an(an1)
    );

    // LED
    assign LED = 16'b1111111111111111; // Only for testing

endmodule

// Clock 訊號處理
module clkDiv #(
    parameter INPUT_FREQ = 100_000_000, // Input clock frequency (default: 100MHz)
    parameter TARGET_FREQ = 1              // Target output clock frequency (default: 1Hz)
) (
    input clk_in,
    input rst_n,
    output reg clk_out = 0
);

    // Calculate the divider value.  We divide by 2 * target hz because we toggle
    // clk_out, effectively creating a 50% duty cycle.
    localparam divParm = INPUT_FREQ / (2 * TARGET_FREQ);

    // Determine the required counter width (number of bits)
    localparam COUNTER_WIDTH = $clog2(divParm);

    reg [COUNTER_WIDTH-1:0] counter = 0;


    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == divParm - 1) begin
                counter <= 0;
                clk_out <= ~clk_out; // Toggle clk_out
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule

// 主邏輯功能區塊
module speedControl(
    input clk,  
    input up,
    input down,
    input rst,
    output reg [3:0] speedCode
);
    // Speed list: 120, 125, 130, 135, 140, 145, 150, 155, 160
    // Speed Code:   0,   1,   2,   3,   4,   5,   6,   7,   8
    always @(posedge clk or posedge rst) begin // triggerd by clk rst
        if (rst) 
            speedCode <= 4'd3; // 135
        else if (down)
            speedCode <= (speedCode == 4'd0) ? 4'd0 : speedCode - 1;
        else if (up)
            speedCode <= (speedCode == 4'd8) ? 4'd8 : speedCode + 1;
    end
endmodule

// 訊號處理區塊
module seg7 (
    input clk_1khz, // 輸入降解訊號
    input [6:0] seg_DK1,
    input [6:0] seg_DK2,
    input [6:0] seg_DK3,
    input [6:0] seg_DK4,
    output reg [6:0] seg, // gfedcba, output single 7-segment digits signal
    output reg [3:0] an
); 

    reg [1:0] refresh_counter; // 用來控制顯示Digit
    
    always @(posedge clk_1khz) begin
        refresh_counter <= refresh_counter + 1;
    end

    /* wire [6:0] seg_DK1, seg_DK2, seg_DK3, seg_DK4;
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
    */


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

module ps2_keyboard (
    input               ps2clk,
    input               ps2data,
    input               reset,
    output reg [7:0]    ascii_out,
    output reg          ascii_valid,
    output reg          error
);

    // --- Constants ---
    localparam  IDLE        = 4'b0001,      // 等待狀態
                START_BIT   = 4'b0010,      // 開始位元
                DATA_BITS   = 4'b0100,      // 資料位元
                PARITY_BIT  = 4'b1000,      // 奇偶校驗位元
                STOP_BIT    = 4'b1001;      // 結束位元

    // --- PS/2 Receiver Register---
    reg [3:0]   state           = IDLE;     // State machine 狀態
    reg [3:0]   bitCounter      = 0;        // 計數器
    reg [10:0]  shift_reg       = 0;        // 已掃描碼暫存器 
    reg         parity_check    = 0;        // 奇偶校驗
    reg [7:0]   scan_code;                  // 掃描碼
    reg         is_break_code   = 0;        // 是否為中斷碼
    reg [7:0]   prev_scan_code  = 0;        // 上一個掃描碼

    // --- Key State Tracking ---
    reg shift_pressed   = 0;                // Shift 鍵是否被按下
    reg caps_lock       = 0;                // Caps Lock 鍵是否被按下
    reg caps_toggled    = 0;                // Caps Lock 鍵是否被切換

    // --- ASCII Converter ---
    wire [7:0] ascii_char;  // Wire to connect to the converter

    ascii_converter ascii_conv (
        .scan_code(scan_code),
        .shift_pressed(shift_pressed),
        .caps_lock(caps_lock),
        .ascii_char(ascii_char)
    );

    // --- State Machine ---
    always @(negedge ps2clk or posedge reset) begin
        if (reset) begin
            // 重設所有變數，進入 IDLE 狀態
            state           <= IDLE;
            bitCounter      <= 0;
            shift_reg       <= 0;
            parity_check    <= 0;
            ascii_out       <= 0;
            ascii_valid     <= 0;
            error           <= 0;
            scan_code       <= 0;
            is_break_code   <= 0;
            prev_scan_code  <= 0;
            shift_pressed   <= 0;
            caps_lock       <= 0;
            caps_toggled    <= 0;
        end 
        else begin
            case (state)
                // --- 等待輸入 ---
                IDLE: begin
                    ascii_valid <= 0;
                    error       <= 0;
                    if (ps2data == 0) begin
                        state           <= START_BIT;
                        bitCounter      <= 0;
                        shift_reg       <= 0;
                        parity_check    <= 1; // Odd parity initialization
                    end
                end

                // --- 開始位元 ---
                START_BIT: begin
                    state <= DATA_BITS;
                end

                // --- 抓取資料 ---
                DATA_BITS: begin
                    bitCounter              <= bitCounter + 1;              // 計數器加一
                    shift_reg[bitCounter]   <= ps2data;                     // 把資料存入暫存器
                    parity_check            <= parity_check ^ ps2data;      // 動態更新奇偶較驗(資料位元中1的總數，加上奇偶校驗位應該是奇數)
                    if (bitCounter == 7) begin
                        state <= PARITY_BIT;                                // 位元抓取完畢，進入奇偶校驗
                    end
                end

                // --- 奇偶校驗 ---
                PARITY_BIT: begin
                    if (parity_check == ps2data) begin
                        state <= STOP_BIT;                                  // 奇偶校驗正確，進入結束位元
                    end else begin
                        state <= IDLE;
                        error <= 1;                                         // 奇偶校驗錯誤，回到等待狀態
                    end
                end

                // --- 結束位元 ---
                STOP_BIT: begin
                    if (ps2data == 1) begin             // 確定結束位元
                        state       <= IDLE;            // 回到等待狀態
                        scan_code   <= shift_reg[8:1];  // 儲存掃描碼

                        // --- 按鍵動作檢查及處理 ---
                        if (shift_reg[8:1] == 8'hF0) begin
                            is_break_code <= 1;         // 偵測到中斷碼
                        end 
                        else if (shift_reg[8:1] == 8'hE0) begin
                            // 未實作牙~                 // 偵測到功能按鍵
                        end 
                        else begin
                            if (is_break_code) begin
                                case (shift_reg[8:1])
                                    8'h12, 8'h59: shift_pressed <= 0;   // 左/右 Shift 鍵釋放
                                endcase
                            end 
                            else begin                                              // 按鍵按下事件
                                case (shift_reg[8:1])           
                                    8'h12, 8'h59: shift_pressed <= 1;               // 左/右 Shift 鍵按下
                                    8'h58: begin                                    // Caps Lock 鍵處理
                                        if (!caps_toggled) begin            
                                            caps_lock   <= ~caps_lock;              // 切換大小寫狀態
                                            caps_toggled<= 1;                       // 標記已切換，防止重複觸發
                                        end
                                    end
                                    default: begin
                                        if(prev_scan_code != 8'hE0) begin           // 確認不是擴展按鍵序列
                                            ascii_out   <= ascii_char;              // 設定ASCII輸出
                                            ascii_valid <= (ascii_char != 8'h00);   // 確認ASCII碼有效
                                        end
                                    end
                                endcase
                                caps_toggled <= 0;                                  // 重置Caps Lock切換標記
                            end         
                            is_break_code <= 0;                                     // 重置斷碼標記

                        end
                        prev_scan_code <= shift_reg[8:1];

                    end 
                    else begin // 結束位元錯誤
                        state <= IDLE;
                        error <= 1; // Stop bit error
                    end
                end
            endcase
        end
    end

endmodule

module ascii_converter (
    input  [7:0] scan_code,         // 掃描碼
    input        shift_pressed,     // Shift 鍵是否被按下
    input        caps_lock,         // Caps Lock 鍵是否被按下
    output [7:0] ascii_char         // 輸出ASCII 字元
);

    function [7:0] scan_code_to_ascii;
        input [7:0] scan_code;
        input       shift_pressed;
        input       caps_lock;
        reg [7:0]   ascii_char_func;  // 內部變數，避免與模組輸出衝突
        begin
            ascii_char_func = 8'h00; // Default: no character

            case (scan_code)
                // --- Numbers (with Shift) ---
                8'h16: ascii_char_func = shift_pressed ? "!" : "1";
                8'h1E: ascii_char_func = shift_pressed ? "@" : "2";
                8'h26: ascii_char_func = shift_pressed ? "#" : "3";
                8'h25: ascii_char_func = shift_pressed ? "$" : "4";
                8'h2E: ascii_char_func = shift_pressed ? "%" : "5";
                8'h36: ascii_char_func = shift_pressed ? "^" : "6";
                8'h3D: ascii_char_func = shift_pressed ? "&" : "7";
                8'h3E: ascii_char_func = shift_pressed ? "*" : "8";
                8'h46: ascii_char_func = shift_pressed ? "(" : "9";
                8'h45: ascii_char_func = shift_pressed ? ")" : "0";

                // --- Letters (with Shift and Caps Lock) ---
                8'h1C: ascii_char_func = (shift_pressed ^ caps_lock) ? "A" : "a";
                8'h32: ascii_char_func = (shift_pressed ^ caps_lock) ? "B" : "b";
                8'h21: ascii_char_func = (shift_pressed ^ caps_lock) ? "C" : "c";
                8'h23: ascii_char_func = (shift_pressed ^ caps_lock) ? "D" : "d";
                8'h24: ascii_char_func = (shift_pressed ^ caps_lock) ? "E" : "e";
                8'h2B: ascii_char_func = (shift_pressed ^ caps_lock) ? "F" : "f";
                8'h34: ascii_char_func = (shift_pressed ^ caps_lock) ? "G" : "g";
                8'h33: ascii_char_func = (shift_pressed ^ caps_lock) ? "H" : "h";
                8'h43: ascii_char_func = (shift_pressed ^ caps_lock) ? "I" : "i";
                8'h3B: ascii_char_func = (shift_pressed ^ caps_lock) ? "J" : "j";
                8'h42: ascii_char_func = (shift_pressed ^ caps_lock) ? "K" : "k";
                8'h4B: ascii_char_func = (shift_pressed ^ caps_lock) ? "L" : "l";
                8'h3A: ascii_char_func = (shift_pressed ^ caps_lock) ? "M" : "m";
                8'h31: ascii_char_func = (shift_pressed ^ caps_lock) ? "N" : "n";
                8'h44: ascii_char_func = (shift_pressed ^ caps_lock) ? "O" : "o";
                8'h4D: ascii_char_func = (shift_pressed ^ caps_lock) ? "P" : "p";
                8'h15: ascii_char_func = (shift_pressed ^ caps_lock) ? "Q" : "q";
                8'h2D: ascii_char_func = (shift_pressed ^ caps_lock) ? "R" : "r";
                8'h1B: ascii_char_func = (shift_pressed ^ caps_lock) ? "S" : "s";
                8'h2C: ascii_char_func = (shift_pressed ^ caps_lock) ? "T" : "t";
                8'h3C: ascii_char_func = (shift_pressed ^ caps_lock) ? "U" : "u";
                8'h2A: ascii_char_func = (shift_pressed ^ caps_lock) ? "V" : "v";
                8'h1D: ascii_char_func = (shift_pressed ^ caps_lock) ? "W" : "w";
                8'h22: ascii_char_func = (shift_pressed ^ caps_lock) ? "X" : "x";
                8'h35: ascii_char_func = (shift_pressed ^ caps_lock) ? "Y" : "y";
                8'h1A: ascii_char_func = (shift_pressed ^ caps_lock) ? "Z" : "z";

                // --- Special Characters (with Shift) ---
                8'h4E: ascii_char_func = shift_pressed ? "_" : "-";
                8'h55: ascii_char_func = shift_pressed ? "+" : "=";
                8'h5D: ascii_char_func = shift_pressed ? "}" : "]";
                8'h54: ascii_char_func = shift_pressed ? "{" : "[";
                8'h4C: ascii_char_func = shift_pressed ? ":" : ";";
                8'h52: ascii_char_func = shift_pressed ? "\"" : "'";
                8'h5B: ascii_char_func = shift_pressed ? "<" : ",";
                8'h41: ascii_char_func = shift_pressed ? "~" : "`";
                8'h4A: ascii_char_func = shift_pressed ? "?" : "/";
                8'h5A: ascii_char_func = 8'h0D; // Enter (Carriage Return)
                8'h66: ascii_char_func = 8'h08; // Backspace
                8'h29: ascii_char_func = " ";    // Space
                8'h0E: ascii_char_func = 8'h09; // TAB
                8'h5C: ascii_char_func = shift_pressed ? "|" : "\\";
                8'h49: ascii_char_func = shift_pressed ? ">" : ".";
                default: ascii_char_func = 8'h00;
            endcase

            scan_code_to_ascii = ascii_char_func;
        end
    endfunction

    assign ascii_char = scan_code_to_ascii(scan_code, shift_pressed, caps_lock);

endmodule

module keyDebouncing( // 按鍵消彈
    input clk,
    input rst,
    input keyIn,
    output reg keyOut
);
    
    localparam samplingNum = 4; // Smapling Number
    localparam SET         = 4'b0000; // Set
    localparam RESET       = 4'b1111; // Reset State
    
    reg [samplingNum - 1:0] keyInReg = RESET;
    
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            keyInReg <= RESET; // Reset
        end
        else begin
            keyInReg[0] <= keyIn;
            for(i = 0; i< samplingNum - 1; i = i+1)
                keyInReg[i+1] <= keyInReg[i];
        end
        case(keyInReg)
            SET:        keyOut <= 1'b0;
            default:    keyOut <= 1'b1;
        endcase
    end
endmodule

// 訊號解碼區塊
module ps2HexDisplayforLab3seg7( // 鍵盤訊號轉譯為7-segment顯示訊號
    input [7:0] ps2Data,
    output reg [6:0] DK1,
    output reg [6:0] DK2,
    output reg [6:0] DK3,
    output reg [6:0] DK4
); // gfedcba, output single 7-segment digits signal
    
    always @(*) begin
        case (ps2Data)
            "f": begin // Fast
                DK1 = 7'b1110001;
                DK2 = 7'b1110111;
                DK3 = 7'b1101101;
                DK4 = 7'b1111000;
            end
            "c": begin// ChUP
                DK1 = 7'b0111001;
                DK2 = 7'b1110100;
                DK3 = 7'b0111110;
                DK4 = 7'b1110011;
            end
            "s": begin // SLID
                DK1 = 7'b1101101;
                DK2 = 7'b0111000;
                DK3 = 7'b0000110;
                DK4 = 7'b1011110;
            end
        endcase
    end
endmodule

module speedDisplayforLab3seg7( // 速度訊號轉譯為7-segment顯示訊號
    input [3:0] speedCode,
    output reg [6:0] DK1,
    output reg [6:0] DK2,
    output reg [6:0] DK3,
    output reg [6:0] DK4
);

    localparam SEG_0     = 7'b0111111; // "0" (g=1, f=1, e=1, d=1, c=1, b=1, a=1)
    localparam SEG_1     = 7'b0000110; // "1" (g=0, f=0, e=0, d=0, c=1, b=1, a=0)
    localparam SEG_2     = 7'b1011011; // "2" (g=1, f=0, e=1, d=1, c=0, b=1, a=1)
    localparam SEG_3     = 7'b1001111; // "3" (g=1, f=0, e=0, d=1, c=1, b=1, a=1)
    localparam SEG_4     = 7'b1100110; // "4" (g=1, f=1, e=0, d=0, c=1, b=1, a=0)
    localparam SEG_5     = 7'b1101101; // "5" (g=1, f=1, e=0, d=1, c=1, b=0, a=1)
    localparam SEG_6     = 7'b1111101; // "6" (g=1, f=1, e=1, d=1, c=1, b=0, a=1)
    localparam SEG_7     = 7'b0000111; // "7" (g=0, f=0, e=0, d=0, c=1, b=1, a=1)
    localparam SEG_8     = 7'b1111111; // "8" (g=1, f=1, e=1, d=1, c=1, b=1, a=1)
    localparam SEG_9     = 7'b1101111; // "9" (g=1, f=1, e=0, d=1, c=1, b=1, a=1)
    localparam SEG_BLANK = 7'b0000000; // All OFF (g=0, f=0, e=0, d=0, c=0, b=0, a=0)

    always @(*) begin
        case (speedCode)
            4'b0: begin // 0120
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_2;
                DK4 = SEG_0;
            end
            4'h1: begin// 0125
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_2;
                DK4 = SEG_5;
            end
            4'h2: begin // 0130
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_3;
                DK4 = SEG_0;
            end
            4'h3: begin// 0135
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_3;
                DK4 = SEG_5;
            end
            4'h4: begin // 0140
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_4;
                DK4 = SEG_0;
            end
            4'h5: begin// 0145
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_4;
                DK4 = SEG_5;
            end
            4'h6: begin // 0150
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_5;
                DK4 = SEG_0;
            end
            4'h7: begin// 0155
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_5;
                DK4 = SEG_5;
            end
            4'h8: begin // 0160
                DK1 = SEG_BLANK;
                DK2 = SEG_1;
                DK3 = SEG_6;
                DK4 = SEG_0;
            end  
        endcase
    end
endmodule