module div_1khz(input clk_in,
            input rst_n,
            output reg clk_out = 0);
    
    parameter dividerCounter = 100000; // 100000000 / 1000 = 100000
    reg[1:0] Counter;
    
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            Counter <= 0;
            end else begin
            if (Counter == (dividerCounter - 1)) begin
                Counter <= 0;
                end else begin
                Counter <= Counter + 1;
            end
        end
    end
    
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            clk_out <= 1'b0;
            end else begin
            if (Counter < (dividerCounter / 2)) begin
                clk_out <= 1'b0;
            end
            else begin
                clk_out <= 1'b1;
            end
        end
    end
endmodule
