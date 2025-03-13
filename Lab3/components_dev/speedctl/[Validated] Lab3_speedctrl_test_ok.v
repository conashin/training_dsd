// Using the Version of Lab3_test.v disabled other modules
module topModule(
    input clk, // FPGA 100MHz Clock
    input rstN, // FPGA Reset Button
    input buttonUp, // Up Button
    input buttonDown, // Down Button
    // input ps2Clk, // PS2 Clock
    // input ps2Data, // PS2 Data

    // output [15:0] LED, // 16 LEDs
    // output [6:0] DN0, // Left 4-digits 7-segment display
    output [6:0] DN1, // Right 4-digits 7-segment display
    // output [3:0] an0, // Left 7-segment display enable
    output [3:0] an1 // Right 7-segment display enable
);

    // 集線區
    wire Clk1kHz; // 1kHz Clock
    wire Clk4Hz; // 1Hz Clock
    // wire [15:0] ps2DataOut; // PS2 Data Out
    wire [3:0] speedCode; // Speed Code
    wire debouncedUp, debouncedDown; // Debounced Up Down Button
    wire [6:0] DK1, DK2, DK3, DK4; // DN0 7-segment display signal
    wire [6:0] DK5, DK6, DK7, DK8; // DN1 7-segment display signal

    assign rst = ~rstN;

    // 模組區
    clkDiv #(
        .TARGET_FREQ(1000) // 1kHz
    )
        div1kHz (
        .clk_in(clk),
        .rst_n(~rst),
        .clk_out(Clk1kHz)
    );
    
    clkDiv #(
        .TARGET_FREQ(4) // 4Hz
    )
        div4Hz (
        .clk_in(clk),
        .rst_n(~rst),
        .clk_out(Clk4Hz)
    );

    /*
    ps2Processing ps2Proc (
        .ps2Clk(ps2Clk),
        .ps2Data(ps2Data),
        .rst(rst),
        .clk(clk),
        .ps2DataOut(ps2DataOut)
    );
    */

    
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

    /*
    ps2HexDisplayforLab3seg7 ps2HexDisplay (
        .ps2Data(ps2DataOut),
        .DK1(DK1),
        .DK2(DK2),
        .DK3(DK3),
        .DK4(DK4)
    );
    */

    speedDisplayforLab3seg7 speedDisplay (
        .speedCode(speedCode),
        .DK1(DK5),
        .DK2(DK6),
        .DK3(DK7),
        .DK4(DK8)
    );

    /*
    seg7 segDisplayLeft (
        .clk_1khz(Clk1kHz),
        .seg_DK1(DK1),
        .seg_DK2(DK2),
        .seg_DK3(DK3),
        .seg_DK4(DK4),
        .seg(DN0),
        .an(an0)
    );
    */

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
    // assign LED = 16'b1111111111111111; // Only for testing

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

    reg [1:0] refresh_counter = 0; // 用來控制顯示Digit
    
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

module ps2Processing( // PS2訊號處理
    input ps2Clk,
    input ps2Data,
    input rst,
    input clk,
    output [15:0] ps2DataOut // {Byte2, Byte1}
);

    // FSM from fsm_ps2
    localparam statWaiting = 0, statDataTrans = 1, statDone = 2;
    localparam START = 0, STOP = 1;
    
    reg nowParity, nextParity; // Parity Verification
    reg [1:0] nowStat, nextStat; // FSM state
    reg [3:0] nowCounter, nextCounter;
    reg [8:0] nowData, nextData;
    reg [15:0] nowBinCode, nextBinCode;
    reg [15:0] nowDisplayBinCode, nextDisplayBinCode;
    reg nowScanCounter, nextScanCounter;

    assign ps2DataOut = nowDisplayBinCode;

    // Initialize and reset
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            nowStat             <= 2'd0;
            nextCounter         <= 4'd0;
            nowData             <= 9'd0;
            nowParity           <= 1'd0;
            nowBinCode          <= 16'd0;
            nowScanCounter      <= 1'd0;
            nowDisplayBinCode   <= 16'd0;
        end
        else begin
            nowStat             <= nextStat;
            nowCounter          <= nextCounter;
            nowData             <= nextData;
            nowParity           <= nextParity;
            nowBinCode          <= nextBinCode;
            nowScanCounter      <= nextScanCounter;
            nowDisplayBinCode   <= nextDisplayBinCode;
        end
    end

    // State flip-flops (sequential)
    always @(posedge ps2Clk) begin
        nextStat            = nowStat;
        nextCounter         = nowCounter;
        nextData            = nowData;
        nextParity          = nowParity;
        nextBinCode         = nowBinCode;
        nextScanCounter     = nowScanCounter;
        nextDisplayBinCode  = nowDisplayBinCode;

        case (nowStat)

            statWaiting: begin
                if (ps2Data == START) begin
                    nextCounter = 4'd9;
                    nextData = 9'd0;
                    nextStat = statDataTrans;
                    if (nowData[7:0] != 8'he0 && nowData[7:0] != 8'hf0) begin
                        nextBinCode = 16'd0;
                    end
                end
            end

            statDataTrans: begin
                // Parity Calculation
                if (nowCounter == 4'd9) begin
                    nextParity = ps2Data;
                end
                else begin
                    nextParity = nowParity ^ ps2Data;
                end

                // Data Collection
                //nextData = (nowData >> 1) | ({ps2Data, {8{1'b0}}});
                nextData = {ps2Data, nowData[8:1]};

                // Check if the data is complete
                if (nowCounter == 4'd1) begin
                    nextStat = statDone;
                end
                else begin
                    nextCounter = nowCounter - 1;
                end
            end

            statDone: begin
                // Display the data
                if (ps2Data == STOP) begin // 檢查PS2_KBDAT是否為STOP
                    // 行奇偶校驗檢查
                    if (nowParity) begin
                        nextBinCode = (nowBinCode << 8) | nowData[7:0]; // Update bin code
                        if (nextScanCounter == 0 || nowData[7:0] == 8'he0 || nowData[7:0] == 8'hf0) begin // 開始新序列&處理特殊掃描碼
                            nextScanCounter = 1; // 計數器歸1
                        end
                        else begin
                            nextDisplayBinCode = nextBinCode; // 更新顯示碼
                            nextScanCounter = 0; // 計數器歸0
                        end
                    end
                    else begin
                        nextDisplayBinCode = 16'hFFFF;
                    end
                    nextStat = statWaiting;
                end
            end
        endcase
    end          
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
    input [15:0] ps2Data,
    output reg [6:0] DK1,
    output reg [6:0] DK2,
    output reg [6:0] DK3,
    output reg [6:0] DK4
); // gfedcba, output single 7-segment digits signal
    
    always @(*) begin
        case (ps2Data)
            16'h2b: begin // Fast
                DK1 = 7'b1110001;
                DK2 = 7'b1110111;
                DK3 = 7'b1101101;
                DK4 = 7'b1111000;
            end
            16'h21: begin// ChUP
                DK1 = 7'b0111001;
                DK2 = 7'b1110100;
                DK3 = 7'b0111110;
                DK4 = 7'b1110011;
            end
            16'h1b: begin // SLID
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