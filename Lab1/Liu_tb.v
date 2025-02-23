`timescale 1ns / 1ps

module tb_Lab1_top;
    reg [2:0] X;
    reg [2:0] Y;
    reg [1:0] sel;
    wire [7:0] out;

    // Instantiate the Design Under Test (DUT)
    Lab1_top uut (
        .X(X),
        .Y(Y),
        .sel(sel),
        .out(out)
    );

    initial begin
        $dumpfile("tb_Lab1_top.vcd");
        $dumpvars(0, tb_Lab1_top);

    
        $monitor("Time=%0t | X=%b, Y=%b, sel=%b, out=%b (%d)", 
                 $time, X, Y, sel, out, out);

        // Test case (a): X1 and Y1 from student ID
        X = 3'b101;  // X1 =5
        Y = 3'b011;  // Y1 =3
        
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        // Test case (b): X2=3’b110, Y2=3’b111
        X = 3'b110;
        Y = 3'b111;
        
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        // Test case (c): X3=3’b111, Y3=3’b010
        X = 3'b111;
        Y = 3'b010;
        
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        $finish;
    end
endmodule
