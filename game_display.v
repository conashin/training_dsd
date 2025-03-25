module game_display (
    input wire clk,
    input wire [9:0] h_cnt, v_cnt,
    input wire valid,
    output reg [7:0] rgb
);

    wire [9:0] x = h_cnt - 144;
    wire [9:0] y = v_cnt - 35;

    localparam GRID_W = 80;
    localparam GRID_H = 80;
    localparam BORDER = 5;

    always @(*) begin
        if (!valid) begin
            rgb = 8'b0;
        end else begin
            rgb = 8'b000_000_00;

            if (x < BORDER || x >= 640 - BORDER || y < BORDER || y >= 480 - BORDER)
                rgb = 8'b111_111_11;

            else if (x % GRID_W < 1 || y % GRID_H < 1)
                rgb = 8'b001_001_01;

            else begin
                if (x >= 0*GRID_W && x < 1*GRID_W && y >= 4*GRID_H && y < 5*GRID_H)
                    rgb = 8'b111_000_00;

                else if (x >= 0*GRID_W && x < 2*GRID_W && y >= 0*GRID_H && y < 2*GRID_H)
                    rgb = 8'b000_111_00;

                else if ((x >= 3*GRID_W && x < 4*GRID_W && y >= 1*GRID_H && y < 2*GRID_H) ||
                         (x >= 6*GRID_W && x < 7*GRID_W && y >= 1*GRID_H && y < 2*GRID_H))
                    rgb = 8'b100_100_10;

                else if (x >= 3*GRID_W && x < 4*GRID_W && y >= 4*GRID_H && y < 5*GRID_H)
                    rgb = 8'b111_011_10;

                else if (x >= 3*GRID_W && x < 4*GRID_W && y >= 0*GRID_H && y < 1*GRID_H)
                    rgb = 8'b111_111_00;

                else if (x >= 7*GRID_W && x < 8*GRID_W && y >= 5*GRID_H && y < 6*GRID_H)
                    rgb = 8'b111_101_00;

                else if ((x >= 1*GRID_W && x < 4*GRID_W) && (y >= 3*GRID_H && y < 4*GRID_H))
                    rgb = 8'b111_101_00;

                else if ((x >= 6*GRID_W && x < 7*GRID_W) &&
                         (y >= 3*GRID_H && y < 5*GRID_H))
                    rgb = 8'b000_000_11;
            end
        end
    end

endmodule