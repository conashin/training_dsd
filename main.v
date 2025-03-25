module main(
    input wire clk,
    input wire rst,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b
);

    wire [9:0] h_cnt, v_cnt;
    wire valid;
    wire [7:0] rgb;
    wire clk_25MHz;

    reg [1:0] clkdiv = 0;
    always @(posedge clk) begin
        clkdiv <= clkdiv + 1;
    end
    assign clk_25MHz = clkdiv[1];

    vga_sync sync_gen (
        .clk(clk_25MHz),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid)
    );

    game_display display (
        .clk(clk_25MHz),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .valid(valid),
        .rgb(rgb)
    );

    assign vga_r = {rgb[7:5], rgb[7:6]};
    assign vga_g = {rgb[4:2], rgb[4:3]};
    assign vga_b = {rgb[1:0], rgb[1:0]};

endmodule