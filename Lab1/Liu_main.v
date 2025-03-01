`include "seg7.v"
`include "divider1khz.v"
    
module Lab1_top (
    input  [2:0] X,
    input  [2:0] Y,
    input  [1:0] sel, // sel[1] LSB
    input rst,
    input clk,
    output reg [7:0] out,
    output [7:0] DN0,
    output [7:0] DN1,
    output reg [7:0] seg_en // Select which 7-segment display to enable, 8 seg7 in Total, only use seg_en[1] and seg_en[0] for DK1 DK0
    );
    
    wire clk_1khz;
    wire [3:0] numx, numy;
    wire [39:0] seg7_data;
    wire [7:0] dummy;
    assign numx = X + 3'b010; // X + 2
    assign numy = Y << 1; // 2 * Y
    assign seg7_data = {6{5'h10}, {sel[1]}, numx, {~sel[1]}, numy}; // Provide 6-digits BLANK and 2-digits data with sel[1] control enable

    div_1khz div1khz(.clk_in(clk), .rst_n(~rst), .clk_out(clk_1khz));
    seg7_display seg7(.clk(clk_1khz), .in(seg7_data), .DN0(DN0), .DN1(DN1), .seg_en(seg_en));
    
    
    always @(*) begin
        if (rst) begin
            seg_en <= 8'b11111111;
            end else begin
            case (sel)
                2'b00: out   = (X << 3) + Y;   // binary representation of 8X + Y
                2'b01: out   = (Y << 4) + X;   // binary representation of 16Y + X
                2'b10: out   = X << Y;         // Logic shift left X by Y bits
                2'b11: out   = Y >> X;         // Logic shift right Y by X bits
                default: out = 8'b00000000;  // default 0
            endcase
            
        end
    end
    
endmodule
