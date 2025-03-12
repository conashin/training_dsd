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
