// This file is for testing the debouncer module
module clkEnable(input Clk_100M,
                    output slow_clk_en);
    reg [26:0]counter = 0;
    parameter dividerCounter = 2;
    
    always @(posedge Clk_100M)
    begin
        counter <= (counter >= 249999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 249999)?1'b1:1'b0;
endmodule
    
    module dff( // D stands for input Data, Q stands for output Data
        input clk,
        input D,
        output reg Q
        );
        
        always @(posedge clk) begin
            Q <= D;
        end
    endmodule
        
        module debouncing( // Debouncing module which input inSignal detect for bouncing active and output debouncedSignal
            input clk,
            input rst,
            input inSignal,
            output debouncedSignal
            );
            
            wire slowClk;
            wire L0, L1;
            
            clkEnable clkEn(
            .Clk_100M(clk),
            .slow_clk_en(slowClk)
            );
            
            dff dff0(
            .clk(slowClk),
            .D(inSignal),
            .Q(L0)
            );
            
            dff dff1(
            .clk(slowClk),
            .D(L0),
            .Q(L1)
            );
            
            and and0(debouncedSignal, L0, ~L1);
            
        endmodule
