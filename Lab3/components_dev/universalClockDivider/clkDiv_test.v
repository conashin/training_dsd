module clkDiv #(
    parameter clkInFreq = 100_000_000, // Input clock frequency (default: 100MHz)
    parameter tgtFreq = 1              // Target output clock frequency (default: 1Hz)
) (
    input clk_in,
    input rst_n,
    output reg clk_out = 0
);

    // Calculate the divider value.  We divide by 2 * target hz because we toggle
    // clk_out, effectively creating a 50% duty cycle.
    localparam divParm = clkInFreq / (2 * tgtFreq);

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