module ps2_keyboard (
    input               clk,
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

    // --- Clock Buffer ---
    wire ps2clk_bufg; // BUFG 輸出的時鐘
    // 實例化 IBUF
    IBUF ps2clk_ibuf (
        .I(ps2clk),
        .O(ps2clk_bufg_i) // 未直接使用的中間信號
    );

    // 實例化 BUFG
    BUFG ps2clk_bufg_inst (
        .I(ps2clk_bufg_i),
        .O(ps2clk_bufg)
    );


    // --- ASCII Converter ---
    wire [7:0] ascii_char;  // Wire to connect to the converter

    ascii_converter ascii_conv (
        .scan_code(scan_code),
        .shift_pressed(shift_pressed),
        .caps_lock(caps_lock),
        .ascii_char(ascii_char)
    );

    // --- State Machine ---
    always @(negedge ps2clk_bufg or posedge reset) begin
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