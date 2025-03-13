`timescale 1ns / 1ps
module clkDiv_tb;

    // Input clock frequency (fixed)
    parameter CLK_IN_FREQ = 100_000_000; // 100 MHz

    // Target frequencies (multiple instances)
    parameter TARGET_FREQ_1  = 50_000_000;  // 50 MHz (20 ns period)
    parameter TARGET_FREQ_2  = 25_000_000; // 25 MHz (40 ns period)
    parameter TARGET_FREQ_3  = 10_000_000; // 10 MHz (100 ns period)
    parameter TARGET_FREQ_4  = 5_000_000;  //  5 MHz (200 ns period)
    parameter TARGET_FREQ_5  = 2_000_000;    //  2 MHz (500 ns period)
    parameter TARGET_FREQ_6 = 1_000_000; // 1 MHz (1000 ns period)
    parameter TARGET_FREQ_7 = 500_000;    // 500 KHz (2000ns period)
    // Add more target frequencies as needed

    // Signals
    reg clk_in;
    reg rst_n;
    wire clk_out_1;
    wire clk_out_2;
    wire clk_out_3;
    wire clk_out_4;
    wire clk_out_5;
    wire clk_out_6;
    wire clk_out_7;

    // Instantiate multiple clkDiv instances
    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ_1)
    ) dut1 (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out_1)
    );

    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ_2)
    ) dut2 (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out_2)
    );

    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ_3)
    ) dut3 (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out_3)
    );

    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ_4)
    ) dut4 (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out_4)
    );

    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ_5)
    ) dut5 (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out_5)
    );

    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ_6)
    ) dut6 (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out_6)
    );
    
    clkDiv #(
        .clkInFreq(CLK_IN_FREQ),
        .tgtFreq(TARGET_FREQ_7)
    ) dut7 (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_out_7)
    );


    // Clock generation (100 MHz)
    initial begin
        clk_in = 0;
        forever #5 clk_in = ~clk_in; // 10 ns period = 100 MHz
    end

    // Test sequence
    initial begin
        // 1. Reset
        rst_n = 0;
        #20;        // Hold reset for 20 ns
        rst_n = 1;
        #20;        // Wait a bit after reset

        // 2. Observe clk_out signals for a few cycles
        #5000;      // Observe for 5000 ns (5 us) - adjust as needed

        // 3. Apply another reset pulse
        rst_n = 0;
        #10;
        rst_n = 1;

        // 4. Observe clk_out signals again
        #5000;      // Observe for another 5000 ns (5 us)

        // 5. Finish simulation
        $finish;
    end

      // Optional: Monitor signals for debugging
    initial begin
        $dumpfile("clkDiv_tb2.vcd");
        $dumpvars(0, clkDiv_tb);
    end

     // Timescale directive
    

endmodule