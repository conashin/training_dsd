// This is a demo code that show the key pressed on the keyboad on the 7-segment display

module keyDebouncing(input clk,
                     input rst,
                     input keyIn,
                     output reg keyOut);
    
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

module ps2Processing(
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
