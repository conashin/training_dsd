// Speed Displaying had been tested on FPGA
module topModule(
    input clk,          // FPGA 100MHz Clock
    input rstN,         // FPGA Reset Button
    input buttonUp,     // Up Button
    input buttonDown,   // Down Button
    // input ps2Clk,       // PS2 Clock
    // input ps2Data,      // PS2 Data
    input buttonMode,   // Mode Button
    input buttonPitch,  // Pitch Button

    output [15:0] LED,  // 16 LEDs
    output [6:0] DN0,   // Left 4-digits 7-segment display
    output [6:0] DN1,   // Right 4-digits 7-segment display
    output [3:0] an0,   // Left 7-segment display enable
    output [3:0] an1    // Right 7-segment display enable
);

    // 集線區
    wire rst;
    // wire error, ascii_valid;            // PS2 Keyboard
    wire Clk1kHz;                       // 1kHz Clock
    wire Clk4Hz;                        // 4Hz Clock
    wire Clk2Hz;                        // 2Hz Clock
    wire Clk1Hz;                        // 1Hz Clock
    // wire [7:0] asciiOut;                // PS2 ASCII Data Out
    wire [1:0] mode;                    // Mode
    wire [3:0] speedCode;               // Speed Code
    wire debouncedUp, debouncedDown, debouncedmode, debouncedpitch;    // Debounced Up Down Button Mode Button
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

    clkDiv #(
        .TARGET_FREQ(2) // 2Hz
    )
        div2Hz (
        .clk_in(clk),
        .rst_n(rstN),
        .clk_out(Clk2Hz)
    );

    clkDiv #(
        .TARGET_FREQ(1) // 1Hz
    )
        div1Hz (
        .clk_in(clk),
        .rst_n(rstN),
        .clk_out(Clk1Hz)
    );

    /*ps2_keyboard ps2Keyboard (
        .ps2clk(ps2Clk),
        .ps2data(ps2Data),
        .reset(rst),
        .ascii_out(asciiOut),
        .ascii_valid(ascii_valid),
        .error(error)
    );*/

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

    keyDebouncing keyDebounceMode (
        .clk(Clk4Hz),
        .rst(rst),
        .keyIn(buttonMode),
        .keyOut(debouncedmode)
    );

    keyDebouncing keyDebouncePitch (
        .clk(clk),
        .rst(rst),
        .keyIn(buttonPitch),
        .keyOut(debouncedpitch)
    );

    speedControl speedCtrl (
        .up(debouncedUp),
        .down(debouncedDown),
        .rst(rst),
        .speedCode(speedCode),
        .clk(Clk4Hz)
    );

    modeSW modeSwitch (
        .clk(Clk4Hz),
        .rst(rst),
        .button(debouncedmode),
        .mode(mode)
    );

    modeDisplayForLab3seg7 modeDisplay (
        .mode(mode),
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

    LED_Controller LEDCtrl (
        .clk(clk),
        .rst(rst),
        .speed(speedCode),
        .mode(mode),
        .clk_1hz(Clk1Hz),
        .clk_2hz(Clk2Hz),
        .LED(LED)
    );

endmodule

// Lab3 Only Function Zone
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

module modeSW(
    input clk,
    input rst,
    input button, // S2
    output reg [1:0] mode
);
    localparam FASTBALL = 0, CHANGE_UP = 2, SLIDER = 1;

    reg button_prev;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode <= FASTBALL;
            button_prev <= 0;
        end
        else begin
            button_prev <= button;
            if (button && !button_prev) begin // Only change mode on button press (rising edge)
                case(mode)
                    FASTBALL:   mode <= SLIDER;
                    SLIDER:     mode <= CHANGE_UP;
                    CHANGE_UP:  mode <= FASTBALL;
                    default:    mode <= FASTBALL;
                endcase
            end
        end
    end
endmodule
