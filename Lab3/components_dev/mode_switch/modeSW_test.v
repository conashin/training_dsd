module modeSW(
    input clk,
    input rst,
    input buttom, // S2
    output reg [1:0] mode
);
    localparam FASTBALL = 0, CHANGE_UP = 1, SLIDER = 2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode <= FASTBALL;
        end
        else begin
            case(mode)
                FASTBALL:   mode <= CHANGE_UP;
                CHANGE_UP:  mode <= SLIDER;
                SLIDER:     mode <= FASTBALL;
                default:    mode <= FASTBALL;
            endcase
        end
    end
endmodule