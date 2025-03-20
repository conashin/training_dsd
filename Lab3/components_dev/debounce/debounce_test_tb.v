`timescale 1ns / 1ps
// testbench verilog code for debouncing button without creating another clock
module tb_button; reg pb_1; reg clk; wire pb_out; keyDebouncing uut (clk,
                                                                  1'b0,
                                                                  pb_1,
                                                                  pb_out);
    initial begin
        clk             = 0;
        forever #10 clk = ~clk;
    end
    initial begin
        $dumpfile("debounce_test.vcd");
        $dumpvars(0, tb_button);
    end
    initial begin
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #20;
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #30;
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #40;
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #30;
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #1000;
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #20;
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #30;
        pb_1 = 0;
        #10;
        pb_1 = 1;
        #40;
        pb_1 = 0;
        #10000;
        $finish;
    end
    
endmodule
