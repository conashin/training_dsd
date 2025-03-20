`timescale 1ns / 1ps
module clkDiv_tb;

    // Parameters (Match the DUT parameters)
    parameter CLK_IN_FREQ = 1_000_000; // 1 MHz input clock
    parameter TARGET_FREQ   = 1_000;     // Target frequency: 1 kHz

    // Signals
    reg clk_in;
    reg rst_n;
    wire clk_out;

    // Instantiate the Device Under Test (DUT)
    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ)
    ) dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out)
    );

    // Clock generation (1 MHz)
    initial begin
        clk_in = 0;
        forever #0.5 clk_in = ~clk_in; // 1 us period = 1 MHz (0.5 us high, 0.5 us low)
    end

    // Test sequence
    initial begin
        // 1. Reset
        rst_n = 0;
        #2;        // Hold reset for 2 us
        rst_n = 1;
        #2;        // Wait a bit after reset

        // 2. Observe clk_out for a few cycles (at least 2 full cycles of the target frequency)
        #(1000000000 / TARGET_FREQ * 2 /1000);   // Wait for 2 full cycles of 1kHz = 2ms. (adjusted for ns timescale)
        

        // 3. Apply another reset pulse
        rst_n = 0;
        #1;
        rst_n = 1;

         // 4. Observe clk_out again
        #(1000000000 / TARGET_FREQ * 2/1000);  // Wait for another 2 cycles = 2ms

        // 5. Finish simulation
        $finish;
    end

      // Optional: Monitor signals for debugging (useful with a waveform viewer)
    initial begin
        $dumpfile("clkDiv_tb.vcd"); // Create a VCD file for waveform viewing
        $dumpvars(0, clkDiv_tb);      // Dump all variables in the testbench
    end

     // Timescale directive (optional, but good practice)
    // `timescale 1ns / 1ps  // Set timescale to 1 ns with 1 ps precision

endmodule