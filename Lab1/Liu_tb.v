`timescale 1ns / 1ns

module tb_Lab1_top; reg [2:0] X; reg [2:0] Y; reg [1:0] sel; reg rst; reg clk; wire [7:0] out; wire [7:0] DN0; wire [7:0] DN1; wire [7:0] seg_en; integer file; Lab1_top uut (.X(X), .Y(Y), .sel(sel), .rst(rst), .clk(clk), .out(out), .DN0(DN0), .DN1(DN1), .seg_en(seg_en));

initial begin
    $dumpfile("Lab1_top.vcd");
    $dumpvars(0, tb_Lab1_top);
end

initial begin
    file = $fopen("Lab1_output.txt", "w");
    if (!file) begin
        $display("Error: Cannot open file!");
        $finish;
    end
    
    clk     = 0;
    rst     = 1;
    #10 rst = 0;
    
    test_case(3'b101, 3'b011);
    test_case(3'b110, 3'b111);
    test_case(3'b111, 3'b010);
    
    $fclose(file);
    $display("File writing complete!");
    #10000000
    $finish;
end

always #5 clk = ~clk;

task test_case(input [2:0] x_val, input [2:0] y_val);
    begin
        X   = x_val; Y   = y_val;
        sel = 2'b00;
        
        repeat (4) begin
            #10;
            $fdisplay(file, "%0t,%b,%b,%b,%h,%h,%h,%h",
            $time, X, Y, sel, out, DN0, DN1, seg_en);
            sel = sel + 1'b1;
        end
    end
endtask

endmodule
