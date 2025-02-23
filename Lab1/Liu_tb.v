`timescale 1ns / 1ns

module tb_Lab1_top;
    reg [2:0] X;
    reg [2:0] Y;
    reg [1:0] sel;
    wire [7:0] out;
    integer file;

    Lab1_top uut ( .X(X), .Y(Y), .sel(sel), .out(out) );

    initial begin
        file = $fopen("Lab1_output.txt", "w");
        if (!file) begin
            $display("Error: Cannot open file!");
            $finish;
        end

        test_case(3'b101, 3'b011);
        test_case(3'b110, 3'b111);
        test_case(3'b111, 3'b010);

        $fclose(file);
        $display("File writing complete!");
    end

    task test_case(input [2:0] x_val, input [2:0] y_val);
        begin
            X = x_val; Y = y_val;
            sel = 2'b00;

            repeat (4) begin
                #10;
               $fdisplay(file, "%0t,%b,%b,%b,%b,%d", 
                          $time, X, Y, sel, out, out);
                sel = sel + 1'b1;
            end
        end
    endtask

endmodule
