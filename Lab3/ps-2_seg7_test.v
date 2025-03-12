module main(
    input clk,
    input ps2clk
);

    localparam FKey

endmodule


module ps2Processing(
    input ps2Clk,
    input [7:0] ps2Data,
    input rst,
    output reg [23:0] ps2DataOut, // {Byte3, Byte2, Byte1}
    output ps2ReadDone // Read ps2DataOut while ps2ReadDone == 1
);

    // FSM from fsm_ps2
	localparam byte1 = 0, byte2 = 1, byte3 = 2, statDone = 3;
    reg [1:0] nowStat, nextStat;
    // int Counter;

    // State transition logic (combinational)
    always @(*) begin
        case(nowStat)
            byte1: nextStat = (ps2Data[3]) ? byte2 : byte1;
            byte2: nextStat = byte3;
            byte3: nextStat = statDone;
            statDone: nextStat = (ps2Data[3]) ? byte2 : byte1; // Continue read byte2, if not back to byte1
        endcase
    end

    // State flip-flops (sequential)
    always @(posedge ps2Clk) begin
        if (rst) begin
            nowStat <= byte1; // Change now to init state
        end
        else begin
            nowStat <= nextStat; // Change now to next state
            case(nextStat)
                byte2: ps2DataOut[23:16] = ps2Data;
                byte3: ps2DataOut[15:8] = ps2Data;
                statDone: ps2DataOut[7:0] = ps2Data;
            endcase
        end
    end          
    // Output logic
    assign ps2ReadDone = (nowStat == statDone);
	
endmodule
