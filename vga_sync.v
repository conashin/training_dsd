module vga_sync (
    input wire clk, rst,
    output reg [9:0] h_cnt, v_cnt,
    output wire hsync, vsync,
    output wire valid
);

parameter H_TOTAL = 800;
parameter H_SYNC  = 96;
parameter H_BACK  = 48;
parameter H_DISP  = 640;
parameter H_FRONT = 16;

parameter V_TOTAL = 525;
parameter V_SYNC  = 2;
parameter V_BACK  = 33;
parameter V_DISP  = 480;
parameter V_FRONT = 10;

assign hsync = ~(h_cnt < H_SYNC);
assign vsync = ~(v_cnt < V_SYNC);
assign valid = (h_cnt >= (H_SYNC + H_BACK) && h_cnt < (H_SYNC + H_BACK + H_DISP)) &&
               (v_cnt >= (V_SYNC + V_BACK) && v_cnt < (V_SYNC + V_BACK + V_DISP));

always @(posedge clk or posedge rst) begin
    if (rst) begin
        h_cnt <= 0;
        v_cnt <= 0;
    end else begin
        if (h_cnt == H_TOTAL - 1) begin
            h_cnt <= 0;
            if (v_cnt == V_TOTAL - 1) v_cnt <= 0;
            else v_cnt <= v_cnt + 1;
        end else begin
            h_cnt <= h_cnt + 1;
        end
    end
end

endmodule