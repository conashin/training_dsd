`timescale 1ns/1ps

module dividerClock #(parameter customOutputCLK0 = 10'b1,
parameter customOutputCLK1 = 10'b1,
parameter customOutputCLK2 = 10'b1
)(
    input clk_in;
    input rst_n;
    output reg clkOut1K = 1,
    output reg clkOut100 = 1,
    output reg clkOut10 = 1,
    output reg clkOut1 = 1,
    output reg clkOutCustom0 = 1,
    output reg clkOutCustom1 = 1,
    output reg clkOutCustom2 = 1
);

    function integer clogb2(input integer bitDepth);
        begin 
            for (clogb2 = 0; bitDepth > 0; clogb2 = clogb2 + 1) begin
                bitDepth = bitDepth >> 1;
            end
        end
    endfunction

    parameter originalClock = 100000000;

    parameter dividerCounter1KHz = originalClock / 100000;
    parameter dividerCounter100Hz = originalClock / 1000000;
    parameter dividerCounter10Hz = originalClock / 10000000;
    parameter dividerCounter1Hz = originalClock / 100000000;
    