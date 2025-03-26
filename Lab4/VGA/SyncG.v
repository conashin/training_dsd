module syncGeneration(
    input pclk,
    input rst,
    output hSync,
    output vSync,
    output dataValid,
    output [9:0] hDatCnt,
    output [9:0] vDatCnt
);
    parameter False = 0, True = 1;
    
    // Horizontal Timing
    parameter H_SP_END = 96;    // Sync Pulse end time
    parameter H_BP_END = 144;   // Back Porch end time
    parameter H_FP_START = 785; // Front Porch start time (Display End)
    parameter H_TOTAL = 800;    // Total time

    // Vertical Timing
    parameter V_SP_END = 2;     // Sync Pulse end time
    parameter V_BP_END = 35;    // Back Porch end time
    parameter V_FP_START = 516; // Front Porch start time (Display End)
    parameter V_TOTAL = 525;    // Total time 


    reg [9:0] hCnt, vCnt;
    wire hValid, vValid;

    // Sync signals
    assign hSync = (hCnt > H_SP_END) ? True : False;
    assign vSync = (vCnt > V_SP_END) ? True : False;
    // Ensure that the data is only valid during the display period
    assign hValid = (hCnt > H_BP_END && hCnt < H_FP_START) ? True : False;
    assign vValid = (vCnt > V_BP_END && vCnt < V_FP_START) ? True : False;
    // Data is valid only when both horizontal and vertical data is valid
    assign dataValid = hValid && vValid;
    // Data counters
    assign hDatCnt = hValid ? hCnt - H_BP_END : 0;
    assign vDatCnt = vValid ? vCnt - V_BP_END : 0;


    always @(posedge pclk or posedge rst) begin
        if (rst)
            hCnt <= 0;
        else if (hCnt == H_TOTAL)
            hCnt <= 0;
        else
            hCnt <= hCnt + 1;
    end

    always @(posedge pclk or posedge rst) begin
        if (rst)
            vCnt <= 0;
        else if (vCnt == V_TOTAL & hCnt == H_TOTAL)
            vCnt <= 0;
        else if (hCnt == H_TOTAL)
            vCnt <= vCnt + 1;
    end
endmodule