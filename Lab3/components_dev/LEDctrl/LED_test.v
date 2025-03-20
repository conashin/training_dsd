module LEDCtrl(
    input clk, // 2Hz Clock
    input rst, // Reset
    input [3:0] speedCode, // Speed Code
    input [2:0] mode, // Mode
    input pitch, // Pitch
    output reg [15:0] LED // 0-15 from right to left
);
    // Speed list: 120, 125, 130, 135, 140, 145, 150, 155, 160
    // Speed Code:   0,   1,   2,   3,   4,   5,   6,   7,   8

    localparam FASTBALL = 1, CHANGE_UP = 3, SLIDER = 2;

    reg [5:0] Counter; // Use to count the steps
    // reg [31:0] LEDx2; // Use to store the LED status for 2Hz
    reg pitchLock; // 1: lock, 0: unlock
    reg [2:0] lockedMode;
    reg lockedFreq; // 0: 1Hz, 1: 2Hz
    integer k;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Counter <= 0;
            // LEDx2 <= 0;
            LED <= 0;
            pitchLock <= 0;
            lockedMode <= 0;
            lockedFreq <= 0;
        end
        else if (pitch && ~pitchLock) begin // Pitch Pressed and not locked
            // Read the mode and speed code reset the counter
            Counter <= 0;
            // LEDx2 <= 0;
            LED <= 0;
            lockedFreq <= (speedCode < 4) ? 0 : 1;
            lockedMode <= mode;
            pitchLock <= 1;
        end
        else if (pitchLock) begin
            case(lockedMode)
                FASTBALL: begin
                    if (~lockedFreq) begin // 1Hz Condition
                        LED <= 0;
                        k = Counter / 2;
                        LED[k] <= 1;
                        if (Counter == 31) begin
                            pitchLock <= 0;
                        end
                    end
                    else if (lockedFreq) begin // 2Hz Condition
                        LED <= 0;
                        k = Counter;
                        LED[k] <= 1;
                        if (Counter == 15) begin
                            pitchLock <= 0;
                        end
                    end
                end

                SLIDER: begin
                    if (~lockedFreq) begin // 1Hz Condition
                        if (Counter < 16) begin
                            LED <= 0;
                            k = Counter / 2;
                            LED[k] <= 1;
                        end
                        else begin
                            case (Counter)
                                17: begin 
                                    LED <= 0;
                                    LED[9] <= 1;
                                end
                                19: begin 
                                    LED <= 0;
                                    LED[8] <= 1;
                                end
                                21: begin 
                                    LED <= 0;
                                    LED[11] <= 1;
                                end
                                23: begin 
                                    LED <= 0;
                                    LED[10] <= 1;
                                end
                                25: begin 
                                    LED <= 0;
                                    LED[13] <= 1;
                                end
                                27: begin 
                                    LED <= 0;
                                    LED[12] <= 1;
                                end
                                29: begin 
                                    LED <= 0;
                                    LED[15] <= 1;
                                end
                                31: begin 
                                    LED <= 0;
                                    LED[14] <= 1;
                                end
                            endcase
                        end

                        if (Counter == 31) begin
                            pitchLock <= 0;
                        end
                    end

                    else if (lockedFreq) begin // 2Hz Condition
                        if (Counter < 8) begin
                            LED <= 0;
                            k = Counter;
                            LED[k] <= 1;
                        end
                        else begin
                            case (Counter)
                                8: begin 
                                    LED <= 0;
                                    LED[9] <= 1;
                                end
                                9: begin 
                                    LED <= 0;
                                    LED[8] <= 1;
                                end
                                10: begin 
                                    LED <= 0;
                                    LED[11] <= 1;
                                end
                                11: begin 
                                    LED <= 0;
                                    LED[10] <= 1;
                                end
                                12: begin 
                                    LED <= 0;
                                    LED[13] <= 1;
                                end
                                13: begin 
                                    LED <= 0;
                                    LED[12] <= 1;
                                end
                                14: begin 
                                    LED <= 0;
                                    LED[15] <= 1;
                                end
                                15: begin 
                                    LED <= 0;
                                    LED[14] <= 1;
                                end
                            endcase
                        end
                        
                        if (Counter == 15) begin
                            pitchLock <= 0;
                        end
                    end
                end

                CHANGE_UP: begin
                    if (Counter < 16) begin
                        LED <= 0;
                        k = Counter / 2;
                        LED[k] <= 1;
                    end
                    else begin
                        LED <= 0;
                        k = Counter - 8;
                        LED[k] <= 1;
                    end

                    if (Counter == 23) begin
                        pitchLock <= 0;
                    end
                end
            endcase

            Counter <= Counter + 1;
        end
        else begin
            pitchLock <= 0;
            Counter <= 0;
            // LEDx2 <= 0;
            LED <= 0;
        end
    end

endmodule

/*

lockedFreq <= (speed < 4) ? 0 : 1;

FASTBALL

case (mode)
                FASTBALL: begin
                    pitchLock <= 0;
                    lockedMode <= 0;
                    lockedSpeed <= 0;
                end
                SLIDER: begin
                    pitchLock <= 1;
                    lockedMode <= SLIDER;
                    lockedSpeed <= speedCode;
                end
                CHANGE_UP: begin
                    pitchLock <= 1;
                    lockedMode <= CHANGE_UP;
                    lockedSpeed <= speedCode;
                end
                default: begin
                    pitchLock <= 0;
                    lockedMode <= 0;
                    lockedSpeed <= 0;
                end
            endcase

for (integer i = 0; i < 16; i = i + 1) begin
        LED[i] <= Counter[i];
      end
      */
