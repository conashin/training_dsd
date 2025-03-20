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


// Usage
/*
     clkDiv #(
        .CLK_IN_HZ(100_000_000), // Or use clk, and get the frequency from the constraint file.
        .TARGET_HZ(1)
    ) div1Hz ( // 實例化1Hz clock divider
        .clk_in(clk),
        .rst_n(rst),
        .clk_out(Clk1Hz) // Output is Clk1Hz
    );
*/